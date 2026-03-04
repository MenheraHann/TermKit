import AppKit

/// 终端类型枚举
enum TerminalType {
    case iTerm2
    case terminal
    case unknown
}

/// 终端操作错误类型
enum TerminalError: Error, LocalizedError {
    /// 未识别的终端应用
    case unknownTerminal
    /// 没有执行权限
    case noPermission
    /// 执行失败，附带具体原因
    case executionFailed(String)

    var errorDescription: String? {
        switch self {
        case .unknownTerminal:
            return "请先切换到 iTerm2 或 Terminal"
        case .noPermission:
            return "没有终端操作权限，请在系统设置中授权"
        case .executionFailed(let reason):
            return "执行失败：\(reason)"
        }
    }
}

/// 终端服务，负责检测当前终端类型并执行命令
enum TerminalService {

    /// 记录面板打开前的终端应用（由 PanelManager 在 toggle 时设置）
    @MainActor static var previousTerminal: TerminalType = .unknown

    // MARK: - 检测终端

    /// 通过前台应用的 bundleIdentifier 判断终端类型
    static func detectFromBundleID(_ bundleID: String?) -> TerminalType {
        guard let bundleID = bundleID else { return .unknown }
        switch bundleID {
        case "com.googlecode.iterm2":
            return .iTerm2
        case "com.apple.Terminal":
            return .terminal
        default:
            return .unknown
        }
    }

    /// 获取当前可用终端：优先用面板打开前记录的终端，否则检查运行中的终端应用
    @MainActor
    static func resolveTerminal() -> TerminalType {
        // 优先使用面板打开前记录的终端
        if previousTerminal != .unknown {
            return previousTerminal
        }
        // 回退：检查是否有终端应用在运行
        let apps = NSWorkspace.shared.runningApplications
        if apps.contains(where: { $0.bundleIdentifier == "com.googlecode.iterm2" }) {
            return .iTerm2
        }
        if apps.contains(where: { $0.bundleIdentifier == "com.apple.Terminal" }) {
            return .terminal
        }
        return .unknown
    }

    // MARK: - 执行命令

    /// 向当前终端发送命令
    @MainActor
    static func executeCommand(_ command: String) -> Result<Void, TerminalError> {
        let terminalType = resolveTerminal()

        switch terminalType {
        case .unknown:
            return .failure(.unknownTerminal)
        case .iTerm2:
            return executeInITerm2(command)
        case .terminal:
            return executeInTerminal(command)
        }
    }

    // MARK: - iTerm2

    /// 通过 AppleScript 在 iTerm2 中执行命令
    private static func executeInITerm2(_ command: String) -> Result<Void, TerminalError> {
        // 先按实际换行符分割，再转义每行
        let lines = command.components(separatedBy: "\n")
        let writeStatements = lines.map { line in
            let escaped = escapeForAppleScript(line)
            return "write text \"\(escaped)\""
        }.joined(separator: "\n")

        let script = """
        tell application "iTerm2"
            activate
            if (count of windows) = 0 then
                create window with default profile
            end if
            tell current session of current window
                \(writeStatements)
            end tell
        end tell
        """

        return runAppleScript(script)
    }

    // MARK: - Terminal.app

    private static func executeInTerminal(_ command: String) -> Result<Void, TerminalError> {
        let escaped = escapeForAppleScript(command)

        let script = """
        tell application "Terminal"
            activate
            if (count of windows) = 0 then
                do script "\(escaped)"
            else
                do script "\(escaped)" in front window
            end if
        end tell
        """

        return runAppleScript(script)
    }

    // MARK: - 辅助方法

    /// 转义命令字符串以安全嵌入 AppleScript 双引号字符串
    private static func escapeForAppleScript(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    /// 执行 AppleScript 字符串
    private static func runAppleScript(_ source: String) -> Result<Void, TerminalError> {
        guard let script = NSAppleScript(source: source) else {
            return .failure(.executionFailed("无法创建 AppleScript"))
        }

        var error: NSDictionary?
        script.executeAndReturnError(&error)

        if let error = error {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int
            let message = error[NSAppleScript.errorMessage] as? String ?? "未知 AppleScript 错误"
            // -1743: 没有自动化授权
            if errorNumber == -1743 {
                return .failure(.noPermission)
            }
            return .failure(.executionFailed(message))
        }

        return .success(())
    }
}
