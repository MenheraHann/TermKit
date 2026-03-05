import AppKit
import SwiftUI

@MainActor
final class CmdHoldMenuWindowController {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<CmdHoldMenuView>?

    private var localMonitor: Any?

    var onRequestConfirm: (() -> Void)?
    var onRequestCancel: (() -> Void)?
    var onRequestNavigate: ((CmdHoldMenuNavigation) -> Void)?
    var onRequestSelectIndex: ((Int) -> Void)?
    var onRequestCommitSelection: (() -> Void)?

    func update(state: CmdHoldMenuState) {
        guard let hostingView else { return }
        hostingView.rootView = CmdHoldMenuView(
            state: state,
            onSelectIndex: { [weak self] index in self?.onRequestSelectIndex?(index) },
            onCommitSelection: { [weak self] in self?.onRequestCommitSelection?() }
        )
    }

    func show(at mouseLocation: NSPoint, state: CmdHoldMenuState) {
        if panel == nil {
            createPanel()
        }
        guard let panel else { return }
        update(state: state)

        let size = panel.frame.size
        let origin = NSPoint(x: mouseLocation.x - size.width / 2, y: mouseLocation.y - size.height / 2)
        panel.setFrameOrigin(origin)

        // 不抢焦点：用 orderFrontRegardless 而非 makeKeyAndOrderFront
        // 这样前台窗口（终端）保持聚焦，粘贴命令能正确送达
        panel.orderFrontRegardless()
        startKeyMonitor()
    }

    func hide() {
        stopKeyMonitor()
        panel?.orderOut(nil)
    }

    func presentAddFolder(onSave: @escaping (String) -> Void) {
        let alert = NSAlert()
        alert.messageText = "添加文件夹"
        alert.informativeText = "输入文件夹路径（支持 ~）"
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        alert.accessoryView = field
        alert.addButton(withTitle: "保存")
        alert.addButton(withTitle: "取消")
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }
        let text = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onSave(text)
    }

    func presentAddCLI(onSave: @escaping (CLIEntry) -> Void) {
        let alert = NSAlert()
        alert.messageText = "添加 CLI"
        alert.informativeText = "输入 CLI 名称与命令模板（可留空）"

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        func row(_ label: String) -> NSTextField {
            let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
            tf.placeholderString = label
            return tf
        }

        let name = row("Name (required)")
        let start = row("Start command (optional)")
        let cont = row("Continue command (optional)")
        let resume = row("Resume command (optional)")

        [name, start, cont, resume].forEach { stack.addArrangedSubview($0) }

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 140))
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        alert.accessoryView = container
        alert.addButton(withTitle: "保存")
        alert.addButton(withTitle: "取消")
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let nameText = name.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nameText.isEmpty else { return }
        let entry = CLIEntry(
            name: nameText,
            startCommand: start.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            continueCommand: cont.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            resumeCommand: resume.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
        onSave(entry)
    }

    func presentAddAction(onSave: @escaping (String, String) -> Void) {
        let alert = NSAlert()
        alert.messageText = "添加动作"
        alert.informativeText = "输入动作名称与命令模板"

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
        alert.addButton(withTitle: "保存")
        alert.addButton(withTitle: "取消")
        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let titleText = title.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let cmdText = cmd.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !titleText.isEmpty, !cmdText.isEmpty else { return }
        onSave(titleText, cmdText)
    }

    // MARK: - Private

    private func createPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 200),
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isReleasedWhenClosed = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true

        let placeholder = CmdHoldMenuView(
            state: CmdHoldMenuState(),
            onSelectIndex: { [weak self] index in self?.onRequestSelectIndex?(index) },
            onCommitSelection: { [weak self] in self?.onRequestCommitSelection?() }
        )
        let hosting = NSHostingView(rootView: placeholder)
        hosting.frame = panel.contentView?.bounds ?? .zero
        hosting.autoresizingMask = [.width, .height]
        panel.contentView = hosting

        self.panel = panel
        self.hostingView = hosting
    }

    private func startKeyMonitor() {
        guard localMonitor == nil else { return }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if handleKeyDown(event) {
                return nil
            }
            return event
        }
    }

    private func stopKeyMonitor() {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 126: // up
            onRequestNavigate?(.up); return true
        case 125: // down
            onRequestNavigate?(.down); return true
        case 123: // left
            onRequestNavigate?(.back); return true
        case 124: // right
            onRequestNavigate?(.forward); return true
        case 36: // return
            onRequestConfirm?(); return true
        case 53: // esc
            onRequestCancel?(); return true
        default:
            break
        }

        if let chars = event.charactersIgnoringModifiers, let first = chars.first {
            switch first {
            case "1"..."9":
                let n = Int(String(first)) ?? 0
                onRequestSelectIndex?(n - 1)
                onRequestCommitSelection?()
                return true
            case "0":
                onRequestSelectIndex?(9)
                onRequestCommitSelection?()
                return true
            case "~", "`":
                onRequestNavigate?(.back)
                return true
            default:
                break
            }
        }

        return false
    }
}

private extension String {
    var nilIfEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
