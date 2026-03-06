import SwiftUI

/// CLI 工具管理面板：左侧列表 + 右侧详情
struct CLISettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?

    private var clis: [CLIEntry] { model.config.clis }

    var body: some View {
        HSplitView {
            // 左侧：CLI 列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(clis) { cli in
                        Text(cli.name)
                            .tag(cli.id)
                    }
                    .onMove(perform: moveCLI)
                    .onDelete(perform: deleteCLI)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                HStack(spacing: 4) {
                    Button(action: addCLI) {
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
            .frame(minWidth: 140, idealWidth: 160, maxWidth: 200)

            // 右侧：详情编辑
            if let id = selectedID, let idx = clis.firstIndex(where: { $0.id == id }) {
                CLIDetailView(cliIndex: idx)
                    .environmentObject(model)
                    .id(id) // selectedID 变化时重建视图
            } else {
                VStack {
                    Spacer()
                    Text("选择一个 CLI 工具进行编辑")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 操作

    private func addCLI() {
        var next = model.config
        let entry = CLIEntry(name: "新 CLI 工具")
        next.clis.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    private func removeSelected() {
        guard let id = selectedID else { return }
        var next = model.config
        next.clis.removeAll { $0.id == id }
        model.saveConfig(next)
        selectedID = nil
    }

    private func moveCLI(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.clis.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }

    private func deleteCLI(at offsets: IndexSet) {
        var next = model.config
        let removing = offsets.map { next.clis[$0].id }
        next.clis.remove(atOffsets: offsets)
        model.saveConfig(next)
        if let id = selectedID, removing.contains(id) { selectedID = nil }
    }
}
