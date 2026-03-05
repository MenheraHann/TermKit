import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: TermKitModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TermKit Settings")
                .font(.headline)

            Text("Implementation follows PRD v2 (Cmd Hold Menu).")
                .font(.callout)
                .foregroundStyle(.secondary)

            Divider()

            Toggle("Enable Hold Menu", isOn: Binding(
                get: { model.config.features.enableCmdHoldMenu },
                set: { value in
                    var next = model.config
                    next.features.enableCmdHoldMenu = value
                    model.saveConfig(next)
                }
            ))

            Picker("Trigger Key", selection: Binding(
                get: { model.config.features.triggerKey },
                set: { value in
                    var next = model.config
                    next.features.triggerKey = value
                    model.saveConfig(next)
                }
            )) {
                ForEach(TriggerModifierKey.allCases, id: \.self) { key in
                    Text(key.displayName).tag(key)
                }
            }
            .disabled(!model.config.features.enableCmdHoldMenu)

            HStack {
                Text("Hold Threshold (ms)")
                Spacer()
                Stepper(
                    value: Binding(
                        get: { model.config.timing.holdThresholdMs },
                        set: { value in
                            var next = model.config
                            next.timing.holdThresholdMs = value
                            model.saveConfig(next)
                        }
                    ),
                    in: 150...800,
                    step: 50
                ) {
                    Text("\(model.config.timing.holdThresholdMs)")
                        .monospacedDigit()
                }
            }

            HStack {
                Text("Clipboard Restore Delay (ms)")
                Spacer()
                Stepper(
                    value: Binding(
                        get: { model.config.timing.clipboardRestoreDelayMs },
                        set: { value in
                            var next = model.config
                            next.timing.clipboardRestoreDelayMs = value
                            model.saveConfig(next)
                        }
                    ),
                    in: 0...1000,
                    step: 50
                ) {
                    Text("\(model.config.timing.clipboardRestoreDelayMs)")
                        .monospacedDigit()
                }
            }

            Divider()

            Button("Open Config Folder") {
                ConfigStore.openConfigFolderInFinder()
            }

            Text("Spec: `TermKit_prd.md`")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 420)
    }
}
