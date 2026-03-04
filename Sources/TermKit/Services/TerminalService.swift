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

    // MARK: - 检测终端

    /// 通过前台应用的 bundleIdentifier 判断当前终端类型
    static func detectTerminal() -> TerminalType {
        guard let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else {
            print("[TermKit] TerminalService.detectTerminal() - 无法获取前台应用 bundleID")
            return .unknown
        }
        print("[TermKit] TerminalService.detectTerminal() - 前台应用: \(bundleID)")

        switch bundleID {
        case "com.googlecode.iterm2":
            return .iTerm2
        case "com.apple.Terminal":
            return .terminal
        default:
            return .unknown
        }
    }

    // MARK: - 执行命令

    /// 向当前终端发送命令
    /// - Parameter command: 要执行的命令字符串
    /// - Returns: 成功或包含错误的 Result
    static func executeCommand(_ command: String) -> Result<Void, TerminalError> {
        let terminalType = detectTerminal()

        switch terminalType {
        case .unknown:
            print("[TermKit] TerminalService.executeCommand() - 未识别终端")
            return .failure(.unknownTerminal)

        case .iTerm2:
            return executeInITerm2(command)

        case .terminal:
            return executeInTerminal(command)
        }
    }

    // MARK: - iTerm2

    /// 通过 AppleScript 在 iTerm2 中执行命令
    /// - 多行命令按 \n 分割，逐行发送 write text
    private static func executeInITerm2(_ command: String) -> Result<Void, TerminalError> {
        let escaped = escapeForAppleScript(command)
        let lines = escaped.components(separatedBy: "\\n")

        // 逐行构建 write text 语句
        let writeStatements = lines.map { line in
            "write text \"\(line)\""
        }.joined(separator: "\n")

        let script = """
        tell application "iTerm2"
            tell current session of current window
                \(writeStatements)
            end tell
        end tell
        """

        print("[TermKit] TerminalService - 发送到 iTerm2:\n\(script)")
        return runAppleScript(script)
    }

    // MARK: - Terminal.app

    /// 通过 AppleScript 在 Terminal.app 中执行命令
    private static func executeInTerminal(_ command: String) -> Result<Void, TerminalError> {
        let escaped = escapeForAppleScript(command)

        let script = """
        tell application "Terminal"
            do script "\(escaped)" in front window
        end tell
        """

        print("[TermKit] TerminalService - 发送到 Terminal.app:\n\(script)")
        return runAppleScript(script)
    }

    // MARK: - 辅助方法

    /// 转义命令字符串以安全嵌入 AppleScript 双引号字符串
    /// - 反斜杠 → \\\\，双引号 → \\"
    private static func escapeForAppleScript(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    /// 执行 AppleScript 字符串，返回结果
    private static func runAppleScript(_ source: String) -> Result<Void, TerminalError> {
        guard let script = NSAppleScript(source: source) else {
            return .failure(.executionFailed("无法创建 AppleScript"))
        }

        var error: NSDictionary?
        script.executeAndReturnError(&error)

        if let error = error {
            let message = error[NSAppleScript.errorMessage] as? String ?? "未知 AppleScript 错误"
            print("[TermKit] AppleScript 错误: \(message)")
            return .failure(.executionFailed(message))
        }

        print("[TermKit] AppleScript 执行成功")
        return .success(())
    }
}
