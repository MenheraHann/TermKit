import XCTest
@testable import TermKit

final class SnippetTests: XCTestCase {
    func testDecodeSnippet() throws {
        let json = """
        {
            "id": "port_lsof",
            "title": "查看端口占用",
            "description": "lsof 查询端口占用进程",
            "category": "Debug",
            "tags": ["port", "lsof", "debug"],
            "command": "lsof -i :{PORT}",
            "variables": [{"key": "PORT", "label": "端口号", "default": "3000"}],
            "dangerLevel": "safe",
            "enabled": true
        }
        """.data(using: .utf8)!
        let snippet = try JSONDecoder().decode(Snippet.self, from: json)
        XCTAssertEqual(snippet.id, "port_lsof")
        XCTAssertEqual(snippet.title, "查看端口占用")
        XCTAssertEqual(snippet.category, "Debug")
        XCTAssertEqual(snippet.tags, ["port", "lsof", "debug"])
        XCTAssertEqual(snippet.variables?.first?.key, "PORT")
        XCTAssertEqual(snippet.variables?.first?.default, "3000")
        XCTAssertEqual(snippet.dangerLevel, .safe)
        XCTAssertTrue(snippet.enabled)
    }

    func testDecodeSnippetFile() throws {
        let json = """
        {"version": 1, "snippets": []}
        """.data(using: .utf8)!
        let file = try JSONDecoder().decode(SnippetFile.self, from: json)
        XCTAssertEqual(file.version, 1)
        XCTAssertTrue(file.snippets.isEmpty)
    }

    func testDecodeNullVariables() throws {
        let json = """
        {
            "id": "git_status",
            "title": "Git 状态",
            "description": "查看状态",
            "category": "Git",
            "tags": ["git"],
            "command": "git status -sb",
            "variables": null,
            "dangerLevel": "safe",
            "enabled": true
        }
        """.data(using: .utf8)!
        let snippet = try JSONDecoder().decode(Snippet.self, from: json)
        XCTAssertNil(snippet.variables)
    }

    func testDangerLevels() throws {
        for level in ["safe", "caution", "danger"] {
            let json = """
            {
                "id": "test",
                "title": "Test",
                "description": "Test",
                "category": "Test",
                "tags": [],
                "command": "echo test",
                "variables": null,
                "dangerLevel": "\(level)",
                "enabled": true
            }
            """.data(using: .utf8)!
            let snippet = try JSONDecoder().decode(Snippet.self, from: json)
            XCTAssertEqual(snippet.dangerLevel.rawValue, level)
        }
    }
}
