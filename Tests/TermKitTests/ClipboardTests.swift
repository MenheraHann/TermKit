import XCTest
import AppKit
@testable import TermKit

final class ClipboardTests: XCTestCase {
    func testCopySingleLine() {
        ClipboardService.copy("hello world")
        XCTAssertEqual(NSPasteboard.general.string(forType: .string), "hello world")
    }

    func testCopyMultiline() {
        let text = "line1\nline2\nline3"
        ClipboardService.copy(text)
        XCTAssertEqual(NSPasteboard.general.string(forType: .string), text)
    }

    func testCopyOverwrites() {
        ClipboardService.copy("first")
        ClipboardService.copy("second")
        XCTAssertEqual(NSPasteboard.general.string(forType: .string), "second")
    }
}
