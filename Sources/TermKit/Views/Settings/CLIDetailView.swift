import SwiftUI

/// 单个 CLI 工具的编辑表单（内联编辑风格）
struct CLIDetailView: View {
    @EnvironmentObject private var model: TermKitModel
    let cliIndex: Int
    @State private var isEditingActions = false
    /// 正在拖拽的动作 ID
    @State private var draggingActionID: UUID?
    /// 拖拽悬停的目标位置（插入点索引）
    @State private var dropInsertIndex: Int?

    private var cli: CLIEntry {
        guard model.config.clis.indices.contains(cliIndex) else { return CLIEntry(name: "") }
        return model.config.clis[cliIndex]
    }

    var body: some View {
        Form {
            Section(L10n.CLI.basicInfo) {
                HStack(spacing: 12) {
                    IconPicker(icon: cliBinding(\.icon), defaultIcon: "terminal")
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(L10n.CLI.toolName, text: cliBinding(\.name))
                            .textFieldStyle(.roundedBorder)
                        TextField(L10n.CLI.noteOptional, text: cliBinding(\.note))
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }

            Section {
                if cli.actions.isEmpty {
                    Text(L10n.CLI.noActions)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(Array(cli.actions.enumerated()), id: \.element.id) { idx, action in
                        if isEditingActions {
                            VStack(spacing: 0) {
                                // 插入指示线（当前项之前）
                                if dropInsertIndex == idx {
                                    insertionIndicator
                                }

                                // 编辑模式行
                                HStack(alignment: .center, spacing: 8) {
                                    // 拖拽手柄（加大点击区域）
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(.tertiary)
                                        .frame(width: 32, height: 44)
                                        .contentShape(Rectangle())

                                    // 名称 + 命令输入框（同宽右对齐）
                                    VStack(alignment: .leading, spacing: 8) {
                                        TextField(L10n.CLI.actionName, text: actionBinding(idx, \.title))
                                            .textFieldStyle(.roundedBorder)
                                            .fontWeight(.medium)
                                        TextField(L10n.CLI.command, text: actionBinding(idx, \.command))
                                            .textFieldStyle(.roundedBorder)
                                            .font(.system(.caption, design: .monospaced))
                                    }

                                    // 删除按钮（垂直居中）
                                    Button(role: .destructive) {
                                        deleteAction(at: idx)
                                    } label: {
                                        Image(systemName: "trash")
                                            .frame(width: 24, height: 24)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.borderless)
                                    .help(L10n.CLI.deleteAction)
                                }
                                .padding(.vertical, 4)
                                .opacity(draggingActionID == action.id ? 0.3 : 1.0)
                                .draggable(action.id.uuidString) {
                                    // 拖拽预览：显示动作名称
                                    HStack(spacing: 6) {
                                        Image(systemName: "line.3.horizontal")
                                            .foregroundStyle(.secondary)
                                        Text(action.title)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                                    .onAppear { draggingActionID = action.id }
                                }

                                // （末尾落点由独立区域处理）
                            }
                            .dropDestination(for: String.self) { items, location in
                                handleDrop(items: items, targetIdx: idx)
                            } isTargeted: { targeted in
                                if targeted {
                                    dropInsertIndex = idx
                                } else if dropInsertIndex == idx {
                                    dropInsertIndex = nil
                                }
                            }
                        } else {
                            // 只读模式：纯文本展示
                            VStack(alignment: .leading, spacing: 4) {
                                Text(action.title)
                                    .fontWeight(.medium)
                                Text(action.command)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // 末尾落点区域：拖到列表最后
                if isEditingActions && !cli.actions.isEmpty {
                    VStack(spacing: 0) {
                        if dropInsertIndex == cli.actions.count {
                            insertionIndicator
                        }
                        Color.clear.frame(height: 24)
                    }
                    .dropDestination(for: String.self) { items, _ in
                        handleDrop(items: items, targetIdx: cli.actions.count)
                    } isTargeted: { targeted in
                        if targeted {
                            dropInsertIndex = cli.actions.count
                        } else if dropInsertIndex == cli.actions.count {
                            dropInsertIndex = nil
                        }
                    }
                }

                if isEditingActions {
                    Button {
                        addAction()
                    } label: {
                        Label(L10n.CLI.addAction, systemImage: "plus")
                            .font(.caption)
                    }
                }
            } header: {
                HStack {
                    Text(L10n.CLI.actionList)
                    Spacer()
                    Button(isEditingActions ? L10n.CLI.done : L10n.CLI.edit) {
                        isEditingActions.toggle()
                    }
                    .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - 插入指示线

    private var insertionIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 2)
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
        }
        .padding(.vertical, 4)
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
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
        next.clis[cliIndex].actions.append(CLIAction(title: L10n.CLI.newAction, command: ""))
        model.saveConfig(next)
    }

    private func deleteAction(at index: Int) {
        guard model.config.clis.indices.contains(cliIndex),
              model.config.clis[cliIndex].actions.indices.contains(index) else { return }
        var next = model.config
        next.clis[cliIndex].actions.remove(at: index)
        model.saveConfig(next)
    }

    private func handleDrop(items: [String], targetIdx: Int) -> Bool {
        defer {
            draggingActionID = nil
            dropInsertIndex = nil
        }
        guard let draggedIDString = items.first,
              let draggedID = UUID(uuidString: draggedIDString),
              let fromIdx = cli.actions.firstIndex(where: { $0.id == draggedID }),
              fromIdx != targetIdx else { return false }
        var next = model.config
        let item = next.clis[cliIndex].actions.remove(at: fromIdx)
        let toIdx = targetIdx > fromIdx ? targetIdx - 1 : targetIdx
        next.clis[cliIndex].actions.insert(item, at: min(toIdx, next.clis[cliIndex].actions.count))
        model.saveConfig(next)
        return true
    }
}
