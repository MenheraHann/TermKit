import SwiftUI

/// 最近使用片段管理器，记录最近使用的 10 条片段 ID
@MainActor
class RecentManager: ObservableObject {
    /// 最近使用的片段 ID 列表（JSON 字符串存储）
    @AppStorage("recentSnippetIDs") private var recentIDsJSON: String = "[]"

    /// 当前最近使用的 ID 列表（解码后）
    var recentIDs: [String] {
        (try? JSONDecoder().decode([String].self, from: Data(recentIDsJSON.utf8))) ?? []
    }

    /// 记录一条最近使用的片段
    func addRecent(_ snippetID: String) {
        var ids = recentIDs
        ids.removeAll { $0 == snippetID }
        ids.insert(snippetID, at: 0)
        if ids.count > 10 {
            ids = Array(ids.prefix(10))
        }
        if let data = try? JSONEncoder().encode(ids),
           let json = String(data: data, encoding: .utf8) {
            recentIDsJSON = json
            objectWillChange.send()
        }
    }

    /// 从 SnippetStore 中查找最近使用的片段（保持顺序）
    func recentSnippets(from store: SnippetStore) -> [Snippet] {
        let ids = recentIDs
        return ids.compactMap { id in
            store.allSnippets.first { $0.id == id && $0.enabled }
        }
    }
}
