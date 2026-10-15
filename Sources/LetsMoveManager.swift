import AppKit
import Foundation

// MARK: - LetsMove: Auto-move to /Applications & Auto-eject DMG
final class LetsMoveManager {
    static let shared = LetsMoveManager()

    func checkAndMoveToApplicationsIfNeeded() {
        let currentPath = Bundle.main.bundlePath
        let appName = Bundle.main.bundleURL.lastPathComponent
        let applicationsURL = URL(fileURLWithPath: "/Applications")
        let destinationURL = applicationsURL.appendingPathComponent(appName)

        // 1. 이미 /Applications 또는 ~/Applications 에 설치되어 실행 중이면 건너뜀
        let homeAppDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path
        if currentPath.hasPrefix("/Applications/") || currentPath.hasPrefix(homeAppDir) {
            return
        }

        // 2. 가상 디스크(/Volumes/...) 또는 다운로드(Downloads) 등 임시 경로에서 실행되었는지 확인
        let isRunningFromDiskImage = currentPath.hasPrefix("/Volumes/")
        let isRunningFromDownloads = currentPath.contains("/Downloads/")

        guard isRunningFromDiskImage || isRunningFromDownloads else {
            return
        }

        // 3. 다국어 알림창 (한국어/영어 자동 감지)
        let isKorean = Locale.preferredLanguages.first?.starts(with: "ko") == true
        let alert = NSAlert()
        let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "SDOCX Converter Lite"

        if isKorean {
            alert.messageText = "\(displayName)을(를) 응용 프로그램 폴더로 이동하시겠습니까?"
            alert.informativeText = "응용 프로그램(Applications) 폴더로 이동하면 Mac을 더 깔끔하게 유지할 수 있으며, 설치 가상 디스크(DMG)가 자동으로 정리됩니다."
            alert.addButton(withTitle: "응용 프로그램 폴더로 이동")
            alert.addButton(withTitle: "현재 위치에서 계속 실행")
        } else {
            alert.messageText = "Move \(displayName) to Applications Folder?"
            alert.informativeText = "Moving to the Applications folder keeps your Mac organized and automatically ejects the disk image."
            alert.addButton(withTitle: "Move to Applications Folder")
            alert.addButton(withTitle: "Do Not Move")
        }
        alert.alertStyle = .informational

        NSApplication.shared.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else {
            return // 사용자가 "이동하지 않음" 선택
        }

        // 4. 가상 볼륨 경로 추출 (/Volumes/<DiskName>)
        var volumePath = ""
        if isRunningFromDiskImage {
            let parts = currentPath.components(separatedBy: "/")
            if parts.count >= 3 && parts[1] == "Volumes" {
                volumePath = "/Volumes/" + parts[2]
            }
        }

        let pid = ProcessInfo.processInfo.processIdentifier
        let destPath = destinationURL.path

        // 5. 백그라운드 전환 및 자동 언마운트 스크립트 실행
        let script = """
        # 현재 프로세스가 완전히 종료될 때까지 대기
        while kill -0 \(pid) 2>/dev/null; do
            sleep 0.1
        done

        # 대상 경로에 기존 앱이 있으면 제거 후 새 앱 복사
        rm -rf "\(destPath)" 2>/dev/null
        cp -R "\(currentPath)" "\(destPath)"

        # 확장 속성 정리 및 ad-hoc 코드 서명 갱신
        xattr -cr "\(destPath)" 2>/dev/null
        codesign --force --deep --sign - "\(destPath)" 2>/dev/null

        # 새 위치에서 앱 실행
        open "\(destPath)"

        # 가상 디스크(DMG) 자동 언마운트 (사이드바 및 창 자동 닫힘)
        if [ -n "\(volumePath)" ] && [ -d "\(volumePath)" ]; then
            sleep 0.5
            diskutil unmount force "\(volumePath)" 2>/dev/null || hdiutil detach "\(volumePath)" -force 2>/dev/null
        fi
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", script]
        try? process.run()

        // 6. 현재 프로세스 즉시 종료
        exit(0)
    }
}
