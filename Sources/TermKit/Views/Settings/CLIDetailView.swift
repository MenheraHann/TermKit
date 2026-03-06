import SwiftUI

/// 单个 CLI 工具的编辑表单
struct CLIDetailView: View {
    @EnvironmentObject private var model: TermKitModel
    let cliIndex: Int

    @State private var selectedActionID: UUID?

    private var cli: CLIEntry { model.config.clis[cliIndex] }

    var body: some View {
        ScrollView {
            Form {
                Section("基本信息") {
                    TextField("名称", text: cliBinding(\.name))
                }

                Section("命令") {
                    TextField("启动命令", text: optionalBinding(\.startCommand), prompt: Text("如 claude"))
                    TextField("继续命令", text: optionalBinding(\.continueCommand), prompt: Text("如 claude --continue"))
                    TextField("恢复命令", text: optionalBinding(\.resumeCommand), prompt: Text("如 claude --resume"))
                }

                Section("标签（菜单中的显示名）") {
                    TextField("启动标签", text: optionalBinding(\.startLabel), prompt: Text("新建对话"))
                    TextField("继续标签", text: optionalBinding(\.continueLabel), prompt: Text("继续上次"))
                    TextField("恢复标签", text: optionalBinding(\.resumeLabel), prompt: Text("恢复对话"))
                }

                Section("自定义动作") {
                    if cli.customActions.isEmpty {
                        Text("暂无自定义动作")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    } else {
                        ForEach(Array(cli.customActions.enumerated()), id: \.element.id) { actionIdx, action in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(action.title).fontWeight(.medium)
                                    Text(action.command)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    removeAction(at: actionIdx)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .onMove(perform: moveAction)
                    }

                    Button(action: addAction) {
                        Label("添加动作", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
        }
    }

    // MARK: - Bindings

    private func cliBinding<T>(_ keyPath: WritableKeyPath<CLIEntry, T>) -> Binding<T> {
        Binding(
            get: { model.config.clis[cliIndex][keyPath: keyPath] },
            set: { value in
                var next = model.config
                next.clis[cliIndex][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }

    /// 将 Optional<String> 字段绑定为非空 String（空字符串 → nil）
    private func optionalBinding(_ keyPath: WritableKeyPath<CLIEntry, String?>) -> Binding<String> {
        Binding(
            get: { model.config.clis[cliIndex][keyPath: keyPath] ?? "" },
            set: { value in
                var next = model.config
                next.clis[cliIndex][keyPath: keyPath] = value.isEmpty ? nil : value
                model.saveConfig(next)
            }
        )
    }

    // MARK: - 动作管理

    private func addAction() {
        var next = model.config
        next.clis[cliIndex].customActions.append(CLIAction(title: "新动作", command: ""))
        model.saveConfig(next)
    }

    private func removeAction(at actionIdx: Int) {
        var next = model.config
        next.clis[cliIndex].customActions.remove(at: actionIdx)
        model.saveConfig(next)
    }

    private func moveAction(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.clis[cliIndex].customActions.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }
}
