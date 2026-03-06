import SwiftUI
import AppKit

/// 文件夹管理面板：列表 + 排序 + 删除 + 编辑名称 + 添加
struct FoldersSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?

    private var folders: [FolderEntry] { model.config.folders }

    var body: some View {
        VStack(spacing: 0) {
            // 列表区域
            List(selection: $selectedID) {
                ForEach(folders) { folder in
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(folder.title)
                                .fontWeight(.medium)
                            Text(abbreviatePath(folder.path))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .tag(folder.id)
                }
                .onMove(perform: moveFolder)
                .onDelete(perform: deleteFolder)
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))

            // 底部操作栏 + 编辑区
            VStack(spacing: 0) {
                Divider()

                // 工具栏
                HStack(spacing: 12) {
                    Button(action: addFolder) {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .help("添加文件夹")

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
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.bar)

                // 选中项编辑详情
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
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button("修改…") { browseFolderPath(at: idx) }
                                .controlSize(.small)
                        }
                    }
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor))
                }
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
        selectedID = nil              // 先清选中，避免 Binding 越界
        model.saveConfig(next)
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
        if let id = selectedID, removing.contains(id) { selectedID = nil }  // 先清选中
        model.saveConfig(next)
    }

    private func browseFolderPath(at idx: Int) {
        guard model.config.folders.indices.contains(idx) else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "修改路径"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var next = model.config
        next.folders[idx].path = url.path
        // 只有当名称和旧路径最后一部分一样时才自动更新名称
        if next.folders[idx].title == URL(fileURLWithPath: model.config.folders[idx].path).lastPathComponent {
            next.folders[idx].title = url.lastPathComponent
        }
        model.saveConfig(next)
    }

    private func bindingForTitle(at idx: Int) -> Binding<String> {
        Binding(
            get: {
                guard model.config.folders.indices.contains(idx) else { return "" }
                return model.config.folders[idx].title
            },
            set: { value in
                guard model.config.folders.indices.contains(idx) else { return }
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
