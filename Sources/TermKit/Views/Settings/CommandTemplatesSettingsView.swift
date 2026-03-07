import SwiftUI

/// 命令模板管理面板：左侧列表 + 右侧详情
struct CommandTemplatesSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteIndex: Int?

    private var templates: [CommandTemplate] { model.config.commandTemplates }

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：模板列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(templates) { tmpl in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tmpl.name)
                                .fontWeight(.medium)
                            Text(tmpl.command)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .padding(.vertical, 2)
                        .tag(tmpl.id)
                    }
                    .onMove(perform: moveTemplate)
                    .onDelete(perform: requestDeleteTemplate)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                HStack(spacing: 12) {
                    Button(action: addTemplate) {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .help(L10n.Templates.addTemplate)

                    Button(action: requestRemoveSelected) {
                        Image(systemName: "minus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .disabled(selectedID == nil)
                    .help(L10n.Common.removeSelected)

                    Spacer()

                    Button(action: moveSelectedUp) {
                        Image(systemName: "chevron.up")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .disabled(!canMoveUp)
                    .help(L10n.Templates.moveUp)

                    Button(action: moveSelectedDown) {
                        Image(systemName: "chevron.down")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .disabled(!canMoveDown)
                    .help(L10n.Templates.moveDown)
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.bar)
            }
            .frame(width: 280)

            Divider()

            // 右侧：详情编辑
            if let id = selectedID, let idx = templates.firstIndex(where: { $0.id == id }) {
                CommandTemplateDetailView(templateIndex: idx)
                    .environmentObject(model)
                    .id(id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(L10n.Templates.selectOrCreateTemplate)
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
        if let idx = pendingDeleteIndex, templates.indices.contains(idx) {
            return L10n.Common.confirmDeleteNamed(templates[idx].name)
        }
        return L10n.Common.confirmDelete
    }

    private func requestRemoveSelected() {
        guard let id = selectedID,
              let idx = templates.firstIndex(where: { $0.id == id }) else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func requestDeleteTemplate(at offsets: IndexSet) {
        guard let idx = offsets.first else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func confirmDelete() {
        guard let idx = pendingDeleteIndex, templates.indices.contains(idx) else {
            pendingDeleteIndex = nil
            return
        }
        let removingID = templates[idx].id
        var next = model.config
        next.commandTemplates.remove(at: idx)
        if selectedID == removingID { selectedID = nil }
        model.saveConfig(next)
        pendingDeleteIndex = nil
    }

    // MARK: - 操作

    private func addTemplate() {
        var next = model.config
        let entry = CommandTemplate(name: L10n.Templates.newTemplate, command: "")
        next.commandTemplates.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    private func moveTemplate(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.commandTemplates.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }

    // MARK: - 排序

    private var selectedIndex: Int? {
        guard let id = selectedID else { return nil }
        return templates.firstIndex(where: { $0.id == id })
    }

    private var canMoveUp: Bool {
        guard let idx = selectedIndex else { return false }
        return idx > 0
    }

    private var canMoveDown: Bool {
        guard let idx = selectedIndex else { return false }
        return idx < templates.count - 1
    }

    private func moveSelectedUp() {
        guard let idx = selectedIndex, idx > 0 else { return }
        var next = model.config
        next.commandTemplates.swapAt(idx, idx - 1)
        model.saveConfig(next)
    }

    private func moveSelectedDown() {
        guard let idx = selectedIndex, idx < templates.count - 1 else { return }
        var next = model.config
        next.commandTemplates.swapAt(idx, idx + 1)
        model.saveConfig(next)
    }
}
