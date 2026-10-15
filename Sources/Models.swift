import Foundation
import SwiftUI
import AppKit

// MARK: - 다국어 문자열 테이블
enum Language: String, CaseIterable, Identifiable {
    case ko = "ko"
    case en = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ko: return "한국어 (Korean)"
        case .en: return "English"
        }
    }
}

enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    func displayName(for lang: Language) -> String {
        switch self {
        case .system: return lang == .ko ? "시스템 설정 동기화" : "Sync with system"
        case .light: return lang == .ko ? "라이트 모드" : "Light mode"
        case .dark: return lang == .ko ? "다크 모드" : "Dark mode"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum OutputMode: String, CaseIterable, Identifiable {
    case same = "same"
    case custom = "custom"

    var id: String { rawValue }
}

enum SplitOption: String, CaseIterable, Identifiable {
    case none = ""
    case a4Portrait = "iso-portrait"
    case a4Landscape = "iso-landscape"

    var id: String { rawValue }

    func title(for lang: Language) -> String {
        switch self {
        case .none: return lang == .ko ? "기본" : "Default"
        case .a4Portrait: return lang == .ko ? "A4 세로" : "A4 Portrait"
        case .a4Landscape: return lang == .ko ? "A4 가로" : "A4 Landscape"
        }
    }
}

// MARK: - 배치 변환 아이템 모델
enum ItemStatus: Equatable {
    case pending
    case converting
    case success(outputPath: String, thumbnail: NSImage?)
    case failed(message: String)

    var isConverting: Bool {
        if case .converting = self { return true }
        return false
    }

    var isFinished: Bool {
        switch self {
        case .success, .failed: return true
        default: return false
        }
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    static func == (lhs: ItemStatus, rhs: ItemStatus) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending): return true
        case (.converting, .converting): return true
        case let (.success(p1, _), .success(p2, _)): return p1 == p2
        case let (.failed(m1), .failed(m2)): return m1 == m2
        default: return false
        }
    }
}

struct BatchItem: Identifiable, Equatable {
    let id: UUID
    let url: URL
    var status: ItemStatus

    init(id: UUID = UUID(), url: URL, status: ItemStatus = .pending) {
        self.id = id
        self.url = url
        self.status = status
    }

    var fileName: String {
        url.lastPathComponent
    }

    var parentDirectoryName: String {
        url.deletingLastPathComponent().lastPathComponent
    }

    var fileSizeString: String {
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attrs[.size] as? Int64 {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useAll]
            bcf.countStyle = .file
            return bcf.string(fromByteCount: size)
        }
        return ""
    }

    static func == (lhs: BatchItem, rhs: BatchItem) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
}

// MARK: - 영구 설정 관리 (AppSettings)
@MainActor
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var language: Language {
        didSet { defaults.set(language.rawValue, forKey: "ui.language") }
    }

    @Published var theme: ThemeMode {
        didSet { defaults.set(theme.rawValue, forKey: "ui.theme") }
    }

    @Published var outputMode: OutputMode {
        didSet { defaults.set(outputMode.rawValue, forKey: "output.mode") }
    }

    @Published var customOutputDir: String {
        didSet { defaults.set(customOutputDir, forKey: "output.dir") }
    }

    @Published var lastBrowseDir: String {
        didSet { defaults.set(lastBrowseDir, forKey: "ui.lastBrowseDir") }
    }

    @Published var hasRequestedPermissions: Bool {
        didSet { defaults.set(hasRequestedPermissions, forKey: "ui.hasRequestedPermissions") }
    }

    @Published var showMenuBarIcon: Bool {
        didSet {
            defaults.set(showMenuBarIcon, forKey: "ui.showMenuBarIcon")
            MenuBarController.shared.updateVisibility()
        }
    }

    @Published var enableNotifications: Bool {
        didSet { defaults.set(enableNotifications, forKey: "ui.enableNotifications") }
    }

    @Published var autoConvertOnOpenWith: Bool {
        didSet { defaults.set(autoConvertOnOpenWith, forKey: "ui.autoConvertOnOpenWith") }
    }

    @Published var automaticallyCheckForUpdates: Bool {
        didSet { defaults.set(automaticallyCheckForUpdates, forKey: "ui.automaticallyCheckForUpdates") }
    }

    @Published var showLicenseSheet: Bool = false

    init() {
        if let savedLang = defaults.string(forKey: "ui.language"),
           let lang = Language(rawValue: savedLang) {
            self.language = lang
        } else {
            let preferred = Locale.preferredLanguages.first ?? ""
            if preferred.starts(with: "ko") {
                self.language = .ko
            } else {
                self.language = .en
            }
        }

        let savedTheme = defaults.string(forKey: "ui.theme") ?? "system"
        self.theme = ThemeMode(rawValue: savedTheme) ?? .system

        let savedMode = defaults.string(forKey: "output.mode") ?? "same"
        self.outputMode = OutputMode(rawValue: savedMode) ?? .same

        self.customOutputDir = defaults.string(forKey: "output.dir") ?? ""

        let savedBrowse = defaults.string(forKey: "ui.lastBrowseDir") ?? ""
        if !savedBrowse.isEmpty && FileManager.default.fileExists(atPath: savedBrowse) {
            self.lastBrowseDir = savedBrowse
        } else {
            self.lastBrowseDir = FileManager.default.homeDirectoryForCurrentUser.path
        }

        self.hasRequestedPermissions = defaults.bool(forKey: "ui.hasRequestedPermissions")
        self.showMenuBarIcon = defaults.object(forKey: "ui.showMenuBarIcon") as? Bool ?? true
        self.enableNotifications = defaults.object(forKey: "ui.enableNotifications") as? Bool ?? true
        self.autoConvertOnOpenWith = defaults.object(forKey: "ui.autoConvertOnOpenWith") as? Bool ?? true
        self.automaticallyCheckForUpdates = defaults.object(forKey: "ui.automaticallyCheckForUpdates") as? Bool ?? true
    }

    func tr(_ key: String) -> String {
        Strings.get(key, lang: language)
    }
}

// MARK: - 문자열 딕셔너리
struct Strings {
    private static let table: [Language: [String: String]] = [
        .ko: [
            "app_title": "SDOCX → PDF 변환기",
            "drop_prompt": "여기에 .sdocx 파일이나 폴더를\n끌어다 놓으세요",
            "drop_subprompt": "여러 파일이나 폴더를 한 번에 넣을 수 있습니다",
            "drop_loaded": "선택된 파일",
            "browse": "파일 또는 폴더 찾기…",
            "browse_title": "Samsung Notes 파일 또는 폴더 선택",
            "pen_scale": "펜 글씨 두께 배율",
            "marker_scale": "마커 두께 배율",
            "split_mode": "페이지 분할",
            "auto_split": "PDF 페이지 기준 자동 분할",
            "prefs_tooltip": "설정",
            "convert": "PDF로 변환 시작",
            "converting": "PDF로 변환 중…",
            "status_ready": "파일 또는 폴더를 선택하면 변환할 수 있습니다.",
            "status_file_ready": "변환 준비가 완료되었습니다.",
            "status_done": "변환이 완료되었습니다!",
            "reveal": "Finder에서 결과 파일 열기",
            "ok": "확인",
            "prefs_title": "설정",
            "grp_output": "저장 위치",
            "out_same": "원본 파일과 동일한 위치에 저장",
            "out_custom": "지정된 기본 폴더에 저장",
            "out_choose": "폴더 선택…",
            "out_choose_title": "기본 저장 폴더 선택",
            "out_placeholder": "폴더를 선택하세요",
            "grp_theme": "테마 모드",
            "grp_lang": "언어 (Language)",
            "close": "닫기",
            "success_title": "PDF 변환이 완료되었습니다.",
            "error_title": "변환 오류",
            "error_unsupported": ".sdocx 파일만 지원됩니다.",
            "error_backend_missing": "내장 변환 엔진을 찾을 수 없습니다.",
            "error_no_sdocx_found": "선택한 항목에서 .sdocx 파일을 찾을 수 없습니다.",
            "queue_title": "변환 대기열",
            "queue_count": "%d개 파일",
            "add_more": "파일/폴더 추가…",
            "clear_all": "대기열 비우기",
            "batch_progress": "변환 진행 중: %d / %d 완료 (%d%%)",
            "batch_convert_btn": "%d개 파일 일괄 변환 시작",
            "batch_converting_btn": "일괄 변환 중… (%d / %d)",
            "open_output_folder": "결과 폴더 열기",
            "open_file": "결과 보기",
            "cancel": "변환 중지",
            "status_pending": "대기",
            "status_converting": "변환 중…",
            "status_success": "완료",
            "status_failed": "실패",
            "batch_all_completed": "모든 변환이 완료되었습니다! (성공 %d개 / 실패 %d개)",
            "perm_dialog_title": "폴더 접근 권한 안내",
            "perm_dialog_desc": "SDOCX 파일을 읽고 PDF로 저장하기 위해 데스크탑, 문서, 다운로드 폴더 접근 권한이 필요합니다.\n처음 한 번 허용하시면 다음부터는 묻지 않습니다.",
            "perm_grant_btn": "권한 허용하기",
            "perm_skip_btn": "나중에 하기",
            "grp_perms": "시스템 권한",
            "perm_system_btn": "macOS 개인정보 보호 설정 열기",
            "grp_menubar": "메뉴 막대",
            "opt_show_menubar": "메뉴 막대 아이콘 표시",
            "opt_show_menubar_desc": "화면 상단 메뉴 막대에서 앱을 열거나 빠른 파일 변환을 수행할 수 있습니다.",
            "menu_converting_progress": "● 변환 진행 중: %d / %d (%d%%)",
            "menu_current_file": "현재: %@",
            "menu_completed_summary": "✔ 변환 완료 (%d개 성공)",
            "menu_open_app": "앱 열기",
            "menu_quit_app": "앱 종료",
            "grp_notifications": "알림",
            "opt_enable_notifications": "변환 완료 시 시스템 알림 받기",
            "opt_enable_notifications_desc": "백그라운드에서 파일 변환이 완료되었을 때 배너와 소리로 알려줍니다.",
            "perm_notif_system_btn": "macOS 알림 설정 열기",
            "grp_behavior": "동작 설정",
            "opt_auto_convert_open_with": "우클릭 '다음으로 열기'로 실행 시 즉시 자동 변환",
            "opt_auto_convert_open_with_desc": "Finder에서 sdocx 파일을 우클릭하여 앱으로 열었을 때 변환 버튼을 누르지 않아도 즉시 변환을 시작합니다.",
            "qa_title": "Finder 우클릭 빠른 동작 (Quick Action)",
            "qa_status_installed": "시스템에 정상 등록됨 (우클릭 메뉴에서 즉시 변환 가능)",
            "qa_status_not_installed": "빠른 동작이 아직 등록되지 않음",
            "qa_reinstall_btn": "빠른 동작 등록",
            "btn_start_new": "대기열 비우기 (처음으로)",
            "btn_reconvert": "다시 변환",
            "btn_new_conversion": "새 파일 변환하기",
            "btn_cancel": "취소",
            "grp_updates": "소프트웨어 업데이트",
            "update_current_ver": "현재 버전: v%@",
            "update_available_notice": "새로운 v%@ 업데이트가 있습니다!",
            "update_up_to_date": "현재 최신 버전을 사용하고 있습니다.",
            "update_check_btn": "업데이트 확인",
            "update_now_btn": "지금 업데이트",
            "update_cancel_btn": "다운로드 취소",
            "update_downloading": "업데이트 다운로드 중… (%d%%)",
            "update_installing": "새 버전 설치 및 재실행 중…",
            "update_release_notes": "릴리스 노트(업데이트 내역) 보기",
            "opt_auto_check_updates": "앱 실행 시 자동으로 새 버전 확인",
            "opt_auto_check_updates_desc": "체크를 해제하면 수동으로 '업데이트 확인'을 클릭할 때만 확인합니다."
        ],
        .en: [
            "app_title": "SDOCX → PDF Converter",
            "drop_prompt": "Drag & drop .sdocx files or folders here",
            "drop_subprompt": "You can add multiple files or entire folders at once",
            "drop_loaded": "Selected file",
            "browse": "Browse files or folders…",
            "browse_title": "Select Samsung Notes files or folders",
            "pen_scale": "Pen width multiplier",
            "marker_scale": "Marker width multiplier",
            "split_mode": "Page splitting",
            "auto_split": "Auto-split by embedded PDF pages",
            "prefs_tooltip": "Preferences",
            "convert": "Convert to PDF",
            "converting": "Converting to PDF…",
            "status_ready": "Select files or folders to start converting.",
            "status_file_ready": "Ready to convert.",
            "status_done": "Conversion complete!",
            "reveal": "Reveal in Finder",
            "ok": "OK",
            "prefs_title": "Preferences",
            "grp_output": "Save location",
            "out_same": "Save next to the original file",
            "out_custom": "Save to a specified default folder",
            "out_choose": "Choose folder…",
            "out_choose_title": "Choose the default output folder",
            "out_placeholder": "Choose a folder",
            "grp_theme": "Theme",
            "grp_lang": "Language",
            "close": "Close",
            "success_title": "Conversion complete",
            "error_title": "Conversion error",
            "error_unsupported": "Only .sdocx files are supported.",
            "error_backend_missing": "Conversion engine was not found.",
            "error_no_sdocx_found": "No .sdocx files found in selected items.",
            "queue_title": "Conversion Queue",
            "queue_count": "%d files",
            "add_more": "Add files/folders…",
            "clear_all": "Clear queue",
            "batch_progress": "Converting: %d / %d completed (%d%%)",
            "batch_convert_btn": "Convert %d files",
            "batch_converting_btn": "Converting… (%d / %d)",
            "open_output_folder": "Open output folder",
            "open_file": "View result",
            "cancel": "Cancel",
            "status_pending": "Pending",
            "status_converting": "Converting…",
            "status_success": "Done",
            "status_failed": "Failed",
            "batch_all_completed": "All conversions completed! (%d succeeded / %d failed)",
            "perm_dialog_title": "Folder Access Permission",
            "perm_dialog_desc": "Permission to access Desktop, Documents, and Downloads folders is required to read SDOCX files and save PDFs.\nOnce granted, you won't be prompted again.",
            "perm_grant_btn": "Grant Permissions",
            "perm_skip_btn": "Later",
            "grp_perms": "System Permissions",
            "perm_system_btn": "Open macOS Privacy Settings",
            "grp_menubar": "Menu Bar",
            "opt_show_menubar": "Show menu bar icon",
            "opt_show_menubar_desc": "Access quick file conversion and app controls from the macOS menu bar.",
            "menu_converting_progress": "● Converting: %d / %d (%d%%)",
            "menu_current_file": "Current: %@",
            "menu_completed_summary": "✔ Conversion complete (%d succeeded)",
            "menu_open_app": "Open App",
            "menu_quit_app": "Quit",
            "grp_notifications": "Notifications",
            "opt_enable_notifications": "System notification on completion",
            "opt_enable_notifications_desc": "Show banner and sound when conversions finish in background.",
            "perm_notif_system_btn": "Open macOS Notification Settings",
            "grp_behavior": "Behavior Settings",
            "opt_auto_convert_open_with": "Auto-convert immediately when opened via 'Open With'",
            "opt_auto_convert_open_with_desc": "Automatically start conversion when sdocx files are opened with this app from Finder.",
            "qa_title": "Finder Right-Click Quick Action",
            "qa_status_installed": "Installed in system (Quick convert in right-click menu)",
            "qa_status_not_installed": "Quick Action not installed",
            "qa_reinstall_btn": "Register Quick Action",
            "btn_start_new": "Clear Queue (Start Over)",
            "btn_reconvert": "Re-convert",
            "btn_new_conversion": "Convert New File",
            "btn_cancel": "Cancel",
            "grp_updates": "Software Update",
            "update_current_ver": "Current Version: v%@",
            "update_available_notice": "New version v%@ is available!",
            "update_up_to_date": "You are using the latest version.",
            "update_check_btn": "Check for Updates",
            "update_now_btn": "Update Now",
            "update_cancel_btn": "Cancel Download",
            "update_downloading": "Downloading update… (%d%%)",
            "update_installing": "Installing and restarting…",
            "update_release_notes": "View Release Notes",
            "opt_auto_check_updates": "Automatically check for updates on startup",
            "opt_auto_check_updates_desc": "When disabled, updates are only checked when clicking 'Check for Updates'."
        ]

    ]

    static func get(_ key: String, lang: Language) -> String {
        table[lang]?[key] ?? table[.en]?[key] ?? key
    }
}
