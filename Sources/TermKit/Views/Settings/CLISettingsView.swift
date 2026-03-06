import SwiftUI

/// CLI 工具管理面板：左侧列表 + 右侧详情
struct CLISettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?

    private var clis: [CLIEntry] { model.config.clis }

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：CLI 列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(clis) { cli in
                        HStack {
                            Image(systemName: "terminal")
                                .foregroundStyle(.secondary)
                            Text(cli.name)
                            Spacer()
                        }
                        .tag(cli.id)
                    }
                    .onMove(perform: moveCLI)
                    .onDelete(perform: deleteCLI)
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
                    .help("添加 CLI 工具")

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
                    Text("选择或创建一个 CLI 工具")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
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
        selectedID = nil              // 先清选中，避免 Binding 越界
        model.saveConfig(next)
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
        if let id = selectedID, removing.contains(id) { selectedID = nil }  // 先清选中
        model.saveConfig(next)
    }
}
