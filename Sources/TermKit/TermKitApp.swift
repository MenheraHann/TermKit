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
            Toggle("启用快捷菜单", isOn: Binding(
                get: { model.config.features.enableCmdHoldMenu },
                set: { value in
                    var next = model.config
                    next.features.enableCmdHoldMenu = value
                    model.saveConfig(next)
                }
            ))
            Divider()
            if #available(macOS 14, *) {
                SettingsLink { Text("配置…") }
            } else {
                Button("配置…") {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
            }
            Button("退出 TermKit") { NSApp.terminate(nil) }
        }
        Settings {
            SettingsView()
                .environmentObject(model)
        }
    }
}
