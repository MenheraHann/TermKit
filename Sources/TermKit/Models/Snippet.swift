import Foundation

/// 命令片段的危险等级
enum DangerLevel: String, Codable, CaseIterable {
    case safe, caution, danger
}

/// 命令中的可替换变量
struct SnippetVariable: Codable, Identifiable, Hashable {
    var id: String { key }
    let key: String
    let label: String
    let `default`: String?
}

/// 单条命令片段
struct Snippet: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    /// 一级分类：所属工具（Claude Code, Codex, Gemini CLI, Aider, OpenClaw, OpenCode, GitHub Copilot CLI, 通用）
    let tool: String
    /// 二级分类：功能类别（常用命令, 配置, 调试, 项目管理, 插件&扩展）
    let category: String
    let tags: [String]
    let command: String
    let variables: [SnippetVariable]?
    let dangerLevel: DangerLevel
    let enabled: Bool

    /// 兼容 v1 片段文件（无 tool 字段），默认归入"通用"
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        tool = try container.decodeIfPresent(String.self, forKey: .tool) ?? "通用"
        category = try container.decode(String.self, forKey: .category)
        tags = try container.decode([String].self, forKey: .tags)
        command = try container.decode(String.self, forKey: .command)
        variables = try container.decodeIfPresent([SnippetVariable].self, forKey: .variables)
        dangerLevel = try container.decode(DangerLevel.self, forKey: .dangerLevel)
        enabled = try container.decode(Bool.self, forKey: .enabled)
    }
}

/// 片段文件的顶层结构
struct SnippetFile: Codable {
    let version: Int
    let snippets: [Snippet]
}
