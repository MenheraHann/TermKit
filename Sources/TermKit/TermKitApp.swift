import AppKit
import SwiftUI

@main
struct TermKitApp: App {
    @StateObject private var model = TermKitModel()

    init() {
        // NSApp 在 SwiftUI App.init() 阶段可能尚未就绪，延迟到主线程下一轮执行
        DispatchQueue.main.async {
            NSApp?.setActivationPolicy(.accessory)
        }
    }

    var body: some Scene {
        MenuBarExtra("TermKit", systemImage: "command") {
            Button("Show Menu") { model.menu.show() }
            Button("Reload Config") { model.reloadConfig() }
            Divider()
            if #available(macOS 14, *) {
                SettingsLink()
            } else {
                Button("Settings…") {
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
