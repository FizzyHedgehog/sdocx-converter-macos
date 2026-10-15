import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private weak var settings: AppSettings?
    private weak var viewModel: ConverterViewModel?
    private let menu = NSMenu()

    func setup(settings: AppSettings, viewModel: ConverterViewModel) {
        self.settings = settings
        self.viewModel = viewModel
        self.menu.delegate = self
        updateVisibility()
    }

    func updateVisibility() {
        guard let settings = settings else { return }
        if settings.showMenuBarIcon {
            if statusItem == nil {
                createStatusItem()
            }
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }

    private func createStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = loadMenuBarIcon()
            button.imagePosition = .imageOnly
            button.toolTip = "SDOCX Converter"
        }

        item.menu = menu
        self.statusItem = item
        rebuildMenu()
    }

    // MARK: - NSMenuDelegate (메뉴 클릭 직전 동적 갱신)
    nonisolated func menuWillOpen(_ menu: NSMenu) {
        Task { @MainActor in
            self.rebuildMenu()
        }
    }

    private func rebuildMenu() {
        menu.removeAllItems()
        guard let settings = settings, let vm = viewModel else { return }

        // 1. [최상단] 변환 진행 중 상태 표시 (진행 중일 때 최우선 노출)
        if vm.isConverting {
            let total = vm.items.count
            let finished = vm.items.filter { $0.status.isFinished }.count
            let current = min(finished + 1, max(total, 1))
            let pct = total > 0 ? Int((Double(finished) / Double(total)) * 100) : 0

            let progressTitle = String(format: settings.tr("menu_converting_progress"), current, total, pct)
            let progressItem = NSMenuItem(title: progressTitle, action: nil, keyEquivalent: "")
            progressItem.isEnabled = false
            menu.addItem(progressItem)

            if let convertingItem = vm.items.first(where: { $0.status.isConverting }) {
                let fileTitle = String(format: settings.tr("menu_current_file"), convertingItem.fileName)
                let fileItem = NSMenuItem(title: fileTitle, action: nil, keyEquivalent: "")
                fileItem.isEnabled = false
                fileItem.indentationLevel = 1
                menu.addItem(fileItem)
            }

            menu.addItem(NSMenuItem.separator())
        } else {
            let successCount = vm.items.filter { $0.status.isSuccess }.count
            if successCount > 0 {
                let compTitle = String(format: settings.tr("menu_completed_summary"), successCount)
                let compItem = NSMenuItem(title: compTitle, action: nil, keyEquivalent: "")
                compItem.isEnabled = false
                menu.addItem(compItem)
                menu.addItem(NSMenuItem.separator())
            }
        }

        // 2. 앱 열기 (창을 띄우는 유일한 메뉴 항목)
        let openItem = NSMenuItem(
            title: settings.tr("menu_open_app"),
            action: #selector(handleOpenApp),
            keyEquivalent: "o"
        )
        openItem.target = self
        menu.addItem(openItem)

        // 3. 설정…
        let prefsTitle = UpdateManager.shared.hasUpdate
            ? settings.tr("prefs_title") + "… (●)"
            : settings.tr("prefs_title") + "…"
        let prefsItem = NSMenuItem(
            title: prefsTitle,
            action: #selector(handleOpenPreferences),
            keyEquivalent: ","
        )
        prefsItem.target = self
        menu.addItem(prefsItem)

        // 4. 오픈소스 정보 및 라이선스
        let aboutItem = NSMenuItem(
            title: settings.language == .ko ? "오픈소스 정보 및 라이선스…" : "About & Open Source…",
            action: #selector(handleOpenAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // 5. 앱 종료
        let quitItem = NSMenuItem(
            title: settings.tr("menu_quit_app"),
            action: #selector(handleQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc private func handleOpenAbout() {
        handleOpenApp()
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

    private func loadMenuBarIcon() -> NSImage {
        let size: CGFloat = 18.0
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            let s = size / 18.0
            ctx.setFillColor(NSColor.black.cgColor)

            // 1. 메인 노트 문서 벡터 패스
            let pagePath = CGMutablePath()
            let leftX: CGFloat = 2.2 * s
            let rightX: CGFloat = 15.8 * s
            let bottomY: CGFloat = 2.2 * s
            let topY: CGFloat = 15.8 * s
            let cornerR: CGFloat = 2.0 * s

            // 시작점: 좌측 상단 (바인더 구멍 위쪽)
            pagePath.move(to: CGPoint(x: leftX, y: 14.0 * s))
            // 좌측 상단 모서리 라운드
            pagePath.addArc(tangent1End: CGPoint(x: leftX, y: topY),
                            tangent2End: CGPoint(x: leftX + cornerR, y: topY),
                            radius: cornerR)
            // 상단 모서리
            pagePath.addLine(to: CGPoint(x: rightX - cornerR, y: topY))
            // 우측 상단 모서리 라운드
            pagePath.addArc(tangent1End: CGPoint(x: rightX, y: topY),
                            tangent2End: CGPoint(x: rightX, y: topY - cornerR),
                            radius: cornerR)

            // 우측 모서리 (접힘 시작점까지)
            let foldY: CGFloat = 7.0 * s
            let foldX: CGFloat = 11.0 * s
            pagePath.addLine(to: CGPoint(x: rightX, y: foldY))

            // 접힌 부위 안쪽 곡선 (하단 접힘 지점으로 연결)
            pagePath.addQuadCurve(to: CGPoint(x: foldX, y: bottomY),
                                  control: CGPoint(x: 11.8 * s, y: 6.2 * s))

            // 하단 모서리 (좌측 하단으로 연결)
            pagePath.addLine(to: CGPoint(x: leftX + cornerR, y: bottomY))
            // 좌측 하단 모서리 라운드
            pagePath.addArc(tangent1End: CGPoint(x: leftX, y: bottomY),
                            tangent2End: CGPoint(x: leftX, y: bottomY + cornerR),
                            radius: cornerR)

            // 좌측 바인더 구멍 3개 (아래부터 위로)
            let holeRadius: CGFloat = 1.35 * s
            let holeCenters: [CGFloat] = [5.2 * s, 9.0 * s, 12.8 * s]
            for center in holeCenters {
                pagePath.addLine(to: CGPoint(x: leftX, y: center - holeRadius))
                pagePath.addArc(center: CGPoint(x: leftX, y: center),
                                radius: holeRadius,
                                startAngle: -.pi / 2,
                                endAngle: .pi / 2,
                                clockwise: false)
            }

            pagePath.addLine(to: CGPoint(x: leftX, y: 14.0 * s))
            pagePath.closeSubpath()

            ctx.addPath(pagePath)
            ctx.fillPath()

            // 2. 우측 하단 접힌 날개(Flap) 벡터 패스
            let flapGap: CGFloat = 0.8 * s
            let flapPath = CGMutablePath()
            flapPath.move(to: CGPoint(x: foldX + flapGap, y: bottomY))
            flapPath.addLine(to: CGPoint(x: rightX, y: foldY - flapGap))
            flapPath.addQuadCurve(to: CGPoint(x: foldX + flapGap, y: bottomY),
                                  control: CGPoint(x: 12.5 * s, y: 5.5 * s))
            flapPath.closeSubpath()

            ctx.addPath(flapPath)
            ctx.fillPath()

            return true
        }
        image.isTemplate = true
        return image
    }

    @objc private func handleOpenApp() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func handleOpenPreferences() {
        handleOpenApp()
        viewModel?.showPreferences = true
    }

    @objc private func handleQuit() {
        NSApp.terminate(nil)
    }
}
