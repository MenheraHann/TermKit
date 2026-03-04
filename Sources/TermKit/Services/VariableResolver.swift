import Foundation

/// 变量替换服务：解析命令中的 {KEY} 占位符并替换为用户输入值
enum VariableResolver {

    /// 将命令中的 {KEY} 替换为实际值
    /// - Parameters:
    ///   - command: 包含 {KEY} 占位符的命令模板
    ///   - variables: 片段定义的变量列表（含默认值）
    ///   - values: 用户输入的变量值字典
    /// - Returns: 替换后的最终命令
    static func resolveCommand(
        _ command: String,
        variables: [SnippetVariable]?,
        values: [String: String]
    ) -> String {
        let keys = extractVariableKeys(from: command)
        guard !keys.isEmpty else { return command }

        // 构建 key → default 映射
        var defaults: [String: String] = [:]
        for v in variables ?? [] {
            if let d = v.default {
                defaults[v.key] = d
            }
        }

        var result = command
        for key in keys {
            let placeholder = "{\(key)}"
            // 优先用用户输入值，其次用 default，都没有则保留原文
            if let value = values[key], !value.isEmpty {
                result = result.replacingOccurrences(of: placeholder, with: value)
            } else if let fallback = defaults[key] {
                result = result.replacingOccurrences(of: placeholder, with: fallback)
            }
            // 都没有则保留 {KEY} 原文
        }
        return result
    }

    /// 缓存正则：匹配 {KEY} 占位符（大写字母/下划线开头，可含数字）
    // swiftlint:disable:next force_try
    private static let variableRegex = try! NSRegularExpression(pattern: "\\{([A-Z_][A-Z0-9_]*)\\}")

    /// 用正则提取命令中所有 {KEY} 的 KEY 名称（去重，保持顺序）
    static func extractVariableKeys(from command: String) -> [String] {
        let range = NSRange(command.startIndex..., in: command)
        let matches = variableRegex.matches(in: command, range: range)

        var seen = Set<String>()
        var keys: [String] = []
        for match in matches {
            if let keyRange = Range(match.range(at: 1), in: command) {
                let key = String(command[keyRange])
                if seen.insert(key).inserted {
                    keys.append(key)
                }
            }
        }
        return keys
    }
}
