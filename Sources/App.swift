import SwiftUI
import AppKit
import UniformTypeIdentifiers
import UserNotifications

@MainActor
final class ConverterViewModel: ObservableObject {
    @Published var items: [BatchItem] = []
    @Published var isConverting: Bool = false
    @Published var isCancelled: Bool = false

    @Published var penScale: Double = 1.5
    @Published var markerScale: Double = 1.0
    @Published var splitOption: SplitOption = .none
    @Published var autoSplit: Bool = false

    @Published var statusKey: String = "status_ready"
    @Published var isDropHovered: Bool = false

    @Published var showPreferences: Bool = false
    @Published var showPermissionSheet: Bool = false
    @Published var showSuccessSheet: Bool = false
    @Published var successOutputPath: String = ""
    @Published var successThumbnail: NSImage? = nil

    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - 파일 및 폴더 탐색 (A + B 하이브리드)
    func browseFilesAndFolders(settings: AppSettings) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [
            UTType(filenameExtension: "sdocx") ?? .data,
            .folder,
            .directory,
            .item
        ]
        panel.directoryURL = URL(fileURLWithPath: settings.lastBrowseDir)
        panel.prompt = settings.tr("browse")

        if panel.runModal() == .OK {
            addURLs(panel.urls, settings: settings)
        }
    }

    func handleDrop(providers: [NSItemProvider], settings: AppSettings) -> Bool {
        let group = DispatchGroup()
        var collectedURLs: [URL] = []
        let lock = NSLock()

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    defer { group.leave() }
                    var resolvedURL: URL?
                    if let u = item as? URL {
                        resolvedURL = u
                    } else if let data = item as? Data {
                        resolvedURL = URL(dataRepresentation: data, relativeTo: nil)
                    }
                    if let url = resolvedURL {
                        lock.lock()
                        collectedURLs.append(url)
                        lock.unlock()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            self.addURLs(collectedURLs, settings: settings)
        }
        return true
    }

    func addURLs(_ urls: [URL], settings: AppSettings, isExternalOpen: Bool = false) {
        var sdocxURLs: [URL] = []
        for url in urls {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    // 폴더를 통째로 넣었을 때 (선택지 B 방식: 재귀 자동 탐색)
                    let found = scanDirectoryForSDOCX(url: url)
                    sdocxURLs.append(contentsOf: found)
                } else if url.pathExtension.lowercased() == "sdocx" {
                    // 개별 sdocx 파일을 여러 개 넣었을 때 (선택지 A 방식)
                    sdocxURLs.append(url)
                }
            }
        }

        guard !sdocxURLs.isEmpty else {
            if !urls.isEmpty {
                errorMessage = settings.tr("error_no_sdocx_found")
                showErrorAlert = true
            }
            return
        }

        // 외부에서 '다음으로 열기'로 열었거나, 이전 항목들이 모두 이미 성공 완료된 상태라면 새 작업을 위해 대기열 정리
        if isExternalOpen || (!items.isEmpty && items.allSatisfy { $0.status.isSuccess }) {
            items.removeAll()
        }

        var existing = Set(items.map { $0.url.path })
        for u in sdocxURLs {
            if !existing.contains(u.path) {
                items.append(BatchItem(url: u, status: .pending))
                existing.insert(u.path)
            } else if let idx = items.firstIndex(where: { $0.url.path == u.path }) {
                // 이미 대기열에 있던 파일이라도 다시 추가되면 상태를 .pending으로 리셋하여 재변환 가능하게 함
                items[idx].status = .pending
            }
        }

        if let first = sdocxURLs.first {
            let parent = first.deletingLastPathComponent().path
            settings.lastBrowseDir = parent
        }

        if items.count == 1 {
            statusKey = "status_file_ready"
        } else {
            statusKey = "status_queue_ready"
        }

        if isExternalOpen && settings.autoConvertOnOpenWith && !isConverting {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startConversion(settings: settings, forceReconvert: true)
            }
        }
    }

    private func scanDirectoryForSDOCX(url: URL) -> [URL] {
        var results: [URL] = []
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else {
            return results
        }

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension.lowercased() == "sdocx" {
                results.append(fileURL)
            }
        }
        return results.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        if items.isEmpty {
            statusKey = "status_ready"
        } else if items.count == 1 {
            statusKey = "status_file_ready"
        }
    }

    func clearAll() {
        items.removeAll()
        statusKey = "status_ready"
    }

    // MARK: - 변환 실행 (단일 & 배치 통합)
    func startConversion(settings: AppSettings, forceReconvert: Bool = false) {
        guard !items.isEmpty else { return }

        // 전체 재변환 요청이거나 모든 항목이 이미 완료 상태였던 경우 전체를 .pending으로 리셋
        if forceReconvert || items.allSatisfy({ $0.status.isSuccess }) {
            for i in items.indices {
                items[i].status = .pending
            }
        }

        isConverting = true
        isCancelled = false

        let currentPen = penScale
        let currentMarker = markerScale
        let currentSplit = splitOption
        let currentAuto = autoSplit

        Task {
            var successCount = 0
            var failCount = 0

            for index in self.items.indices {
                if self.isCancelled { break }
                let item = self.items[index]
                let input = item.url.path
                let baseName = item.url.deletingPathExtension().lastPathComponent

                let outDir: String
                if settings.outputMode == .custom && !settings.customOutputDir.isEmpty {
                    outDir = settings.customOutputDir
                } else {
                    outDir = item.url.deletingLastPathComponent().path
                }
                let outPath = URL(fileURLWithPath: outDir).appendingPathComponent("\(baseName).pdf").path

                // 만약 status가 성공으로 되어있더라도, 파일이 디스크에 실제 없거나 forceReconvert인 경우 재변환
                if case .success(let prevOut, _) = self.items[index].status, !forceReconvert {
                    if FileManager.default.fileExists(atPath: prevOut) {
                        successCount += 1
                        continue
                    }
                }

                self.items[index].status = .converting

                do {
                    try await ConverterService.shared.convert(
                        input: input,
                        output: outPath,
                        penScale: currentPen,
                        markerScale: currentMarker,
                        split: currentSplit,
                        autoSplit: currentAuto
                    )

                    let thumb = ConverterService.shared.generateThumbnail(for: outPath)
                    self.items[index].status = .success(outputPath: outPath, thumbnail: thumb)
                    successCount += 1

                    // 단일 파일 변환이었던 경우 성공 시트 표시
                    if self.items.count == 1 {
                        self.successOutputPath = outPath
                        self.successThumbnail = thumb
                        self.showSuccessSheet = true
                    }
                } catch {
                    self.items[index].status = .failed(message: error.localizedDescription)
                    failCount += 1
                }
            }

            self.isConverting = false

            if self.items.count == 1 {
                if successCount > 0 {
                    self.statusKey = "status_done"
                } else {
                    self.statusKey = "status_ready"
                }
                if settings.enableNotifications {
                    NotificationManager.shared.sendConversionCompletedNotification(
                        successCount: successCount,
                        failCount: failCount,
                        totalCount: 1,
                        singleFileName: self.items.first?.fileName
                    )
                }
            } else {
                self.statusKey = "batch_all_completed"
                if settings.enableNotifications {
                    NotificationManager.shared.sendConversionCompletedNotification(
                        successCount: successCount,
                        failCount: failCount,
                        totalCount: self.items.count,
                        singleFileName: nil
                    )
                }
            }
        }
    }

    func cancelConversion() {
        isCancelled = true
        isConverting = false
        statusKey = "cancel"
    }

    // MARK: - Finder 연동
    func revealInFinder(path: String) {
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            proc.arguments = ["-R", path]
            try? proc.run()
        }
    }

    func openOutputFolder(settings: AppSettings) {
        let folderPath: String
        if settings.outputMode == .custom && !settings.customOutputDir.isEmpty {
            folderPath = settings.customOutputDir
        } else if let first = items.first {
            folderPath = first.url.deletingLastPathComponent().path
        } else {
            folderPath = settings.lastBrowseDir
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: folderPath))
    }

    // MARK: - 사전 권한 요청
    func requestInitialFolderPermissions(settings: AppSettings) {
        showPermissionSheet = false
        settings.hasRequestedPermissions = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            let dirs: [FileManager.SearchPathDirectory] = [.desktopDirectory, .documentDirectory, .downloadsDirectory]
            for dir in dirs {
                if let dirURL = fm.urls(for: dir, in: .userDomainMask).first {
                    _ = try? fm.contentsOfDirectory(atPath: dirURL.path)
                }
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var pendingURLs: [URL] = []
    private var batchBuffer: [URL] = []
    private var debounceWorkItem: DispatchWorkItem?
    private var lastHandledTimestamp: Date = .distantPast
    private var lastHandledPaths: Set<String> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            LetsMoveManager.shared.checkAndMoveToApplicationsIfNeeded()
        }
    }

    var onOpenURLs: (([URL]) -> Void)? {
        didSet {
            if onOpenURLs != nil && !pendingURLs.isEmpty {
                let toHandle = pendingURLs
                pendingURLs.removeAll()
                enqueueURLs(toHandle)
            }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        DispatchQueue.main.async {
            self.enqueueURLs(urls)
        }
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        let urls = filenames.map { URL(fileURLWithPath: $0) }
        DispatchQueue.main.async {
            self.enqueueURLs(urls)
        }
        sender.reply(toOpenOrPrint: .success)
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        DispatchQueue.main.async {
            self.enqueueURLs([url])
        }
        return true
    }

    func enqueueURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }

        guard let handler = self.onOpenURLs else {
            for u in urls {
                if !pendingURLs.contains(where: { $0.path == u.path }) {
                    pendingURLs.append(u)
                }
            }
            return
        }

        for u in urls {
            if !batchBuffer.contains(where: { $0.path == u.path }) {
                batchBuffer.append(u)
            }
        }

        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let urlsToProcess = self.batchBuffer
            self.batchBuffer.removeAll()

            guard !urlsToProcess.isEmpty else { return }

            let paths = Set(urlsToProcess.map { $0.path })
            let now = Date()
            if now.timeIntervalSince(self.lastHandledTimestamp) < 0.5 && paths == self.lastHandledPaths {
                return
            }
            self.lastHandledTimestamp = now
            self.lastHandledPaths = paths
            handler(urlsToProcess)
        }
        debounceWorkItem = workItem
        // 150ms 대기: Finder에서 여러 파일을 동시 선택해 열 때 각 파일별 이벤트가 순차 도착하므로 하나의 배열로 취합
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }
}

@main
struct SDOCXConverterNativeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = AppSettings()
    @StateObject private var vm = ConverterViewModel()

    init() {
        if let idx = CommandLine.arguments.firstIndex(of: "--notify") {
            let title = CommandLine.arguments.count > idx + 1 ? CommandLine.arguments[idx + 1] : "SDOCX Converter"
            let body = CommandLine.arguments.count > idx + 2 ? CommandLine.arguments[idx + 2] : "변환 완료"

            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            if let iconURL = Bundle.main.url(forResource: "notification_icon", withExtension: "png"),
               let attachment = try? UNNotificationAttachment(identifier: "app_logo", url: iconURL, options: nil) {
                content.attachments = [attachment]
            }
            let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            let sema = DispatchSemaphore(value: 0)
            center.add(req) { err in
                if let err = err {
                    fputs("Notification error: \(err)\n", stderr)
                } else {
                    fputs("Notification sent successfully\n", stderr)
                }
                sema.signal()
            }
            _ = sema.wait(timeout: .now() + 1.0)
            exit(0)
        }
    }

    var body: some Scene {
        Window("SDOCX → PDF 변환기", id: "main") {
            MainContentView()
                .environmentObject(settings)
                .environmentObject(vm)
                .preferredColorScheme(settings.theme.colorScheme)
                .onAppear {
                    appDelegate.onOpenURLs = { urls in
                        vm.addURLs(urls, settings: settings, isExternalOpen: true)
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        if let window = NSApplication.shared.windows.first {
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                    MenuBarController.shared.setup(settings: settings, viewModel: vm)
                    NotificationManager.shared.requestAuthorization()
                    QuickActionManager.shared.installIfNeeded()
                    if settings.automaticallyCheckForUpdates {
                        UpdateManager.shared.checkForUpdates(silent: true)
                    }
                }
                .onOpenURL { url in
                    appDelegate.enqueueURLs([url])
                }
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About SDOCX Converter") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "SDOCX Converter",
                            NSApplication.AboutPanelOptionKey.version: "1.0.0",
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "Copyright © 2026 FizzyHedgehog. All rights reserved.",
                            NSApplication.AboutPanelOptionKey(rawValue: "Credits"): NSAttributedString(
                                string: "Based on squ1dd13/sdocx2pdf (MIT License)\nPublished by FizzyHedgehog"
                            )
                        ]
                    )
                }
            }
        }
    }
}

struct MainContentView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var vm: ConverterViewModel
    @ObservedObject private var updateManager = UpdateManager.shared

    private var allSucceeded: Bool {
        !vm.items.isEmpty && vm.items.allSatisfy { $0.status.isSuccess }
    }

    var body: some View {
        VStack(spacing: 12) {
            // 상단 타이틀 바
            HStack {
                Text(settings.tr("app_title"))
                    .font(.system(size: 19, weight: .bold))
                Spacer()
                Button(action: { vm.showPreferences = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)

                        if updateManager.hasUpdate {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 3, y: -3)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help(settings.tr("prefs_tooltip"))
            }

            // 본문 영역: 상태에 따라 동적 UI 전환
            if vm.items.isEmpty {
                // 1. 대기열이 비어있을 때: 메인 드롭존 + 파일 찾기 버튼
                DropZoneView(itemCount: 0, isHovering: vm.isDropHovered, tr: settings.tr)
                    .onDrop(of: [.fileURL], isTargeted: $vm.isDropHovered) { providers in
                        vm.handleDrop(providers: providers, settings: settings)
                    }

                Button(action: { vm.browseFilesAndFolders(settings: settings) }) {
                    Text(settings.tr("browse"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else if vm.items.count == 1 {
                // 2. 단일 파일 등록 시: 카드 뷰 (하이브리드 확장 가능)
                SingleItemCardView(
                    item: vm.items[0],
                    tr: settings.tr,
                    onRemove: { vm.clearAll() },
                    onAddMore: { vm.browseFilesAndFolders(settings: settings) },
                    onReveal: {
                        if case .success(let outPath, _) = vm.items[0].status {
                            vm.revealInFinder(path: outPath)
                        }
                    }
                )
                .onDrop(of: [.fileURL], isTargeted: $vm.isDropHovered) { providers in
                    vm.handleDrop(providers: providers, settings: settings)
                }
            } else {
                // 3. 다중 파일 등록 시: 대기열 목록 뷰 (선택지 A & B 통합)
                BatchQueueView(
                    items: vm.items,
                    isConverting: vm.isConverting,
                    tr: settings.tr,
                    onAddMore: { vm.browseFilesAndFolders(settings: settings) },
                    onClearAll: { vm.clearAll() },
                    onRemoveItem: { id in vm.removeItem(id: id) },
                    onRevealItem: { path in vm.revealInFinder(path: path) }
                )
                .onDrop(of: [.fileURL], isTargeted: $vm.isDropHovered) { providers in
                    vm.handleDrop(providers: providers, settings: settings)
                }
            }

            // 변환 옵션 영역
            VStack(spacing: 10) {
                // 펜 두께 배율
                HStack(spacing: 12) {
                    Text(settings.tr("pen_scale"))
                        .frame(width: 140, alignment: .leading)
                    Slider(value: $vm.penScale, in: 0.5...3.0, step: 0.1)
                    Text(String(format: "%.1f", vm.penScale))
                        .frame(width: 44, alignment: .trailing)
                        .monospacedDigit()
                    Stepper("", value: $vm.penScale, in: 0.5...3.0, step: 0.1)
                        .labelsHidden()
                }

                // 마커 두께 배율
                HStack(spacing: 12) {
                    Text(settings.tr("marker_scale"))
                        .frame(width: 140, alignment: .leading)
                    Slider(value: $vm.markerScale, in: 0.5...3.0, step: 0.1)
                    Text(String(format: "%.1f", vm.markerScale))
                        .frame(width: 44, alignment: .trailing)
                        .monospacedDigit()
                    Stepper("", value: $vm.markerScale, in: 0.5...3.0, step: 0.1)
                        .labelsHidden()
                }

                // 페이지 분할
                HStack(spacing: 12) {
                    Text(settings.tr("split_mode"))
                        .frame(width: 140, alignment: .leading)
                    Picker("", selection: $vm.splitOption) {
                        ForEach(SplitOption.allCases) { opt in
                            Text(opt.title(for: settings.language)).tag(opt)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 자동 분할 체크박스
                HStack {
                    Spacer().frame(width: 152)
                    Toggle(settings.tr("auto_split"), isOn: $vm.autoSplit)
                        .toggleStyle(.checkbox)
                    Spacer()
                }
            }
            .padding(.vertical, 2)

            // 하단 변환 시작 / 일괄 액션 버튼
            if vm.isConverting {
                HStack(spacing: 10) {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.trailing, 4)
                        Text(vm.items.count > 1
                             ? String(format: settings.tr("batch_converting_btn"), vm.items.filter { $0.status.isFinished }.count, vm.items.count)
                             : settings.tr("converting"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(6)

                    Button(action: { vm.cancelConversion() }) {
                        Text(settings.tr("cancel"))
                    }
                    .buttonStyle(.bordered)
                }
            } else if allSucceeded {
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Button(action: { vm.startConversion(settings: settings, forceReconvert: true) }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(settings.tr("btn_reconvert"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.bordered)

                        Button(action: { vm.openOutputFolder(settings: settings) }) {
                            HStack {
                                Image(systemName: "folder")
                                Text(settings.tr("open_output_folder"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button(action: { vm.clearAll() }) {
                        HStack {
                            Image(systemName: "trash")
                            Text(settings.tr("btn_start_new"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Button(action: { vm.startConversion(settings: settings) }) {
                    Text(vm.items.count > 1
                         ? String(format: settings.tr("batch_convert_btn"), vm.items.count)
                         : settings.tr("convert"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.items.isEmpty)
            }

            // 상태 표시줄
            statusView
        }
        .padding(20)
        .frame(width: 520)
        .onAppear {
            if !settings.hasRequestedPermissions {
                vm.showPermissionSheet = true
            }
        }
        .sheet(isPresented: $vm.showPermissionSheet) {
            InitialPermissionSheet(
                tr: settings.tr,
                onGrant: { vm.requestInitialFolderPermissions(settings: settings) },
                onSkip: {
                    vm.showPermissionSheet = false
                    settings.hasRequestedPermissions = true
                }
            )
        }
        .sheet(isPresented: $vm.showPreferences) {
            PreferencesView(settings: settings)
        }
        .sheet(isPresented: $vm.showSuccessSheet, onDismiss: {
            vm.clearAll()
        }) {
            SuccessSheetView(
                outputPath: vm.successOutputPath,
                thumbnail: vm.successThumbnail,
                tr: settings.tr,
                onReveal: {
                    let out = vm.successOutputPath
                    vm.revealInFinder(path: out)
                    vm.clearAll()
                    vm.showSuccessSheet = false
                },
                onStartNew: {
                    vm.clearAll()
                    vm.showSuccessSheet = false
                },
                onDismiss: {
                    vm.clearAll()
                    vm.showSuccessSheet = false
                }
            )
        }
        .alert(settings.tr("error_title"), isPresented: $vm.showErrorAlert) {
            Button(settings.tr("ok")) { }
        } message: {
            Text(vm.errorMessage)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if vm.statusKey == "batch_all_completed" {
            let succ = vm.items.filter { $0.status.isSuccess }.count
            let fail = vm.items.count - succ
            Text(String(format: settings.tr("batch_all_completed"), succ, fail))
                .font(.footnote)
                .foregroundColor(fail > 0 ? .orange : .green)
        } else if vm.statusKey == "status_queue_ready" {
            Text(String(format: settings.tr("status_queue_ready"), vm.items.count))
                .font(.footnote)
                .foregroundColor(.secondary)
        } else {
            Text(settings.tr(vm.statusKey))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
