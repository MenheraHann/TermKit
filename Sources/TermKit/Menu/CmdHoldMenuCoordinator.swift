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

        window.onRequestConfirm = { [weak self] in self?.confirm() }
        window.onRequestCancel = { [weak self] in self?.hide() }
        window.onRequestNavigate = { [weak self] nav in self?.handle(nav) }
        window.onRequestSelectIndex = { [weak self] index in self?.state.select(index: index) }
        window.onRequestCommitSelection = { [weak self] in self?.state.commitSelection() }
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
        state.reset()
        window.show(at: NSEvent.mouseLocation, state: state)
    }

    func hide() {
        window.hide()
    }

    private func handle(_ nav: CmdHoldMenuNavigation) {
        state.navigate(nav)
        window.update(state: state)
    }

    private func confirm() {
        let action = state.currentAction
        switch action {
        case .pasteText(let text):
            let delayMs = config.timing.clipboardRestoreDelayMs
            paster.pasteTextWithClipboardRestore(text, restoreDelayMs: delayMs)
            hide()
        case .pasteImagePath:
            guard let imageURL = imagePaster.savePasteboardImage(
                saveDirectory: config.imagePaste.saveDirectory
            ) else {
                NSSound.beep()
                hide()
                return
            }
            let delayMs = config.timing.clipboardRestoreDelayMs
            paster.pasteTextWithClipboardRestore(imageURL.path, restoreDelayMs: delayMs)
            hide()
        case .showAddFolder:
            window.presentAddFolder { [weak self] path in
                guard let self else { return }
                var next = config
                let expanded = (path as NSString).expandingTildeInPath
                next.folders.append(FolderEntry(title: URL(fileURLWithPath: expanded).lastPathComponent, path: expanded))
                self.configStore.save(next)
                self.applyConfig(next)
            }
        case .showAddCLI:
            window.presentAddCLI { [weak self] entry in
                guard let self else { return }
                var next = config
                next.clis.append(entry)
                self.configStore.save(next)
                self.applyConfig(next)
            }
        case .showAddAction(let cliID):
            window.presentAddAction { [weak self] title, command in
                guard let self else { return }
                var next = config
                guard let idx = next.clis.firstIndex(where: { $0.id == cliID }) else { return }
                next.clis[idx].customActions.append(CLIAction(title: title, command: command))
                self.configStore.save(next)
                self.applyConfig(next)
            }
        case .none:
            hide()
        }
    }
}
