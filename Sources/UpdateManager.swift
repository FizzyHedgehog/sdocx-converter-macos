import Foundation
import AppKit

@MainActor
final class UpdateManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    static let shared = UpdateManager()

    @Published var isChecking: Bool = false
    @Published var hasUpdate: Bool = false
    @Published var latestVersion: String = ""
    @Published var releaseNotes: String = ""
    @Published var releaseURL: String = ""
    @Published var downloadURL: String = ""
    @Published var downloadSize: Int64 = 0

    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double = 0.0
    @Published var isUpdating: Bool = false
    @Published var statusMessage: String = ""
    @Published var errorMessage: String? = nil

    private var downloadTask: URLSessionDownloadTask?
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }()

    override private init() {
        super.init()
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    func checkForUpdates(silent: Bool = false) {
        guard !isChecking, !isDownloading else { return }
        isChecking = true
        if !silent {
            statusMessage = ""
            errorMessage = nil
        }

        guard let url = URL(string: "https://api.github.com/repos/FizzyHedgehog/sdocx-converter-macos/releases/latest") else {
            isChecking = false
            return
        }

        var req = URLRequest(url: url)
        req.setValue("SDOCX-Converter-App", forHTTPHeaderField: "User-Agent")
        req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        // Read github token if available to prevent API rate limits
        let tokenPath = ("~/.config/github_token.txt" as NSString).expandingTildeInPath
        if let token = try? String(contentsOfFile: tokenPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.isChecking = false

                if let error = error {
                    if !silent {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard let data = data else {
                    if !silent {
                        self.errorMessage = "No response from server"
                    }
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let tag = json["tag_name"] as? String {
                            let remoteVer = tag.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
                            let localVer = self.currentVersion.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))

                            self.latestVersion = remoteVer
                            self.releaseNotes = json["body"] as? String ?? ""
                            self.releaseURL = json["html_url"] as? String ?? ""

                            // Look for DMG asset
                            if let assets = json["assets"] as? [[String: Any]] {
                                for asset in assets {
                                    if let name = asset["name"] as? String, name.lowercased().hasSuffix(".dmg"),
                                       let dl = asset["browser_download_url"] as? String {
                                        self.downloadURL = dl
                                        self.downloadSize = (asset["size"] as? Int64) ?? 0
                                        break
                                    }
                                }
                            }

                            if self.isRemoteNewer(remote: remoteVer, local: localVer) {
                                self.hasUpdate = true
                                self.statusMessage = "v\(remoteVer)"
                            } else {
                                self.hasUpdate = false
                                if !silent {
                                    self.statusMessage = "up_to_date"
                                }
                            }
                        } else if let msg = json["message"] as? String, !silent {
                            self.errorMessage = msg
                        }
                    }
                } catch {
                    if !silent {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }.resume()
    }

    func isRemoteNewer(remote: String, local: String) -> Bool {
        let rParts = remote.split(separator: ".").compactMap { Int($0) }
        let lParts = local.split(separator: ".").compactMap { Int($0) }
        let count = max(rParts.count, lParts.count)
        for i in 0..<count {
            let r = i < rParts.count ? rParts[i] : 0
            let l = i < lParts.count ? lParts[i] : 0
            if r > l { return true }
            if r < l { return false }
        }
        return false
    }

    func startUpdate() {
        guard let url = URL(string: downloadURL), !isDownloading else {
            if let relURL = URL(string: releaseURL) {
                NSWorkspace.shared.open(relURL)
            }
            return
        }

        isDownloading = true
        downloadProgress = 0.0
        errorMessage = nil

        let task = urlSession.downloadTask(with: url)
        self.downloadTask = task
        task.resume()
    }

    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        isDownloading = false
        downloadProgress = 0.0
    }

    // MARK: - URLSessionDownloadDelegate
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = totalBytesExpectedToWrite > 0 ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : 0.0
        Task { @MainActor in
            self.downloadProgress = progress
        }
    }

    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            Task { @MainActor in
                self.isDownloading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let tempDMG = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sdocx_update_\(UUID().uuidString).dmg")
        do {
            if FileManager.default.fileExists(atPath: tempDMG.path) {
                try FileManager.default.removeItem(at: tempDMG)
            }
            try FileManager.default.copyItem(at: location, to: tempDMG)

            Task { @MainActor in
                self.applyUpdate(dmgURL: tempDMG)
            }
        } catch {
            Task { @MainActor in
                self.isDownloading = false
                self.errorMessage = "Failed to prepare update: \(error.localizedDescription)"
            }
        }
    }

    private func applyUpdate(dmgURL: URL) {
        isUpdating = true

        var targetAppPath = Bundle.main.bundlePath
        if !targetAppPath.hasPrefix("/Applications") && FileManager.default.fileExists(atPath: "/Applications/SDOCX Converter.app") {
            targetAppPath = "/Applications/SDOCX Converter.app"
        }

        let pid = ProcessInfo.processInfo.processIdentifier
        let scriptPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("sdocx_updater.sh")
        let scriptContent = """
        #!/bin/bash
        set -e

        APP_PID="\(pid)"
        TARGET_APP="\(targetAppPath)"
        DMG_FILE="\(dmgURL.path)"

        # Wait for the current running application to exit
        for i in {1..40}; do
            if ! kill -0 "$APP_PID" 2>/dev/null; then
                break
            fi
            sleep 0.25
        done

        # Create temporary mount point
        MOUNT_DIR=$(mktemp -d /tmp/sdocx_update_mount_XXXXXX)
        hdiutil attach "$DMG_FILE" -nobrowse -readonly -mountpoint "$MOUNT_DIR" -quiet

        SOURCE_APP=$(find "$MOUNT_DIR" -maxdepth 1 -name "*.app" | head -n 1)

        if [ -n "$SOURCE_APP" ] && [ -d "$SOURCE_APP" ]; then
            # Replace target app with newly downloaded version
            rm -rf "$TARGET_APP"
            cp -R "$SOURCE_APP" "$TARGET_APP"

            # CRITICAL: Strip Gatekeeper quarantine attribute completely so no security prompt appears
            xattr -cr "$TARGET_APP" 2>/dev/null || true
        fi

        # Detach and clean up
        hdiutil detach "$MOUNT_DIR" -quiet -force 2>/dev/null || true
        rm -rf "$MOUNT_DIR" "$DMG_FILE"

        # Relaunch the new application
        open "$TARGET_APP"
        """

        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            let chmodProcess = Process()
            chmodProcess.executableURL = URL(fileURLWithPath: "/bin/chmod")
            chmodProcess.arguments = ["+x", scriptPath]
            try chmodProcess.run()
            chmodProcess.waitUntilExit()

            let updateProcess = Process()
            updateProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
            updateProcess.arguments = [scriptPath]
            try updateProcess.run()

            NSApplication.shared.terminate(nil)
        } catch {
            isUpdating = false
            isDownloading = false
            errorMessage = "Failed to launch updater: \(error.localizedDescription)"
        }
    }
}
