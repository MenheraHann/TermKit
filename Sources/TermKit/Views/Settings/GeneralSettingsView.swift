import SwiftUI

/// 通用设置面板
struct GeneralSettingsView: View {
    @EnvironmentObject private var model: TermKitModel

    var body: some View {
        Form {
            Section("快捷菜单") {
                Toggle("启用快捷菜单", isOn: binding(\.features.enableCmdHoldMenu))
                    .toggleStyle(.switch)

                Picker("触发修饰键", selection: binding(\.features.triggerKey)) {
                    ForEach(TriggerModifierKey.allCases, id: \.self) { key in
                        Text(key.displayName).tag(key)
                    }
                }
                .disabled(!model.config.features.enableCmdHoldMenu)
            }

            Section("时间参数") {
                LabeledContent("长按阈值") {
                    HStack {
                        Text("\(model.config.timing.holdThresholdMs) ms")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Stepper("", value: binding(\.timing.holdThresholdMs), in: 150...800, step: 50)
                            .labelsHidden()
                    }
                }

                LabeledContent("剪贴板恢复延迟") {
                    HStack {
                        Text("\(model.config.timing.clipboardRestoreDelayMs) ms")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Stepper("", value: binding(\.timing.clipboardRestoreDelayMs), in: 0...1000, step: 50)
                            .labelsHidden()
                    }
                }
            }

            Section("图片") {
                VStack(alignment: .leading) {
                    Text("保存目录")
                    TextField("路径", text: binding(\.imagePaste.saveDirectory))
                        .textFieldStyle(.roundedBorder)
                }
            }

            Section {
                LabeledContent("配置文件") {
                    Button("在 Finder 中显示") {
                        ConfigStore.openConfigFolderInFinder()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
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
