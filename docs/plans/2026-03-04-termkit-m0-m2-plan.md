# TermKit M0-M2 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS floating panel app that lets users search, browse, and copy command snippets via global hotkey.

**Architecture:** SwiftUI macOS app with NSPanel floating window, menu bar presence (no Dock icon), local JSON snippet storage. Observable data layer with in-memory search.

**Tech Stack:** Swift 5.9+, SwiftUI, AppKit (NSPanel, NSEvent, NSPasteboard), macOS 13+

---

### Task 1: Create Xcode Project

**Files:**
- Create: Xcode project `TermKit` (macOS App, SwiftUI)
- Modify: `TermKit/Info.plist` — set LSUIElement=YES (menu bar only, no Dock icon)

**Step 1: Create project via xcodebuild**

Use `swift package init` won't work for macOS App. Create project structure manually:

```
TermKit/
├── TermKit.xcodeproj/
├── TermKit/
│   ├── TermKitApp.swift
│   ├── ContentView.swift
│   ├── Info.plist
│   ├── Assets.xcassets/
│   └── TermKit.entitlements
└── TermKitTests/
    └── TermKitTests.swift
```

**Step 2: Verify project builds**

Run: `cd /Users/menherahan/Documents/Develop/TermKit && xcodebuild -project TermKit.xcodeproj -scheme TermKit build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: create Xcode project skeleton"
```

---

### Task 2: Data Model — Snippet

**Files:**
- Create: `TermKit/Models/Snippet.swift`
- Create: `TermKit/Models/SnippetFile.swift`
- Test: `TermKitTests/SnippetTests.swift`

**Step 1: Write failing test**

```swift
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
        XCTAssertEqual(snippet.variables?.first?.key, "PORT")
        XCTAssertEqual(snippet.dangerLevel, .safe)
    }

    func testDecodeSnippetFile() throws {
        let json = """
        {"version": 1, "snippets": []}
        """.data(using: .utf8)!
        let file = try JSONDecoder().decode(SnippetFile.self, from: json)
        XCTAssertEqual(file.version, 1)
        XCTAssertTrue(file.snippets.isEmpty)
    }
}
```

**Step 2: Run test, verify fails**

Run: `xcodebuild test -project TermKit.xcodeproj -scheme TermKit -destination 'platform=macOS'`
Expected: FAIL — Snippet not found

**Step 3: Implement models**

```swift
// Snippet.swift
import Foundation

enum DangerLevel: String, Codable {
    case safe, caution, danger
}

struct SnippetVariable: Codable, Identifiable {
    var id: String { key }
    let key: String
    let label: String
    let `default`: String?
}

struct Snippet: Codable, Identifiable {
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

// SnippetFile.swift
import Foundation

struct SnippetFile: Codable {
    let version: Int
    let snippets: [Snippet]
}
```

**Step 4: Run test, verify passes**

Expected: PASS

**Step 5: Commit**

```bash
git commit -m "feat: add Snippet and SnippetFile data models"
```

---

### Task 3: SnippetStore — Load & Search

**Files:**
- Create: `TermKit/Services/SnippetStore.swift`
- Create: `TermKit/Resources/default_snippets.json`
- Test: `TermKitTests/SnippetStoreTests.swift`

**Step 1: Write failing tests**

```swift
import XCTest
@testable import TermKit

final class SnippetStoreTests: XCTestCase {
    func testLoadDefaultSnippets() {
        let store = SnippetStore()
        store.loadFromBundle()
        XCTAssertGreaterThan(store.allSnippets.count, 0)
    }

    func testSearchByTitle() {
        let store = SnippetStore()
        store.loadFromBundle()
        store.searchText = "端口"
        XCTAssertTrue(store.filteredSnippets.contains(where: { $0.id == "port_lsof" }))
    }

    func testFilterByCategory() {
        let store = SnippetStore()
        store.loadFromBundle()
        store.selectedCategory = "Debug"
        XCTAssertTrue(store.filteredSnippets.allSatisfy { $0.category == "Debug" })
    }

    func testCategories() {
        let store = SnippetStore()
        store.loadFromBundle()
        XCTAssertTrue(store.categories.contains("Debug"))
        XCTAssertTrue(store.categories.contains("Git"))
    }
}
```

**Step 2: Run tests, verify fail**

**Step 3: Create default_snippets.json**

PRD Section 15 provides 10 default snippets. Create the full JSON file with all 10.

**Step 4: Implement SnippetStore**

```swift
import Foundation
import Combine

class SnippetStore: ObservableObject {
    @Published var allSnippets: [Snippet] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil

    var categories: [String] {
        Array(Set(allSnippets.map(\.category))).sorted()
    }

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

    func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "default_snippets", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(SnippetFile.self, from: data) else { return }
        allSnippets = file.snippets
    }

    func loadFromDisk() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("TermKit")
        let file = dir.appendingPathComponent("snippets.json")

        if !FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            if let bundleURL = Bundle.main.url(forResource: "default_snippets", withExtension: "json") {
                try? FileManager.default.copyItem(at: bundleURL, to: file)
            }
        }

        guard let data = try? Data(contentsOf: file),
              let snippetFile = try? JSONDecoder().decode(SnippetFile.self, from: data) else {
            loadFromBundle()
            return
        }
        allSnippets = snippetFile.snippets
    }
}
```

**Step 5: Run tests, verify pass**

**Step 6: Commit**

```bash
git commit -m "feat: add SnippetStore with load, search, and filter"
```

---

### Task 4: Panel Manager — Floating Window

**Files:**
- Create: `TermKit/Panel/PanelManager.swift`
- Create: `TermKit/Panel/FloatingPanel.swift`
- Modify: `TermKit/TermKitApp.swift`

**Step 1: Implement FloatingPanel (NSPanel subclass)**

```swift
import AppKit
import SwiftUI

class FloatingPanel: NSPanel {
    init(contentRect: NSRect, contentView: NSView) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        self.contentView = contentView
        self.level = .floating
        self.isFloatingPanel = true
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
        self.setContentSize(NSSize(width: 420, height: 520))
        self.center()
    }
}
```

**Step 2: Implement PanelManager**

```swift
import AppKit
import SwiftUI

class PanelManager: ObservableObject {
    private var panel: FloatingPanel?
    @Published var isVisible = false

    func createPanel(with view: some View) {
        let hostingView = NSHostingView(rootView: view)
        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 520),
            contentView: hostingView
        )
    }

    func toggle() {
        guard let panel = panel else { return }
        if panel.isVisible {
            panel.orderOut(nil)
            isVisible = false
        } else {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            isVisible = true
        }
    }
}
```

**Step 3: Update TermKitApp.swift with menu bar + hotkey**

```swift
import SwiftUI
import AppKit

@main
struct TermKitApp: App {
    @StateObject private var snippetStore = SnippetStore()
    @StateObject private var panelManager = PanelManager()

    var body: some Scene {
        MenuBarExtra("TermKit", systemImage: "terminal") {
            Button("Toggle Panel (⌥Space)") { panelManager.toggle() }
            Divider()
            Button("Quit") { NSApp.terminate(nil) }
        }
        Settings { EmptyView() }
    }

    init() {
        // Setup will happen in onAppear or AppDelegate
    }
}
```

**Step 4: Add global hotkey registration via AppDelegate**

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    var panelManager: PanelManager?
    var snippetStore: SnippetStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.option) && event.keyCode == 49 { // 49 = Space
                DispatchQueue.main.async { self?.panelManager?.toggle() }
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.option) && event.keyCode == 49 {
                DispatchQueue.main.async { self?.panelManager?.toggle() }
                return nil
            }
            return event
        }
    }
}
```

**Step 5: Build and verify panel appears**

Run: `xcodebuild build`
Expected: BUILD SUCCEEDED. App launches with menu bar icon, ⌥Space toggles floating panel.

**Step 6: Commit**

```bash
git commit -m "feat: add floating panel with global hotkey toggle"
```

---

### Task 5: Main UI — Search, Categories, Snippet List, Detail

**Files:**
- Create: `TermKit/Views/ContentView.swift`
- Create: `TermKit/Views/SearchBar.swift`
- Create: `TermKit/Views/CategorySidebar.swift`
- Create: `TermKit/Views/SnippetRow.swift`
- Create: `TermKit/Views/SnippetDetailView.swift`

**Step 1: Build all views**

ContentView layout:
- Top: SearchBar (text field bound to snippetStore.searchText)
- Left: CategorySidebar (list of categories, "All" option)
- Right: List of SnippetRow items
- Bottom: SnippetDetailView (selected snippet's command preview + Copy button)

**Step 2: Build and verify UI renders**

Expected: Panel shows search bar, categories on left, snippets on right, detail at bottom.

**Step 3: Commit**

```bash
git commit -m "feat: add main UI with search, categories, snippet list, and detail"
```

---

### Task 6: Copy to Clipboard + Toast

**Files:**
- Create: `TermKit/Services/ClipboardService.swift`
- Create: `TermKit/Views/ToastView.swift`
- Modify: `TermKit/Views/SnippetDetailView.swift` — wire up Copy button
- Test: `TermKitTests/ClipboardTests.swift`

**Step 1: Write failing test**

```swift
import XCTest
@testable import TermKit

final class ClipboardTests: XCTestCase {
    func testCopyToClipboard() {
        ClipboardService.copy("hello world")
        let result = NSPasteboard.general.string(forType: .string)
        XCTAssertEqual(result, "hello world")
    }

    func testCopyMultiline() {
        let multiline = "line1\nline2\nline3"
        ClipboardService.copy(multiline)
        let result = NSPasteboard.general.string(forType: .string)
        XCTAssertEqual(result, multiline)
    }
}
```

**Step 2: Implement ClipboardService**

```swift
import AppKit

enum ClipboardService {
    static func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
```

**Step 3: Implement ToastView**

Overlay text "Copied!" that fades in/out over 1.5s.

**Step 4: Wire Copy button in SnippetDetailView**

**Step 5: Run tests, verify pass**

**Step 6: Commit**

```bash
git commit -m "feat: add copy to clipboard with toast feedback"
```

---

### Task 7: Integration — Wire Everything Together

**Files:**
- Modify: `TermKit/TermKitApp.swift` — connect store, panel, views
- Verify: Full flow works

**Step 1: Ensure app startup loads snippets and creates panel**

**Step 2: Manual integration test**
1. Launch app → menu bar icon appears
2. Press ⌥Space → panel opens with 10 default snippets
3. Type "port" in search → filters to port-related snippets
4. Click "Debug" category → shows only Debug snippets
5. Click a snippet → detail shows command
6. Click Copy → clipboard has correct command, toast shows "Copied!"
7. Press ⌥Space → panel hides

**Step 3: Commit**

```bash
git commit -m "feat: wire up full M0-M2 flow"
```
