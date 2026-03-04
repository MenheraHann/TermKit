import Foundation
import SwiftUI

/// 片段数据管理中心，负责加载、过滤和搜索命令片段
@MainActor
class SnippetStore: ObservableObject {
    /// 所有已加载的片段
    @Published var allSnippets: [Snippet] = []
    /// 当前搜索关键词
    @Published var searchText: String = ""
    /// 当前选中的分类（nil 表示全部）
    @Published var selectedCategory: String? = nil
    /// 当前选中的片段
    @Published var selectedSnippet: Snippet? = nil

    /// 从所有片段中提取的去重排序分类列表
    var categories: [String] {
        Array(Set(allSnippets.map(\.category))).sorted()
    }

    /// 根据当前搜索条件和分类过滤后的片段列表
    var filteredSnippets: [Snippet] {
        var result = allSnippets.filter(\.enabled)
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query) ||
                $0.tags.contains(where: { $0.lowercased().contains(query) })
            }
        }
        return result
    }

    /// 用户数据文件路径：~/Library/Application Support/TermKit/snippets.json
    private var dataFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("TermKit")
        return dir.appendingPathComponent("snippets.json")
    }

    /// 加载片段数据：优先从用户目录读取，不存在则从 bundle 复制默认文件
    func load() {
        let fm = FileManager.default
        let fileURL = dataFileURL
        let dir = fileURL.deletingLastPathComponent()

        // 如果目录不存在则创建
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        // 如果用户文件不存在，从 bundle 复制默认片段
        if !fm.fileExists(atPath: fileURL.path) {
            if let bundleURL = Bundle.module.url(forResource: "default_snippets", withExtension: "json") {
                try? fm.copyItem(at: bundleURL, to: fileURL)
            }
        }

        // 从用户文件加载，失败则回退到 bundle
        if let data = try? Data(contentsOf: fileURL),
           let file = try? JSONDecoder().decode(SnippetFile.self, from: data) {
            allSnippets = file.snippets
        } else if let bundleURL = Bundle.module.url(forResource: "default_snippets", withExtension: "json"),
                  let data = try? Data(contentsOf: bundleURL),
                  let file = try? JSONDecoder().decode(SnippetFile.self, from: data) {
            allSnippets = file.snippets
        }
    }
}
