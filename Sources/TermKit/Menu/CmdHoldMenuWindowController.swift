import AppKit
import SwiftUI

@MainActor
final class CmdHoldMenuWindowController {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<CmdHoldMenuView>?

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
        let origin = panel.frame.origin
        // 保持左上角不动（macOS 坐标系 y 从底部起）
        let newOrigin = NSPoint(x: origin.x, y: origin.y + panel.frame.height - newSize.height)
        let clamped = clampToScreen(origin: newOrigin, size: newSize)
        panel.setFrame(NSRect(origin: clamped, size: newSize), display: true, animate: false)
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
        // 面板出现在光标右下方（类似右键菜单的位置）
        let origin = NSPoint(x: mouseLocation.x, y: mouseLocation.y - panelSize.height)
        let clamped = clampToScreen(origin: origin, size: panelSize)
        panel.setFrame(NSRect(origin: clamped, size: panelSize), display: true)

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

        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK, let url = panel.url else { return }
        onSave(url.path)
    }

    func presentAddCLI(onSave: @escaping (CLIEntry) -> Void) {
        let alert = NSAlert()
        alert.messageText = L10n.MenuDialog.addCLITitle
        alert.informativeText = L10n.MenuDialog.addCLIMessage

        let name = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        name.placeholderString = "Name (required)"

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
        title.placeholderString = "Title (required)"
        let cmd = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        cmd.placeholderString = "Command (required)"
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

    /// 将面板 origin 钳制到光标所在屏幕的可见区域内
    private func clampToScreen(origin: NSPoint, size: NSSize) -> NSPoint {
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouseLocation) }
            ?? NSScreen.main
        guard let visibleFrame = screen?.visibleFrame else { return origin }

        var x = origin.x
        var y = origin.y

        // 右侧溢出 → 左移
        if x + size.width > visibleFrame.maxX {
            x = visibleFrame.maxX - size.width
        }
        // 左侧溢出 → 右移
        if x < visibleFrame.minX {
            x = visibleFrame.minX
        }
        // 底部溢出 → 上移
        if y < visibleFrame.minY {
            y = visibleFrame.minY
        }
        // 顶部溢出 → 下移
        if y + size.height > visibleFrame.maxY {
            y = visibleFrame.maxY - size.height
        }

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

