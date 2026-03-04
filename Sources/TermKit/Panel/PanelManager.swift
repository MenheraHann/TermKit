import AppKit
import SwiftUI

/// 面板管理器，负责创建、显示和隐藏浮动面板
/// - 持有 FloatingPanel 实例
/// - 通过 toggle() 切换面板的显示/隐藏状态
/// - isVisible 属性实时反映面板当前状态
@MainActor
class PanelManager: ObservableObject {

    /// 面板是否当前可见
    @Published var isVisible: Bool = false

    /// 浮动面板实例
    private var panel: FloatingPanel?

    /// 用指定的 SwiftUI 视图创建浮动面板
    /// - Parameter content: 要在面板内显示的 SwiftUI 视图
    func createPanel<Content: View>(with content: Content) {
        let panel = FloatingPanel()

        // 用 NSHostingView 把 SwiftUI 视图嵌入 NSPanel
        let hostingView = NSHostingView(rootView: content)
        hostingView.autoresizingMask = [.width, .height]

        if let contentView = panel.contentView {
            hostingView.frame = contentView.bounds
            contentView.addSubview(hostingView)
        }

        self.panel = panel
    }

    /// 切换面板的显示/隐藏状态
    func toggle() {
        guard let panel = panel else {
            print("[TermKit] PanelManager.toggle() - 面板尚未创建")
            return
        }

        if panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    /// 显示面板并激活应用
    private func show() {
        guard let panel = panel else { return }
        // 记录面板打开前的前台应用（用于 Run 功能识别终端）
        let frontBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        TerminalService.previousTerminal = TerminalService.detectFromBundleID(frontBundleID)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isVisible = true
    }

    /// 隐藏面板
    private func hide() {
        guard let panel = panel else { return }
        panel.orderOut(nil)
        isVisible = false
        print("[TermKit] 面板已隐藏")
    }
}
