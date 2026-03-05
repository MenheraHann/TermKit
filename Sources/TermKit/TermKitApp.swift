import AppKit
import SwiftUI

@main
struct TermKitApp: App {
    @StateObject private var model = TermKitModel()

    init() {
        NSApp.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("TermKit", systemImage: "command") {
            Button("Show Menu") { model.menu.show() }
            Button("Reload Config") { model.reloadConfig() }
            Divider()
            Button("Settings…") {
                if #available(macOS 14, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
            }
            Button("Quit") { NSApp.terminate(nil) }
        }
        Settings {
            SettingsView()
                .environmentObject(model)
        }
    }
}
