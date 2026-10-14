import Foundation
import AppKit
import PDFKit

final class ConverterService {
    static let shared = ConverterService()

    /// 내장 sdocx2pdf 바이너리 경로 검색
    func resolveBackendPath() -> String? {
        // 1. Bundle Resource
        if let path = Bundle.main.path(forResource: "sdocx2pdf-macOS-arm64", ofType: nil) {
            return path
        }
        // 2. Executable 옆
        let execDir = Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS")
        let candidate = execDir.appendingPathComponent("sdocx2pdf-macOS-arm64").path
        if FileManager.default.fileExists(atPath: candidate) {
            return candidate
        }
        return nil
    }

    /// PDF 변환 실행
    func convert(
        input: String,
        output: String,
        penScale: Double,
        markerScale: Double,
        split: SplitOption,
        autoSplit: Bool
    ) async throws {
        guard let backend = resolveBackendPath() else {
            throw NSError(domain: "Converter", code: 1, userInfo: [NSLocalizedDescriptionKey: "내장 엔진을 찾을 수 없습니다."])
        }

        // 실행 권한 확보
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: backend)

        var args = [
            "--pen-width-multiplier", String(format: "%.1f", penScale),
            "--marker-width-multiplier", String(format: "%.1f", markerScale),
            "--detailed-errors"
        ]

        if !split.rawValue.isEmpty {
            args += ["--basic-split", split.rawValue]
        }
        if autoSplit {
            args.append("--auto-split")
        }
        args += [input, output]

        let process = Process()
        process.executableURL = URL(fileURLWithPath: backend)
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let log = String(data: data, encoding: .utf8) ?? "알 수 없는 오류"
            throw NSError(domain: "Converter", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: log])
        }

        if !FileManager.default.fileExists(atPath: output) {
            throw NSError(domain: "Converter", code: 2, userInfo: [NSLocalizedDescriptionKey: "결과 PDF 파일이 생성되지 않았습니다."])
        }
    }

    /// PDFKit을 사용해 첫 페이지를 고해상도 문서 카드 형태의 NSImage로 렌더링
    func generateThumbnail(for pdfPath: String, cardWidth: CGFloat = 80, cardHeight: CGFloat = 104) -> NSImage? {
        guard let doc = PDFDocument(url: URL(fileURLWithPath: pdfPath)),
              let page = doc.page(at: 0) else {
            return nil
        }

        let pageBounds = page.bounds(for: .mediaBox)
        guard pageBounds.width > 0, pageBounds.height > 0 else { return nil }

        let innerW = cardWidth - 8
        let innerH = cardHeight - 8

        let widthRatio = innerW / pageBounds.width
        let heightRatio = innerH / pageBounds.height
        let scale = min(widthRatio, heightRatio)

        let targetW = pageBounds.width * scale
        let targetH = pageBounds.height * scale

        let pageThumb = page.thumbnail(of: CGSize(width: targetW * 2, height: targetH * 2), for: .mediaBox)

        // 종이 문서 카드 프레임 합성
        let canvas = NSImage(size: NSSize(width: cardWidth, height: cardHeight))
        canvas.lockFocus()

        // 1. 흰색 배경 + 라운드 사각형 + 은은한 테두리
        let bgRect = NSRect(x: 1.5, y: 1.5, width: cardWidth - 3, height: cardHeight - 3)
        let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 4, yRadius: 4)
        NSColor.white.setFill()
        bgPath.fill()
        NSColor(calibratedWhite: 0, alpha: 0.2).setStroke()
        bgPath.lineWidth = 1
        bgPath.stroke()

        // 2. 페이지 이미지 중앙 배치
        let drawX = (cardWidth - targetW) / 2.0
        let drawY = (cardHeight - targetH) / 2.0
        pageThumb.draw(in: NSRect(x: drawX, y: drawY, width: targetW, height: targetH))

        canvas.unlockFocus()
        return canvas
    }
}

// MARK: - Finder 빠른 동작 (Quick Action) 자동 연동 관리
final class QuickActionManager {
    static let shared = QuickActionManager()

    private let workflowName = "SDOCX를 PDF로 변환.workflow"

    var servicesDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Services")
    }

    var installedWorkflowURL: URL {
        servicesDirectory.appendingPathComponent(workflowName)
    }

    var isInstalled: Bool {
        FileManager.default.fileExists(atPath: installedWorkflowURL.path)
    }

    func installIfNeeded() {
        guard let bundledURL = Bundle.main.url(forResource: "SDOCX를 PDF로 변환", withExtension: "workflow") else {
            return
        }

        let fm = FileManager.default
        try? fm.createDirectory(at: servicesDirectory, withIntermediateDirectories: true)

        let target = installedWorkflowURL
        if !fm.fileExists(atPath: target.path) {
            try? fm.copyItem(at: bundledURL, to: target)
            refreshServices()
        }
    }

    func forceReinstall() -> Bool {
        guard let bundledURL = Bundle.main.url(forResource: "SDOCX를 PDF로 변환", withExtension: "workflow") else {
            return false
        }
        let fm = FileManager.default
        let target = installedWorkflowURL
        try? fm.createDirectory(at: servicesDirectory, withIntermediateDirectories: true)
        try? fm.removeItem(at: target)
        do {
            try fm.copyItem(at: bundledURL, to: target)
            refreshServices()
            return true
        } catch {
            return false
        }
    }

    func uninstall() {
        let fm = FileManager.default
        if fm.fileExists(atPath: installedWorkflowURL.path) {
            try? fm.removeItem(at: installedWorkflowURL)
            refreshServices()
        }
    }

    private func refreshServices() {
        DispatchQueue.global(qos: .utility).async {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/System/Library/CoreServices/pbs")
            proc.arguments = ["-update"]
            try? proc.run()
            proc.waitUntilExit()

            let proc2 = Process()
            proc2.executableURL = URL(fileURLWithPath: "/System/Library/CoreServices/pbs")
            proc2.arguments = ["-flush"]
            try? proc2.run()
        }
    }
}

