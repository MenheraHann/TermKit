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
    private var reEnableTimer: DispatchSourceTimer?

    /// 暂停 1 小时标志（UI 需读取来同步开关状态）
    private(set) var isTemporarilyDisabled = false

    /// 外部回调：当 coordinator 内部修改了 config（如永久关闭快捷键），通知 model 同步
    var onConfigDidChange: ((TermKitConfig) -> Void)?

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
        detector.onDisableTemporary = { [weak self] in self?.disableForOneHour() }
        detector.onDisablePermanent = { [weak self] in self?.disablePermanently() }
        detector.onOpenSelection = { [weak self] in self?.handleOpenSelection() }
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
        ModifierHoldDetector.updateAllowedApps(config.allowedApps)

        // 用户在暂停期间手动打开开关 → 视为主动恢复，取消暂停
        if config.features.enableCmdHoldMenu && isTemporarilyDisabled {
            cancelTemporaryDisable()
        }

        detector.isEnabled = config.features.enableCmdHoldMenu && !isTemporarilyDisabled
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
            state.deselect()           // 取消选中，防止释放时重复执行
            window.update(state: state)
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

    /// L 键：读取选中文字，解析为路径并用 Finder/默认应用打开
    private func handleOpenSelection() {
        hide()
        paster.readSelectedText { [weak self] text in
            guard self != nil else { return }
            guard let raw = text, !raw.isEmpty else {
                NSSound.beep()
                return
            }

            NSLog("[TermKit] [OpenSel] 原始文本 (%d 字符): %@", raw.count, String(raw.prefix(200)))

            var path = raw.trimmingCharacters(in: .whitespacesAndNewlines)

            // 清理 ANSI 转义码（终端复制的文本可能包含颜色/格式代码）
            path = path.replacingOccurrences(
                of: #"\x1B\[[0-9;]*[A-Za-z]"#,
                with: "",
                options: .regularExpression
            )
            // 移除终端换行及其后的缩进空格（终端自动换行会把路径拆断）
            path = path.replacingOccurrences(
                of: #"\r?\n\s*"#,
                with: "",
                options: .regularExpression
            )
            NSLog("[TermKit] [OpenSel] 清理后路径: %@", path)

            // 去除包裹的引号
            if (path.hasPrefix("\"") && path.hasSuffix("\""))
                || (path.hasPrefix("'") && path.hasSuffix("'")) {
                path = String(path.dropFirst().dropLast())
            }

            // 处理 file:line:column 格式（去掉 :行号:列号 后缀）
            // 匹配模式：路径部分至少 2 字符，后面跟 :数字 一到两组
            if let range = path.range(of: #":\d+(?::\d+)?$"#, options: .regularExpression) {
                path = String(path[path.startIndex..<range.lowerBound])
            }

            // 展开 ~ 为用户主目录
            if path.hasPrefix("~") {
                path = (path as NSString).expandingTildeInPath
            }

            // 注意：相对路径基于 app 进程 cwd，非终端 cwd，建议选中绝对路径使用
            let exists = FileManager.default.fileExists(atPath: path)
            NSLog("[TermKit] [OpenSel] fileExists(%@) = %@", path, exists ? "true" : "false")
            guard exists else {
                NSSound.beep()
                return
            }

            NSWorkspace.shared.open(URL(fileURLWithPath: path))
        }
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
        case .openSelection:
            handleOpenSelection()
            return
        case .showAddFolder:
            hide()
            window.presentAddFolder { [weak self] path in
                guard let self else { return }
                var next = config
                let expanded = (path as NSString).expandingTildeInPath
                next.folders.append(FolderEntry(title: URL(fileURLWithPath: expanded).lastPathComponent, path: expanded))
                self.configStore.save(next)
                self.applyConfig(next)
                self.onConfigDidChange?(next)
            }
        case .showAddCLI:
            hide()
            window.presentAddCLI { [weak self] entry in
                guard let self else { return }
                var next = config
                next.clis.append(entry)
                self.configStore.save(next)
                self.applyConfig(next)
                self.onConfigDidChange?(next)
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
                self.onConfigDidChange?(next)
            }
        case .disableTemporary:
            disableForOneHour()
        case .disablePermanent:
            disablePermanently()
        case .none:
            hide()
        }
    }

    // MARK: - 关闭快捷键

    /// 暂停快捷键 1 小时后自动恢复
    private func disableForOneHour() {
        hide()
        isTemporarilyDisabled = true
        detector.isEnabled = false
        // 通知 model 刷新 UI（开关需显示 OFF）
        onConfigDidChange?(config)
        NSLog("[TermKit] 快捷键已暂停 1 小时")

        reEnableTimer?.cancel()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + 3600)
        timer.setEventHandler { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.reEnableTimer = nil
                self.isTemporarilyDisabled = false
                // 恢复时重新走 applyConfig 让 detector 状态与 config 一致
                self.applyConfig(self.config)
                self.onConfigDidChange?(self.config)
                NSLog("[TermKit] 快捷键 1 小时暂停已到期，已自动恢复")
            }
        }
        reEnableTimer = timer
        timer.resume()
    }

    /// 取消暂停（用户手动恢复时调用）
    private func cancelTemporaryDisable() {
        isTemporarilyDisabled = false
        reEnableTimer?.cancel()
        reEnableTimer = nil
        NSLog("[TermKit] 用户手动恢复，暂停已取消")
    }

    /// 永久关闭快捷键：修改配置并同步
    private func disablePermanently() {
        hide()
        var next = config
        next.features.enableCmdHoldMenu = false
        configStore.save(next)
        applyConfig(next)
        onConfigDidChange?(next)
        NSLog("[TermKit] 快捷键已永久关闭")
    }
}
