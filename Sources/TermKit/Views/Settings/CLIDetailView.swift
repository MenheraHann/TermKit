import SwiftUI

/// 单个 CLI 工具的编辑表单（内联编辑风格）
struct CLIDetailView: View {
    @EnvironmentObject private var model: TermKitModel
    let cliIndex: Int

    private var cli: CLIEntry {
        guard model.config.clis.indices.contains(cliIndex) else { return CLIEntry(name: "") }
        return model.config.clis[cliIndex]
    }

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("工具名称", text: cliBinding(\.name))
                    .textFieldStyle(.roundedBorder)
            }

            Section {
                if cli.actions.isEmpty {
                    Text("暂无动作")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(Array(cli.actions.enumerated()), id: \.element.id) { idx, action in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "command")
                                    .foregroundStyle(.secondary)
                                TextField("动作名称", text: actionBinding(idx, \.title))
                                    .textFieldStyle(.plain)
                                    .fontWeight(.medium)
                                Spacer()
                                Button(role: .destructive) {
                                    deleteAction(at: idx)
                                } label: {
                                    Image(systemName: "trash")
                                        .frame(width: 28, height: 28)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.borderless)
                                .help("删除此动作")
                            }

                            TextField("命令", text: actionBinding(idx, \.command))
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.caption, design: .monospaced))
                        }
                        .padding(.vertical, 4)
                    }
                    .onMove(perform: moveAction)
                }
            } header: {
                HStack {
                    Text("动作列表")
                    Spacer()
                    Button("添加动作") { addAction() }
                        .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Bindings

    private func cliBinding<T>(_ keyPath: WritableKeyPath<CLIEntry, T>) -> Binding<T> {
        Binding(
            get: { cli[keyPath: keyPath] },
            set: { value in
                guard model.config.clis.indices.contains(cliIndex) else { return }
                var next = model.config
                next.clis[cliIndex][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }

    private func actionBinding(_ actionIdx: Int, _ keyPath: WritableKeyPath<CLIAction, String>) -> Binding<String> {
        Binding(
            get: {
                guard model.config.clis.indices.contains(cliIndex),
                      model.config.clis[cliIndex].actions.indices.contains(actionIdx) else { return "" }
                return model.config.clis[cliIndex].actions[actionIdx][keyPath: keyPath]
            },
            set: { value in
                guard model.config.clis.indices.contains(cliIndex),
                      model.config.clis[cliIndex].actions.indices.contains(actionIdx) else { return }
                var next = model.config
                next.clis[cliIndex].actions[actionIdx][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }

    // MARK: - 动作管理

    private func addAction() {
        guard model.config.clis.indices.contains(cliIndex) else { return }
        var next = model.config
        next.clis[cliIndex].actions.append(CLIAction(title: "新动作", command: ""))
        model.saveConfig(next)
    }

    private func deleteAction(at index: Int) {
        guard model.config.clis.indices.contains(cliIndex),
              model.config.clis[cliIndex].actions.indices.contains(index) else { return }
        var next = model.config
        next.clis[cliIndex].actions.remove(at: index)
        model.saveConfig(next)
    }

    private func moveAction(from source: IndexSet, to destination: Int) {
        guard model.config.clis.indices.contains(cliIndex) else { return }
        var next = model.config
        next.clis[cliIndex].actions.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }
}
