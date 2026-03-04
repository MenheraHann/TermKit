import AppKit

/// 自定义浮动面板，作为 TermKit 的主界面窗口
/// - HUD 风格窗口，始终浮动在最上层
/// - 隐藏标题栏，支持拖拽移动
/// - 毛玻璃背景效果（vibrancy）
/// - 默认尺寸 420x520，居中显示
class FloatingPanel: NSPanel {

    /// 初始化浮动面板，配置窗口样式和行为
    init(contentRect: NSRect = NSRect(x: 0, y: 0, width: 420, height: 520)) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )

        // 浮动层级，始终在普通窗口之上
        level = .floating

        // 隐藏标题栏，使其透明
        titlebarAppearsTransparent = true
        titleVisibility = .hidden

        // 允许通过拖拽窗口背景移动
        isMovableByWindowBackground = true

        // 可跨所有桌面空间显示
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // 关闭时不释放，方便反复显示/隐藏
        isReleasedWhenClosed = false

        // 居中显示
        center()

        // 添加毛玻璃背景效果
        setupVibrancyBackground()
    }

    /// 配置 NSVisualEffectView 实现毛玻璃模糊背景
    private func setupVibrancyBackground() {
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        visualEffect.autoresizingMask = [.width, .height]

        // 将毛玻璃视图设为内容视图的底层
        if let contentView = self.contentView {
            visualEffect.frame = contentView.bounds
            contentView.addSubview(visualEffect, positioned: .below, relativeTo: nil)
        }
    }

    /// 允许面板成为 key window，以接收键盘事件
    override var canBecomeKey: Bool { true }

    /// 允许面板成为 main window
    override var canBecomeMain: Bool { true }
}
