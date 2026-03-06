import SwiftUI

/// 命令模板管理面板：左侧列表 + 右侧详情
struct CommandTemplatesSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?

    private var templates: [CommandTemplate] { model.config.commandTemplates }

    var body: some View {
        HSplitView {
            // 左侧：模板列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(templates) { tmpl in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tmpl.name)
                                .fontWeight(.medium)
                            Text(tmpl.command)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .tag(tmpl.id)
                    }
                    .onMove(perform: moveTemplate)
                    .onDelete(perform: deleteTemplate)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                HStack(spacing: 4) {
                    Button(action: addTemplate) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)

                    Button(action: removeSelected) {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(.borderless)
                    .disabled(selectedID == nil)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .frame(minWidth: 140, idealWidth: 180, maxWidth: 220)

            // 右侧：详情编辑
            if let id = selectedID, let idx = templates.firstIndex(where: { $0.id == id }) {
                CommandTemplateDetailView(templateIndex: idx)
                    .environmentObject(model)
                    .id(id)
            } else {
                VStack {
                    Spacer()
                    Text("选择一个模板进行编辑")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 操作

    private func addTemplate() {
        var next = model.config
        let entry = CommandTemplate(name: "新模板", command: "")
        next.commandTemplates.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    private func removeSelected() {
        guard let id = selectedID else { return }
        var next = model.config
        next.commandTemplates.removeAll { $0.id == id }
        model.saveConfig(next)
        selectedID = nil
    }

    private func moveTemplate(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.commandTemplates.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }

    private func deleteTemplate(at offsets: IndexSet) {
        var next = model.config
        let removing = offsets.map { next.commandTemplates[$0].id }
        next.commandTemplates.remove(atOffsets: offsets)
        model.saveConfig(next)
        if let id = selectedID, removing.contains(id) { selectedID = nil }
    }
}
