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
    let category: String
    let tags: [String]
    let command: String
    let variables: [SnippetVariable]?
    let dangerLevel: DangerLevel
    let enabled: Bool
}

/// 片段文件的顶层结构
struct SnippetFile: Codable {
    let version: Int
    let snippets: [Snippet]
}
