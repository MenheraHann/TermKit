import SwiftUI

@main
struct TermKitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("TermKit", systemImage: "terminal") {
            Button("Toggle Panel (\u{2325}Space)") {
                appDelegate.panelManager.toggle()
            }
            Divider()
            Button("Quit") { NSApp.terminate(nil) }
        }
        Settings {
            EmptyView()
        }
    }
}
