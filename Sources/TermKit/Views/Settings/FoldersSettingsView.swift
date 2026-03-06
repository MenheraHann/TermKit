import SwiftUI
import AppKit

/// 文件夹管理面板：列表 + 排序 + 删除 + 编辑名称 + 添加
struct FoldersSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?

    private var folders: [FolderEntry] { model.config.folders }

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selectedID) {
                ForEach(folders) { folder in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(folder.title)
                                .fontWeight(.medium)
                            Text(abbreviatePath(folder.path))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .tag(folder.id)
                }
                .onMove(perform: moveFolder)
                .onDelete(perform: deleteFolder)
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))

            Divider()

            // 底部工具栏
            HStack(spacing: 4) {
                Button(action: addFolder) {
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

            // 选中行的编辑区域
            if let id = selectedID, let idx = folders.firstIndex(where: { $0.id == id }) {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("名称")
                            .frame(width: 50, alignment: .trailing)
                        TextField("显示名称", text: bindingForTitle(at: idx))
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("路径")
                            .frame(width: 50, alignment: .trailing)
                        Text(folders[idx].path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button("浏览…") { browseFolderPath(at: idx) }
                            .controlSize(.small)
                    }
                }
                .padding(12)
            }
        }
    }

    // MARK: - 操作

    private func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "选择文件夹"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var next = model.config
        let entry = FolderEntry(title: url.lastPathComponent, path: url.path)
        next.folders.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    private func removeSelected() {
        guard let id = selectedID else { return }
        var next = model.config
        next.folders.removeAll { $0.id == id }
        model.saveConfig(next)
        selectedID = nil
    }

    private func moveFolder(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.folders.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }

    private func deleteFolder(at offsets: IndexSet) {
        var next = model.config
        let removing = offsets.map { next.folders[$0].id }
        next.folders.remove(atOffsets: offsets)
        model.saveConfig(next)
        if let id = selectedID, removing.contains(id) { selectedID = nil }
    }

    private func browseFolderPath(at idx: Int) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "选择文件夹"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var next = model.config
        next.folders[idx].path = url.path
        next.folders[idx].title = url.lastPathComponent
        model.saveConfig(next)
    }

    private func bindingForTitle(at idx: Int) -> Binding<String> {
        Binding(
            get: { model.config.folders[idx].title },
            set: { value in
                var next = model.config
                next.folders[idx].title = value
                model.saveConfig(next)
            }
        )
    }

    private func abbreviatePath(_ path: String) -> String {
        let home = NSHomeDirectory()
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}
