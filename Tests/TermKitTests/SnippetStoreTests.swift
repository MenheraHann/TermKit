import XCTest
@testable import TermKit

@MainActor
final class SnippetStoreTests: XCTestCase {
    func testFilterByCategory() {
        let store = SnippetStore()
        store.allSnippets = makeSampleSnippets()
        store.selectedCategory = "Debug"
        XCTAssertTrue(store.filteredSnippets.allSatisfy { $0.category == "Debug" })
        XCTAssertFalse(store.filteredSnippets.isEmpty)
    }

    func testSearchByTitle() {
        let store = SnippetStore()
        store.allSnippets = makeSampleSnippets()
        store.searchText = "端口"
        XCTAssertTrue(store.filteredSnippets.contains(where: { $0.id == "port_lsof" }))
    }

    func testSearchByTag() {
        let store = SnippetStore()
        store.allSnippets = makeSampleSnippets()
        store.searchText = "docker"
        XCTAssertTrue(store.filteredSnippets.contains(where: { $0.id == "docker_ps" }))
    }

    func testDisabledSnippetsHidden() {
        let store = SnippetStore()
        var snippets = makeSampleSnippets()
        snippets[0] = Snippet(
            id: snippets[0].id,
            title: snippets[0].title,
            description: snippets[0].description,
            category: snippets[0].category,
            tags: snippets[0].tags,
            command: snippets[0].command,
            variables: snippets[0].variables,
            dangerLevel: snippets[0].dangerLevel,
            enabled: false
        )
        store.allSnippets = snippets
        XCTAssertFalse(store.filteredSnippets.contains(where: { $0.id == snippets[0].id }))
    }

    func testCategories() {
        let store = SnippetStore()
        store.allSnippets = makeSampleSnippets()
        let cats = store.categories
        XCTAssertTrue(cats.contains("Debug"))
        XCTAssertTrue(cats.contains("Git"))
    }

    func testEmptySearch() {
        let store = SnippetStore()
        store.allSnippets = makeSampleSnippets()
        store.searchText = ""
        XCTAssertEqual(store.filteredSnippets.count, store.allSnippets.filter(\.enabled).count)
    }

    private func makeSampleSnippets() -> [Snippet] {
        [
            Snippet(id: "port_lsof", title: "查看端口占用", description: "lsof 查询",
                    category: "Debug", tags: ["port", "lsof"], command: "lsof -i :3000",
                    variables: nil, dangerLevel: .safe, enabled: true),
            Snippet(id: "git_status", title: "Git 状态", description: "查看状态",
                    category: "Git", tags: ["git"], command: "git status -sb",
                    variables: nil, dangerLevel: .safe, enabled: true),
            Snippet(id: "docker_ps", title: "容器列表", description: "列出容器",
                    category: "Docker", tags: ["docker", "ps"], command: "docker ps -a",
                    variables: nil, dangerLevel: .safe, enabled: true),
        ]
    }
}
