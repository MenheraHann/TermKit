import SwiftUI

/// CLI 工具管理面板：左侧列表 + 右侧详情
struct CLISettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteIndex: Int?

    private var clis: [CLIEntry] { model.config.clis }

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：CLI 列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(clis) { cli in
                        HStack {
                            IconView(icon: cli.icon, defaultIcon: "terminal", size: 16)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cli.name)
                                    .fontWeight(.medium)
                                Text(cli.note.isEmpty ? L10n.CLI.actionCount(cli.actions.count) : cli.note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .tag(cli.id)
                    }
                    .onMove(perform: moveCLI)
                    .onDelete(perform: requestDeleteCLI)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                // 统一底部工具栏
                HStack(spacing: 12) {
                    Button(action: addCLI) {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .help(L10n.CLI.addCLI)

                    Button(action: requestRemoveSelected) {
                        Image(systemName: "minus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .disabled(selectedID == nil)
                    .help(L10n.Common.removeSelected)

                    Spacer()
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.bar)
            }
            .frame(width: 280)

            Divider()

            // 右侧：详情编辑
            if let id = selectedID, let idx = clis.firstIndex(where: { $0.id == id }) {
                CLIDetailView(cliIndex: idx)
                    .environmentObject(model)
                    .id(id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(L10n.CLI.selectOrCreateCLI)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .confirmationDialog(
            deleteConfirmTitle,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Common.delete, role: .destructive) { confirmDelete() }
            Button(L10n.Common.cancel, role: .cancel) { pendingDeleteIndex = nil }
        }
    }

    // MARK: - 删除确认

    private var deleteConfirmTitle: String {
        if let idx = pendingDeleteIndex, clis.indices.contains(idx) {
            return L10n.Common.confirmDeleteNamed(clis[idx].name)
        }
        return L10n.Common.confirmDelete
    }

    private func requestRemoveSelected() {
        guard let id = selectedID,
              let idx = clis.firstIndex(where: { $0.id == id }) else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func requestDeleteCLI(at offsets: IndexSet) {
        guard let idx = offsets.first else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func confirmDelete() {
        guard let idx = pendingDeleteIndex, clis.indices.contains(idx) else {
            pendingDeleteIndex = nil
            return
        }
        let removingID = clis[idx].id
        var next = model.config
        next.clis.remove(at: idx)
        if selectedID == removingID { selectedID = nil }
        model.saveConfig(next)
        pendingDeleteIndex = nil
    }

    // MARK: - 操作

    private func addCLI() {
        var next = model.config
        let entry = CLIEntry(name: L10n.CLI.newCLI)
        next.clis.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    private func moveCLI(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.clis.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }
}
