import SwiftUI
import AppKit

// MARK: - 드래그 앤 드롭 영역
struct DropZoneView: View {
    let itemCount: Int
    let isHovering: Bool
    var tr: ((String) -> String)? = nil
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHovering ? Color.accentColor : Color.secondary.opacity(0.35),
                    style: StrokeStyle(lineWidth: isHovering ? 2.5 : 1.5, dash: [6, 4])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isHovering ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.02))
                )

            VStack(spacing: 8) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 34))
                    .foregroundColor(isHovering ? .accentColor : .secondary)

                Text(settings.tr("drop_prompt"))
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                Text(settings.tr("drop_subprompt"))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .id(settings.language)
    }
}

// MARK: - 단일 파일 카드 뷰 (아이템이 1개일 때 표시)
struct SingleItemCardView: View {
    let item: BatchItem
    var tr: ((String) -> String)? = nil
    @EnvironmentObject var settings: AppSettings
    let onRemove: () -> Void
    let onAddMore: () -> Void
    let onReveal: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                // 아이콘 / 상태
                switch item.status {
                case .pending:
                    Image(systemName: "doc.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                case .converting:
                    ProgressView()
                        .controlSize(.regular)
                        .frame(width: 30, height: 30)
                case .success(_, let thumb):
                    if let thumb = thumb {
                        Image(nsImage: thumb)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 40)
                            .cornerRadius(3)
                            .shadow(radius: 1)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.green)
                    }
                case .failed:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                }

                // 파일 정보
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.fileName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    HStack(spacing: 6) {
                        Text(item.parentDirectoryName)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        if !item.fileSizeString.isEmpty {
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text(item.fileSizeString)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // 우측 버튼들
                if case .success = item.status {
                    Button(action: onReveal) {
                        Label(settings.tr("open_file"), systemImage: "folder")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                if !item.status.isConverting {
                    Button(action: onAddMore) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .help(settings.tr("add_more"))

                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary.opacity(0.8))
                    .help(settings.language == .ko ? "삭제" : "Remove")
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .id(settings.language)
    }
}

// MARK: - 대기열 목록 행 (BatchItemRowView)
struct BatchItemRowView: View {
    let item: BatchItem
    var tr: ((String) -> String)? = nil
    @EnvironmentObject var settings: AppSettings
    let onRemove: () -> Void
    let onReveal: (String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            // 상태 아이콘
            switch item.status {
            case .pending:
                Image(systemName: "doc.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 22)
            case .converting:
                ProgressView()
                    .controlSize(.small)
                    .frame(width: 22)
            case .success(_, let thumb):
                if let thumb = thumb {
                    Image(nsImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 22)
                        .cornerRadius(2)
                        .shadow(radius: 1)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .frame(width: 22)
                }
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(width: 22)
            }

            // 파일 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(item.fileName)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 4) {
                    Text(item.parentDirectoryName)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if !item.fileSizeString.isEmpty {
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                        Text(item.fileSizeString)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // 우측 액션
            switch item.status {
            case .pending:
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help(settings.language == .ko ? "제거" : "Remove")

            case .converting:
                Text(settings.tr("status_converting"))
                    .font(.system(size: 10))
                    .foregroundColor(.accentColor)

            case .success(let outPath, _):
                Button(action: { onReveal(outPath) }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderless)
                .foregroundColor(.accentColor)
                .help(settings.tr("reveal"))

            case .failed(let msg):
                Text(settings.tr("status_failed"))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.red)
                    .help(msg)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        )
        .id(settings.language)
    }
}

// MARK: - 대기열 컨테이너 뷰 (BatchQueueView)
struct BatchQueueView: View {
    let items: [BatchItem]
    let isConverting: Bool
    var tr: ((String) -> String)? = nil
    @EnvironmentObject var settings: AppSettings
    let onAddMore: () -> Void
    let onClearAll: () -> Void
    let onRemoveItem: (UUID) -> Void
    let onRevealItem: (String) -> Void

    private var finishedCount: Int {
        items.filter { $0.status.isFinished }.count
    }

    var body: some View {
        VStack(spacing: 8) {
            // 대기열 상단 헤더
            HStack {
                HStack(spacing: 6) {
                    Text(settings.tr("queue_title"))
                        .font(.system(size: 13, weight: .bold))
                    Text(String(format: settings.tr("queue_count"), items.count))
                        .font(.system(size: 11))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                        .foregroundColor(.accentColor)
                }

                Spacer()

                if !isConverting {
                    Button(action: onAddMore) {
                        Label(settings.tr("add_more"), systemImage: "plus")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.borderless)

                    Button(action: onClearAll) {
                        Text(settings.tr("clear_all"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
            }

            // 변환 진행 바 (변환 중이거나 부분 완료된 경우)
            if isConverting || finishedCount > 0 {
                VStack(spacing: 4) {
                    let pct = items.isEmpty ? 0 : Int((Double(finishedCount) / Double(items.count)) * 100)
                    HStack {
                        Text(String(format: settings.tr("batch_progress"), finishedCount, items.count, pct))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    ProgressView(value: Double(finishedCount), total: Double(max(items.count, 1)))
                        .progressViewStyle(.linear)
                }
                .padding(.vertical, 2)
            }

            // 파일 목록 리스트
            ScrollView {
                LazyVStack(spacing: 5) {
                    ForEach(items) { item in
                        BatchItemRowView(
                            item: item,
                            onRemove: { onRemoveItem(item.id) },
                            onReveal: onRevealItem
                        )
                    }
                }
                .padding(4)
            }
            .frame(maxHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .textBackgroundColor).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                    )
            )
        }
        .id(settings.language)
    }
}

// MARK: - 성공 알림 시트 (PDF 썸네일 카드 포함)
struct SuccessSheetView: View {
    let outputPath: String
    let thumbnail: NSImage?
    let tr: (String) -> String
    let onReveal: () -> Void
    let onStartNew: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                if let thumb = thumbnail {
                    Image(nsImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 104)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                } else {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.accentColor)
                        .frame(width: 80, height: 104)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(tr("success_title"))
                        .font(.system(size: 15, weight: .semibold))
                    Text(outputPath)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .truncationMode(.middle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 8)

            HStack(spacing: 10) {
                Button(action: onReveal) {
                    Label(tr("reveal"), systemImage: "folder")
                }
                .buttonStyle(.bordered)

                Button(action: onStartNew) {
                    Label(tr("btn_new_conversion"), systemImage: "plus")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action: onDismiss) {
                    Text(tr("ok"))
                        .frame(minWidth: 70)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 530)
    }
}

// MARK: - 첫 실행 권한 안내 시트 (InitialPermissionSheet)
struct InitialPermissionSheet: View {
    let tr: (String) -> String
    let onGrant: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 46))
                .foregroundColor(.accentColor)
                .padding(.top, 10)

            Text(tr("perm_dialog_title"))
                .font(.system(size: 17, weight: .bold))

            Text(tr("perm_dialog_desc"))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .lineSpacing(3)

            HStack(spacing: 14) {
                Button(action: onSkip) {
                    Text(tr("perm_skip_btn"))
                        .frame(minWidth: 90)
                }
                .buttonStyle(.bordered)

                Button(action: onGrant) {
                    Text(tr("perm_grant_btn"))
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom, 6)
        }
        .padding(24)
        .frame(width: 440)
    }
}

// MARK: - 설정 창 (Preferences)
struct PreferencesView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject private var updateManager = UpdateManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 상단 고정 헤더
            HStack {
                Text(settings.tr("prefs_title"))
                    .font(.headline)
                Spacer()
                Button(settings.tr("close")) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // 저장 위치
                    GroupBox(label: Text(settings.tr("grp_output")).font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                    Picker("", selection: $settings.outputMode) {
                        Text(settings.tr("out_same")).tag(OutputMode.same)
                        Text(settings.tr("out_custom")).tag(OutputMode.custom)
                    }
                    .pickerStyle(.radioGroup)

                    if settings.outputMode == .custom {
                        HStack {
                            TextField(settings.tr("out_placeholder"), text: $settings.customOutputDir)
                                .textFieldStyle(.roundedBorder)
                                .disabled(true)
                            Button(settings.tr("out_choose")) {
                                chooseFolder()
                            }
                        }
                        .padding(.leading, 20)
                    }
                }
                .padding(8)
            }

            // 테마 모드
            GroupBox(label: Text(settings.tr("grp_theme")).font(.headline)) {
                Picker("", selection: $settings.theme) {
                    ForEach(ThemeMode.allCases) { mode in
                        Text(mode.displayName(for: settings.language)).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                .padding(8)
            }

            // 언어
            GroupBox(label: Text(settings.tr("grp_lang")).font(.headline)) {
                Picker("", selection: $settings.language) {
                    ForEach(Language.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 240)
                .padding(8)
            }

            // 메뉴 막대
            GroupBox(label: Text(settings.tr("grp_menubar")).font(.headline)) {
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(settings.tr("opt_show_menubar"), isOn: $settings.showMenuBarIcon)
                        .toggleStyle(.checkbox)
                    Text(settings.tr("opt_show_menubar_desc"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
                .padding(8)
            }

            // 시스템 알림
            GroupBox(label: Text(settings.tr("grp_notifications")).font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(settings.tr("opt_enable_notifications"), isOn: $settings.enableNotifications)
                        .toggleStyle(.checkbox)
                    Text(settings.tr("opt_enable_notifications_desc"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)

                    HStack {
                        Spacer().frame(width: 12)
                        Button(settings.tr("perm_notif_system_btn")) {
                            openNotificationSettings()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(8)
            }

            // 동작 설정 (우클릭 변환)
            GroupBox(label: Text(settings.tr("grp_behavior")).font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(settings.tr("opt_auto_convert_open_with"), isOn: $settings.autoConvertOnOpenWith)
                        .toggleStyle(.checkbox)
                    Text(settings.tr("opt_auto_convert_open_with_desc"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(settings.tr("qa_title"))
                                .font(.system(size: 12, weight: .medium))
                            Text(QuickActionManager.shared.isInstalled ? settings.tr("qa_status_installed") : settings.tr("qa_status_not_installed"))
                                .font(.system(size: 11))
                                .foregroundColor(QuickActionManager.shared.isInstalled ? .green : .orange)
                        }
                        Spacer()
                        Button(settings.tr("qa_reinstall_btn")) {
                            _ = QuickActionManager.shared.forceReinstall()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.top, 2)
                }
                .padding(8)
            }

            // 시스템 접근 권한
            GroupBox(label: Text(settings.tr("grp_perms")).font(.headline)) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("macOS 시스템 설정 > 파일 및 폴더")
                            .font(.system(size: 12, weight: .medium))
                        Text("앱의 데스크탑, 문서, 다운로드 권한을 관리합니다.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(settings.tr("perm_system_btn")) {
                        openPrivacySettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
            }

            // 소프트웨어 업데이트
            GroupBox(label: HStack(spacing: 6) {
                Text(settings.tr("grp_updates")).font(.headline)
                if updateManager.hasUpdate {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(String(format: settings.tr("update_current_ver"), updateManager.currentVersion))
                                    .font(.system(size: 12, weight: .semibold))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        settings.handleVersionTap()
                                    }

                                if settings.isDeveloperMode {
                                    Text("DEV")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)
                                }
                            }

                            if !settings.devToastMessage.isEmpty {
                                Text(settings.devToastMessage)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.orange)
                            }

                            if updateManager.hasUpdate {
                                Text(String(format: settings.tr("update_available_notice"), updateManager.latestVersion))
                                    .font(.system(size: 11))
                                    .foregroundColor(.green)
                            } else if updateManager.statusMessage == "up_to_date" {
                                Text(settings.tr("update_up_to_date"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            } else if !updateManager.statusMessage.isEmpty {
                                Text(updateManager.statusMessage)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()

                        if updateManager.isChecking {
                            ProgressView()
                                .controlSize(.small)
                        } else if updateManager.hasUpdate {
                            if updateManager.isDownloading {
                                Button(settings.tr("update_cancel_btn")) {
                                    updateManager.cancelDownload()
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            } else {
                                Button(settings.tr("update_now_btn")) {
                                    updateManager.startUpdate()
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        } else {
                            Button(settings.tr("update_check_btn")) {
                                updateManager.checkForUpdates(silent: false, includePrereleases: settings.includePrereleaseUpdates)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }

                    if updateManager.isDownloading {
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressView(value: updateManager.downloadProgress, total: 1.0)
                            Text(updateManager.isUpdating
                                 ? settings.tr("update_installing")
                                 : String(format: settings.tr("update_downloading"), Int(updateManager.downloadProgress * 100)))
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }

                    if updateManager.hasUpdate && !updateManager.releaseNotes.isEmpty {
                        DisclosureGroup(settings.tr("update_release_notes")) {
                            ScrollView {
                                Text(updateManager.releaseNotes)
                                    .font(.system(size: 11))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(6)
                            }
                            .frame(height: 90)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                        }
                        .font(.system(size: 11))
                    }

                    if let error = updateManager.errorMessage {
                        Text(error)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }

                    Divider()

                    Toggle(settings.tr("opt_auto_check_updates"), isOn: $settings.automaticallyCheckForUpdates)
                        .toggleStyle(.checkbox)
                    Text(settings.tr("opt_auto_check_updates_desc"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
                .padding(8)
            }

            // 개발자 옵션 (버전 7회 탭 시 활성화)
            if settings.isDeveloperMode {
                GroupBox(label: HStack(spacing: 6) {
                    Image(systemName: "hammer.fill")
                        .foregroundColor(.orange)
                    Text(settings.tr("dev_mode_title"))
                        .font(.headline)
                        .foregroundColor(.orange)
                }) {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(settings.tr("opt_include_prereleases"), isOn: $settings.includePrereleaseUpdates)
                            .toggleStyle(.checkbox)
                        Text(settings.tr("opt_include_prereleases_desc"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(settings.tr("update_test_simulation_title"))
                                    .font(.system(size: 12, weight: .medium))
                                Text(settings.tr("update_test_simulation_desc"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(settings.tr("update_test_simulation_btn")) {
                                updateManager.checkForUpdates(silent: false, includePrereleases: settings.includePrereleaseUpdates, simulateTest: true)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .disabled(updateManager.isChecking || updateManager.isDownloading)
                        }

                        Divider()

                        HStack {
                            Spacer()
                            Button(settings.tr("dev_mode_hide_btn")) {
                                withAnimation {
                                    settings.isDeveloperMode = false
                                    settings.includePrereleaseUpdates = false
                                    settings.devToastMessage = settings.tr("dev_mode_disabled")
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    settings.devToastMessage = ""
                                }
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                }
            }

            // 오픈소스 라이선스 및 크레딧
            GroupBox(label: Text(settings.language == .ko ? "오픈소스 라이선스 및 크레딧" : "Open Source Licenses & Credits").font(.headline)) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("SDOCX Converter v1.0.0")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Copyright © 2026 FizzyHedgehog. All rights reserved.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(settings.language == .ko ? "기반 오픈소스: squ1dd13/sdocx2pdf (MIT License)" : "Based on squ1dd13/sdocx2pdf (MIT License)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(settings.language == .ko ? "라이선스 전문 보기" : "View License") {
                        settings.showLicenseSheet = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
            }

                }
                .padding(24)
            }
        }
        .frame(width: 520, height: 500)
        .sheet(isPresented: $settings.showLicenseSheet) {
            LicenseSheetView(language: settings.language, onDismiss: {
                settings.showLicenseSheet = false
            })
        }
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = settings.tr("out_choose")
        if panel.runModal() == .OK, let url = panel.url {
            settings.customOutputDir = url.path
        }
    }

    private func openPrivacySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders") {
            NSWorkspace.shared.open(url)
        }
    }

    private func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") {
            NSWorkspace.shared.open(url)
        } else if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - 오픈소스 라이선스 고지 시트
struct LicenseSheetView: View {
    let language: Language
    let onDismiss: () -> Void
    private let licenseContent: String

    init(language: Language, onDismiss: @escaping () -> Void) {
        self.language = language
        self.onDismiss = onDismiss
        if let path = Bundle.main.path(forResource: "LICENSE", ofType: "txt"),
           let text = try? String(contentsOfFile: path, encoding: .utf8) {
            self.licenseContent = text
        } else {
            self.licenseContent = """
            SDOCX Converter
            Copyright (c) 2026 FizzyHedgehog. All rights reserved.

            ================================================================================
            Third-Party Software and Licenses
            ================================================================================

            This application incorporates and is based on sdocx2pdf:
            https://github.com/squ1dd13/sdocx2pdf

            MIT License
            Copyright (c) 2026 squ1dd13/sdocx2pdf

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
            """
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(language == .ko ? "오픈소스 라이선스 고지" : "Open Source License Notice")
                        .font(.headline)
                    Text("SDOCX Converter & squ1dd13/sdocx2pdf")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(language == .ko ? "닫기" : "Close") {
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
            }

            ScrollView {
                Text(licenseContent)
                    .font(.system(size: 11, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )

            HStack {
                Text("Copyright © 2026 FizzyHedgehog. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(language == .ko ? "확인" : "OK") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 560, height: 440)
    }
}
