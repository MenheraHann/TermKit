import SwiftUI

/// 通用设置面板
struct GeneralSettingsView: View {
    @EnvironmentObject private var model: TermKitModel

    var body: some View {
        Form {
            Section("快捷菜单") {
                Toggle("启用快捷菜单", isOn: binding(\.features.enableCmdHoldMenu))

                Picker("触发键", selection: binding(\.features.triggerKey)) {
                    ForEach(TriggerModifierKey.allCases, id: \.self) { key in
                        Text(key.displayName).tag(key)
                    }
                }
                .disabled(!model.config.features.enableCmdHoldMenu)
            }

            Section("时间参数") {
                HStack {
                    Text("长按阈值")
                    Spacer()
                    Stepper(
                        value: binding(\.timing.holdThresholdMs),
                        in: 150...800,
                        step: 50
                    ) {
                        Text("\(model.config.timing.holdThresholdMs) ms")
                            .monospacedDigit()
                    }
                }

                HStack {
                    Text("剪贴板恢复延迟")
                    Spacer()
                    Stepper(
                        value: binding(\.timing.clipboardRestoreDelayMs),
                        in: 0...1000,
                        step: 50
                    ) {
                        Text("\(model.config.timing.clipboardRestoreDelayMs) ms")
                            .monospacedDigit()
                    }
                }
            }

            Section("图片") {
                HStack {
                    Text("图片保存目录")
                    Spacer()
                    TextField("路径", text: binding(\.imagePaste.saveDirectory))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 250)
                }
            }

            Section {
                Button("打开配置文件夹") {
                    ConfigStore.openConfigFolderInFinder()
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
