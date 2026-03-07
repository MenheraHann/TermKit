import AppKit
import SwiftUI

@MainActor
final class CmdHoldMenuWindowController {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<CmdHoldMenuView>?
    private var lastMouseLocation: NSPoint = .zero

    /// 首次弹出时记住的方向（true = 向上弹，false = 向下弹）
    /// 子菜单优先沿用首次方向，除非放不下才翻转
    private var initialPopUpward: Bool?
    private var initialPopLeft: Bool?

    /// 菜单面板宽度限制
    private let minMenuWidth: CGFloat = 240
    private let maxMenuWidth: CGFloat = 300

    var onRequestSelectIndex: ((Int) -> Void)?
    var onRequestCommitSelection: (() -> Void)?

    func update(state: CmdHoldMenuState) {
        guard let hostingView, let panel else { return }
        hostingView.rootView = CmdHoldMenuView(
            state: state,
            onSelectIndex: { [weak self] index in self?.onRequestSelectIndex?(index) },
            onCommitSelection: { [weak self] in self?.onRequestCommitSelection?() }
        )
        // 强制刷新布局，确保 fittingSize 反映新内容
        hostingView.layoutSubtreeIfNeeded()
        let fittingSize = hostingView.fittingSize
        let newSize = NSSize(
            width: min(max(fittingSize.width, minMenuWidth), maxMenuWidth),
            height: fittingSize.height
        )
        // 层级切换时也用智能定位，根据鼠标位置重新翻转
        if lastMouseLocation != .zero {
            let newOrigin = smartPosition(mouse: lastMouseLocation, size: newSize)
            panel.setFrame(NSRect(origin: newOrigin, size: newSize), display: true, animate: false)
        } else {
            let origin = panel.frame.origin
            let newOrigin = NSPoint(x: origin.x, y: origin.y + panel.frame.height - newSize.height)
            panel.setFrame(NSRect(origin: newOrigin, size: newSize), display: true, animate: false)
        }
    }

    func show(at mouseLocation: NSPoint, state: CmdHoldMenuState) {
        if panel == nil {
            createPanel()
        }
        guard let panel, let hostingView else { return }
        update(state: state)

        // 让面板大小跟随 SwiftUI 内容
        let fittingSize = hostingView.fittingSize
        let panelSize = NSSize(
            width: min(max(fittingSize.width, minMenuWidth), maxMenuWidth),
            height: fittingSize.height
        )
        // 首次打开：重置方向记忆，由 smartPosition 决定并记录
        initialPopUpward = nil
        initialPopLeft = nil
        lastMouseLocation = mouseLocation
        let origin = smartPosition(mouse: mouseLocation, size: panelSize)
        panel.setFrame(NSRect(origin: origin, size: panelSize), display: true)

        // 不抢焦点
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func presentAddFolder(onSave: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.title = L10n.MenuDialog.chooseFolderTitle
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        if #available(macOS 14.0, *) { NSApp.activate() } else { NSApp.activate(ignoringOtherApps: true) }
        guard panel.runModal() == .OK, let url = panel.url else { return }
        onSave(url.path)
    }

    func presentAddCLI(onSave: @escaping (CLIEntry) -> Void) {
        let alert = NSAlert()
        alert.messageText = L10n.MenuDialog.addCLITitle
        alert.informativeText = L10n.MenuDialog.addCLIMessage

        let name = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        name.placeholderString = L10n.MenuDialog.placeholderName

        alert.accessoryView = name
        alert.addButton(withTitle: L10n.Common.save)
        alert.addButton(withTitle: L10n.Common.cancel)
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let nameText = name.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nameText.isEmpty else { return }
        onSave(CLIEntry(name: nameText))
    }

    func presentAddAction(onSave: @escaping (String, String) -> Void) {
        let alert = NSAlert()
        alert.messageText = L10n.MenuDialog.addActionTitle
        alert.informativeText = L10n.MenuDialog.addActionMessage

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        title.placeholderString = L10n.MenuDialog.placeholderTitle
        let cmd = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        cmd.placeholderString = L10n.MenuDialog.placeholderCommand
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(cmd)

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 70))
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        alert.accessoryView = container
        alert.addButton(withTitle: L10n.Common.save)
        alert.addButton(withTitle: L10n.Common.cancel)
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let titleText = title.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let cmdText = cmd.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !titleText.isEmpty, !cmdText.isEmpty else { return }
        onSave(titleText, cmdText)
    }

    // MARK: - Private

    /// 智能定位：根据鼠标位置决定菜单弹出方向
    /// - 首次打开：自动判断方向（上/下、左/右）并锁定
    /// - 子菜单：方向永远不变，放不下时只做平移（clamp 到屏幕可见区域），不翻转
    private func smartPosition(mouse: NSPoint, size: NSSize) -> NSPoint {
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) }
            ?? NSScreen.main
        guard let visibleFrame = screen?.visibleFrame else {
            return NSPoint(x: mouse.x, y: mouse.y - size.height)
        }

        // 首次打开：判断方向并锁定
        if initialPopLeft == nil {
            initialPopLeft = mouse.x + size.width > visibleFrame.maxX
        }
        if initialPopUpward == nil {
            initialPopUpward = mouse.y - size.height < visibleFrame.minY
        }

        // X 轴：按锁定方向计算，不翻转
        let goLeft = initialPopLeft ?? false
        var x = goLeft ? mouse.x - size.width : mouse.x

        // Y 轴：按锁定方向计算，不翻转
        let goUp = initialPopUpward ?? false
        var y = goUp ? mouse.y : mouse.y - size.height

        // 平移兜底：确保完整显示在屏幕内
        x = max(visibleFrame.minX, min(x, visibleFrame.maxX - size.width))
        y = max(visibleFrame.minY, min(y, visibleFrame.maxY - size.height))

        return NSPoint(x: x, y: y)
    }

    private func createPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 100),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isReleasedWhenClosed = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false

        let placeholder = CmdHoldMenuView(
            state: CmdHoldMenuState(),
            onSelectIndex: { [weak self] index in self?.onRequestSelectIndex?(index) },
            onCommitSelection: { [weak self] in self?.onRequestCommitSelection?() }
        )
        let hosting = NSHostingView(rootView: placeholder)
        panel.contentView = hosting

        self.panel = panel
        self.hostingView = hosting
    }

}

