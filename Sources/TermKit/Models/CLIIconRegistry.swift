import Foundation

/// 品牌图标注册表：CLI 名称 → PNG 文件名映射
enum CLIIconRegistry {
    /// CLI 名称到品牌图标文件名的映射（不含扩展名）
    private static let mapping: [String: String] = [
        "Claude Code": "claude",
        "OpenAI Codex": "openai",
        "Gemini CLI": "gemini",
        "OpenCode": "opencode-logo-light",
        "OpenClaw": "openclaw",
        "GitHub Copilot CLI": "githubcopilot",
    ]

    /// 根据 CLI 名称返回对应的品牌图标文件名，无对应图标返回 nil
    static func iconName(for cliName: String) -> String? {
        mapping[cliName]
    }

    /// 返回 Resources/CLIIcons/ 中所有可用的 PNG 文件名（不含扩展名），供 IconPicker 使用
    static var allBrandIcons: [String] {
        guard let resourceURL = Bundle.main.resourceURL else { return [] }
        let iconsDir = resourceURL.appendingPathComponent("CLIIcons")
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: iconsDir,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else { return [] }

        return contents
            .filter { $0.pathExtension.lowercased() == "png" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }
}
