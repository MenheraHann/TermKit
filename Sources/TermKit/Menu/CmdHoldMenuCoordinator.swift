import AppKit
import Foundation

@MainActor
final class CmdHoldMenuCoordinator: ObservableObject {
    private let configStore: ConfigStore
    private let detector: ModifierHoldDetector
    private let window: CmdHoldMenuWindowController
    private let paster = PasteService()
    private let imagePaster = ImagePasteService()

    private var config: TermKitConfig = .defaultValue
    private let state = CmdHoldMenuState()

    init(configStore: ConfigStore) {
        self.configStore = configStore
        self.detector = ModifierHoldDetector()
        self.window = CmdHoldMenuWindowController()

        detector.onShowMenu = { [weak self] in self?.show() }
        detector.onConfirm = { [weak self] in self?.confirm() }
        detector.onCancel = { [weak self] in self?.hide() }
        detector.onNavigate = { [weak self] nav in self?.handle(nav) }
        detector.onDelete = { [weak self] in self?.handleDelete() }
        detector.onPaste = { [weak self] in self?.handleSmartPaste() }
        detector.onNumberKeySelect = { [weak self] index in
            guard let self, index < self.state.numberedItemCount else { return }
            self.state.select(index: index)
            self.commitAndMaybeExecute()
        }

        window.onRequestSelectIndex = { [weak self] index in self?.state.select(index: index) }
        window.onRequestCommitSelection = { [weak self] in self?.commitAndMaybeExecute() }
    }

    func applyConfig(_ config: TermKitConfig) {
        self.config = config
        detector.holdThresholdMs = config.timing.holdThresholdMs
        detector.triggerKey = config.features.triggerKey
        detector.isEnabled = config.features.enableCmdHoldMenu
        state.applyConfig(config)
        window.update(state: state)
    }

    func show() {
        detector.menuDidShow()
        state.reset()
        window.show(at: NSEvent.mouseLocation, state: state)
    }

    func hide() {
        detector.menuDidHide()
        window.hide()
    }

    private func handle(_ nav: CmdHoldMenuNavigation) {
        if nav == .forward && state.selectedIndex >= 0 {
            commitAndMaybeExecute()
        } else {
            state.navigate(nav)
            window.update(state: state)
        }
    }

    private func commitAndMaybeExecute() {
        let levelBefore = state.level
        state.commitSelection()
        if state.level == levelBefore, state.currentAction != nil {
            confirm()
        } else {
            window.update(state: state)
        }
    }

    private func handleDelete() {
        if state.level == .root {
            paster.sendClearLine()
            hide()
        } else {
            state.reset()
            window.update(state: state)
        }
    }

    private func handleSmartPaste() {
        detector.menuDidHide()
        let pb = NSPasteboard.general
        if pb.string(forType: .string) != nil {
            // 剪贴板有文字 → 直接 ⌘V
            paster.sendPaste()
        } else if NSImage(pasteboard: pb) != nil {
            // 剪贴板有图片 → 保存路径再粘贴
            guard let url = imagePaster.savePasteboardImage(
                saveDirectory: config.imagePaste.saveDirectory
            ) else {
                NSSound.beep()
                hide()
                return
            }
            paster.pasteTextWithClipboardRestore(url.path, restoreDelayMs: config.timing.clipboardRestoreDelayMs)
        } else {
            NSSound.beep()
        }
        hide()
    }

    private func confirm() {
        detector.menuDidHide()
        let action = state.currentAction
        switch action {
        case .pasteText(let text):
            let delayMs = config.timing.clipboardRestoreDelayMs
            paster.pasteTextWithClipboardRestore(text, restoreDelayMs: delayMs)
            hide()
        case .pasteImagePath:
            handleSmartPaste()
            return
        case .deleteInput:
            paster.sendClearLine()
            hide()
        case .showAddFolder:
            hide()
            window.presentAddFolder { [weak self] path in
                guard let self else { return }
                var next = config
                let expanded = (path as NSString).expandingTildeInPath
                next.folders.append(FolderEntry(title: URL(fileURLWithPath: expanded).lastPathComponent, path: expanded))
                self.configStore.save(next)
                self.applyConfig(next)
            }
        case .showAddCLI:
            hide()
            window.presentAddCLI { [weak self] entry in
                guard let self else { return }
                var next = config
                next.clis.append(entry)
                self.configStore.save(next)
                self.applyConfig(next)
            }
        case .pasteTemplate(let tmpl):
            // 检查是否有未填充的变量（无默认值）
            let hasUnresolved = tmpl.variables.contains { $0.defaultValue.isEmpty }
            if hasUnresolved {
                NSSound.beep()
                hide()
            } else {
                let resolved = tmpl.resolvedCommand()
                let delayMs = config.timing.clipboardRestoreDelayMs
                paster.pasteTextWithClipboardRestore(resolved, restoreDelayMs: delayMs)
                hide()
            }
        case .showAddAction(let cliID):
            hide()
            window.presentAddAction { [weak self] title, command in
                guard let self else { return }
                var next = config
                guard let idx = next.clis.firstIndex(where: { $0.id == cliID }) else { return }
                next.clis[idx].actions.append(CLIAction(title: title, command: command))
                self.configStore.save(next)
                self.applyConfig(next)
            }
        case .none:
            hide()
        }
    }
}
