import AppKit
import SwiftUI

/// 应用程序代理，负责：
/// - 注册全局和本地热键监听（⌥Space 切换面板）
/// - 设置应用激活策略（隐藏 Dock 图标）
/// - 管理 PanelManager 和 SnippetStore 的生命周期
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    /// 面板管理器，控制浮动面板的显示/隐藏
    let panelManager = PanelManager()
    /// 片段数据管理中心
    let snippetStore = SnippetStore()
    /// 设置管理器
    let settingsManager = SettingsManager()
    /// 最近使用管理器
    let recentManager = RecentManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设为 accessory 应用，不在 Dock 中显示图标
        NSApp.setActivationPolicy(.accessory)

        // 加载片段数据
        snippetStore.load()

        // 创建面板，嵌入 ContentView
        let contentView = ContentView(
            store: snippetStore,
            panelManager: panelManager,
            settings: settingsManager,
            recentManager: recentManager
        )
        panelManager.createPanel(with: contentView)

        // 全局热键监听（应用未聚焦时生效）
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleHotkey(event)
        }

        // 本地热键监听（应用聚焦时生效）
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleHotkey(event) == true {
                return nil  // 消费事件，不再传递
            }
            return event
        }

        // 分布式通知：opentk CLI 触发面板切换
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.termkit.toggle"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.panelManager.toggle()
        }

        print("[TermKit] 应用启动完成，按 ⌥Space 或运行 opentk 切换面板")
    }

    /// 处理热键事件
    /// - Parameter event: 键盘事件
    /// - Returns: 如果匹配热键则返回 true
    @discardableResult
    private func handleHotkey(_ event: NSEvent) -> Bool {
        // ⌥Space（Option + 空格键，keyCode 49）
        if event.modifierFlags.contains(.option) && event.keyCode == 49 {
            DispatchQueue.main.async { [weak self] in
                self?.panelManager.toggle()
            }
            return true
        }
        return false
    }
}
