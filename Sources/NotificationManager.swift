import Foundation
import UserNotifications
import AppKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                NSLog("[NotificationManager] requestAuthorization failed: %@", error.localizedDescription)
            }
        }
    }

    func sendConversionCompletedNotification(
        successCount: Int,
        failCount: Int,
        totalCount: Int,
        singleFileName: String?
    ) {
        let content = UNMutableNotificationContent()
        content.title = "SDOCX Converter"
        content.sound = .default

        if let iconURL = Bundle.main.url(forResource: "notification_icon", withExtension: "png"),
           let attachment = try? UNNotificationAttachment(identifier: "app_logo", url: iconURL, options: nil) {
            content.attachments = [attachment]
        }

        let isKorean = (UserDefaults.standard.string(forKey: "ui.language") ?? Locale.preferredLanguages.first ?? "").starts(with: "ko")

        if totalCount == 1 {
            let name = singleFileName ?? (isKorean ? "문서" : "document")
            if successCount > 0 {
                content.body = isKorean
                    ? "'\(name)' 변환이 성공적으로 완료되었습니다."
                    : "Successfully converted '\(name)'."
            } else {
                content.body = isKorean
                    ? "'\(name)' 변환에 실패했습니다."
                    : "Failed to convert '\(name)'."
            }
        } else {
            if failCount == 0 {
                content.body = isKorean
                    ? "총 \(totalCount)개 파일의 PDF 변환이 완료되었습니다."
                    : "Successfully converted all \(totalCount) files to PDF."
            } else {
                content.body = isKorean
                    ? "총 \(totalCount)개 파일 중 \(successCount)개 변환 완료 (\(failCount)개 실패)"
                    : "\(successCount) of \(totalCount) files converted (\(failCount) failed)."
            }
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 즉시 알림 발송
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("[NotificationManager] add request failed: %@", error.localizedDescription)
            }
        }
    }

    // 앱이 전면(포그라운드)에 있어도 상단 배너 및 사운드 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    // 사용자가 배너를 클릭했을 때 앱 창 전면 활성화
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
        completionHandler()
    }
}
