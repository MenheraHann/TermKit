import SwiftUI

@main
struct TermKitApp: App {
    @StateObject private var snippetStore = SnippetStore()

    var body: some Scene {
        MenuBarExtra("TermKit", systemImage: "terminal") {
            Button("Toggle Panel (\u{2325}Space)") {
                // Will be wired in Task 4
            }
            Divider()
            Button("Quit") { NSApp.terminate(nil) }
        }
        Settings {
            EmptyView()
        }
    }
}
