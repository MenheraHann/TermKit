import AppKit
import SwiftUI

// MARK: - 设置窗口管理器

/// 用自管理的 NSWindow 替代 SwiftUI Settings 场景，彻底避免时序问题
final class SettingsWindowManager: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowManager()
    private var window: NSWindow?

    func open(model: TermKitModel) {
        // 已打开则直接置前
        if let w = window, w.isVisible {
            w.makeKeyAndOrderFront(nil)
            if #available(macOS 14.0, *) { NSApp.activate() } else { NSApp.activate(ignoringOtherApps: true) }
            return
        }

        NSApp.setActivationPolicy(.regular)

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        w.title = L10n.MenuBar.settingsWindowTitle
        w.titleVisibility = .visible
        w.toolbarStyle = .expanded
        w.contentView = NSHostingView(
            rootView: SettingsView().environmentObject(model)
        )
        w.isReleasedWhenClosed = false
        w.delegate = self
        w.center()
        w.makeKeyAndOrderFront(nil)
        if #available(macOS 14.0, *) { NSApp.activate() } else { NSApp.activate(ignoringOtherApps: true) }

        self.window = w
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

// MARK: - App Delegate

/// 防止关闭设置窗口时 macOS 终止后台进程
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// MARK: - App 入口

@main
struct TermKitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var model = TermKitModel()

    init() {
        DispatchQueue.main.async {
            NSApp?.setActivationPolicy(.accessory)
        }
    }

    var body: some Scene {
        MenuBarExtra("TermKit", systemImage: "terminal") {
            Toggle(L10n.MenuBar.enableQuickMenu, isOn: Binding(
                get: { model.config.features.enableCmdHoldMenu },
                set: { value in
                    var next = model.config
                    next.features.enableCmdHoldMenu = value
                    model.saveConfig(next)
                }
            ))
            Divider()
            Button(L10n.MenuBar.configure) {
                SettingsWindowManager.shared.open(model: model)
            }
            Button(L10n.MenuBar.quit) { NSApp.terminate(nil) }
        }
    }
}
