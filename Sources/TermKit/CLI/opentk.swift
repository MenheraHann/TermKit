import Foundation
import AppKit

/// opentk CLI 入口
/// - TermKit 已运行 → 发通知切换面板
/// - TermKit 未运行 → 启动 TermKit 并显示面板
@main
struct OpenTKCLI {
    static func main() {
        let bundleID = "com.termkit.app"
        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == bundleID
        }

        if isRunning {
            // 已运行：发通知切换面板
            DistributedNotificationCenter.default().post(
                name: Notification.Name("com.termkit.toggle"),
                object: nil
            )
        } else {
            // 未运行：找到 TermKit 并启动
            let termkitPath = findTermKit()
            guard let path = termkitPath else {
                print("❌ 找不到 TermKit，请确认已安装")
                exit(1)
            }
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = ["--show"]
            do {
                try process.run()
                // 等一下让 TermKit 启动，然后发通知显示面板
                Thread.sleep(forTimeInterval: 1.0)
                DistributedNotificationCenter.default().post(
                    name: Notification.Name("com.termkit.toggle"),
                    object: nil
                )
            } catch {
                print("❌ 启动 TermKit 失败：\(error.localizedDescription)")
                exit(1)
            }
        }
    }

    /// 查找 TermKit 可执行文件路径
    static func findTermKit() -> String? {
        let candidates = [
            // 同目录（brew 安装或手动安装时 opentk 和 TermKit 在同一目录）
            URL(fileURLWithPath: CommandLine.arguments[0])
                .deletingLastPathComponent()
                .appendingPathComponent("TermKit").path,
            "/usr/local/bin/TermKit",
            "/opt/homebrew/bin/TermKit",
            // macOS .app bundle
            "/Applications/TermKit.app/Contents/MacOS/TermKit",
            "~/Applications/TermKit.app/Contents/MacOS/TermKit"
        ]
        for path in candidates {
            let expanded = NSString(string: path).expandingTildeInPath
            if FileManager.default.isExecutableFile(atPath: expanded) {
                return expanded
            }
        }
        return nil
    }
}
