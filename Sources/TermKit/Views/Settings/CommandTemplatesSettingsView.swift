import SwiftUI

/// 命令模板管理面板：左侧列表 + 右侧详情
struct CommandTemplatesSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?

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
                    .onDelete(perform: deleteTemplate)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                HStack(spacing: 12) {
                    Button(action: addTemplate) {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .help("添加模板")

                    Button(action: removeSelected) {
                        Image(systemName: "minus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .disabled(selectedID == nil)
                    .help("移除选中")

                    Spacer()
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.bar)
            }
            .frame(maxWidth: .infinity)

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
                    Text("选择或创建一个命令模板")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
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
        selectedID = nil              // 先清选中，避免 Binding 越界
        model.saveConfig(next)
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
        if let id = selectedID, removing.contains(id) { selectedID = nil }  // 先清选中
        model.saveConfig(next)
    }
}
