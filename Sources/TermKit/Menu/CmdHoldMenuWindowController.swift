import AppKit
import SwiftUI

@MainActor
final class CmdHoldMenuWindowController {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<CmdHoldMenuView>?
    private var lastMouseLocation: NSPoint = .zero

    var onRequestSelectIndex: ((Int) -> Void)?
    var onRequestCommitSelection: (() -> Void)?

    func update(state: CmdHoldMenuState) {
        guard let hostingView, let panel else { return }
        hostingView.rootView = CmdHoldMenuView(
            state: state,
            onSelectIndex: { [weak self] index in self?.onRequestSelectIndex?(index) },
            onCommitSelection: { [weak self] in self?.onRequestCommitSelection?() }
        )
        // 切换层级时重新调整面板大小
        let fittingSize = hostingView.fittingSize
        let newSize = NSSize(width: max(fittingSize.width, 240), height: fittingSize.height)
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
        let panelSize = NSSize(width: max(fittingSize.width, 240), height: fittingSize.height)
        // 智能定位：根据鼠标位置自动翻转菜单方向
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
    /// - 默认：鼠标右下方
    /// - 右侧溢出：翻到鼠标左侧
    /// - 底部溢出：翻到鼠标上方
    /// - 极端情况仍做边界兜底 clamp
    private func smartPosition(mouse: NSPoint, size: NSSize) -> NSPoint {
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) }
            ?? NSScreen.main
        guard let visibleFrame = screen?.visibleFrame else {
            return NSPoint(x: mouse.x, y: mouse.y - size.height)
        }

        // X 轴：右侧放不下就翻到左侧
        var x: CGFloat
        if mouse.x + size.width > visibleFrame.maxX {
            x = mouse.x - size.width
        } else {
            x = mouse.x
        }

        // Y 轴：下方放不下就翻到上方（macOS 坐标系 y 从底部起）
        var y: CGFloat
        if mouse.y - size.height < visibleFrame.minY {
            y = mouse.y
        } else {
            y = mouse.y - size.height
        }

        // 边界兜底：防止极端情况（屏幕比菜单还小）
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
        // 让 hosting view 根据 SwiftUI 内容自适应大小
        hosting.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = hosting

        self.panel = panel
        self.hostingView = hosting
    }

}

