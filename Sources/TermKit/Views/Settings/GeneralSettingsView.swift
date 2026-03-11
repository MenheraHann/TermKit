import SwiftUI
import ServiceManagement

/// 通用设置面板
struct GeneralSettingsView: View {
    @EnvironmentObject private var model: TermKitModel

    @State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)

    var body: some View {
        Form {
            Section(L10n.General.language) {
                Picker(L10n.General.interfaceLanguage, selection: binding(\.language)) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
            }

            Section {
                Toggle(L10n.General.launchAtLogin, isOn: Binding(
                    get: { launchAtLogin },
                    set: { newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                            launchAtLogin = newValue
                        } catch {
                            NSLog("[TermKit] 开机自启动设置失败: %@", error.localizedDescription)
                            launchAtLogin = (SMAppService.mainApp.status == .enabled)
                        }
                    }
                ))
                .toggleStyle(.switch)
            }

            Section(L10n.General.quickMenu) {
                Toggle(L10n.MenuBar.enableQuickMenu, isOn: Binding(
                    get: { model.config.features.enableCmdHoldMenu && !model.menu.isTemporarilyDisabled },
                    set: { value in
                        var next = model.config
                        next.features.enableCmdHoldMenu = value
                        model.saveConfig(next)
                    }
                ))
                    .toggleStyle(.switch)

                Picker(L10n.General.triggerKey, selection: binding(\.features.triggerKey)) {
                    ForEach(TriggerModifierKey.allCases, id: \.self) { key in
                        Text(key.displayName).tag(key)
                    }
                }
                .disabled(!model.config.features.enableCmdHoldMenu)
            }

            Section(L10n.General.timingParameters) {
                LabeledContent(L10n.General.holdThreshold) {
                    HStack {
                        Text("\(model.config.timing.holdThresholdMs) ms")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Stepper("", value: binding(\.timing.holdThresholdMs), in: 0...500, step: 100)
                            .labelsHidden()
                    }
                }

                LabeledContent(L10n.General.clipboardRestoreDelay) {
                    HStack {
                        Text("\(model.config.timing.clipboardRestoreDelayMs) ms")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Stepper("", value: binding(\.timing.clipboardRestoreDelayMs), in: 0...1000, step: 50)
                            .labelsHidden()
                    }
                }
            }

            Section(L10n.General.images) {
                LabeledContent(L10n.General.saveDirectory) {
                    HStack {
                        Text(abbreviatePath(model.config.imagePaste.saveDirectory))
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button(L10n.Common.choose) { browseImageSaveDirectory() }
                            .controlSize(.small)
                    }
                }
            }

            Section {
                LabeledContent(L10n.General.configFile) {
                    Button(L10n.General.showInFinder) {
                        ConfigStore.openConfigFolderInFinder()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - 文件夹选择

    private func browseImageSaveDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = L10n.General.chooseSaveDirectory
        // 尝试定位到当前目录
        let current = (model.config.imagePaste.saveDirectory as NSString).expandingTildeInPath
        panel.directoryURL = URL(fileURLWithPath: current)
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var next = model.config
        next.imagePaste.saveDirectory = url.path
        model.saveConfig(next)
    }

    /// 通用 Binding 工厂：读取 config 的 keyPath，写入时保存
    private func binding<T>(_ keyPath: WritableKeyPath<TermKitConfig, T>) -> Binding<T> {
        Binding(
            get: { model.config[keyPath: keyPath] },
            set: { value in
                var next = model.config
                next[keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }
}
