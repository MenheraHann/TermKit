import SwiftUI
import AppKit

/// 文件夹管理面板：左侧列表 + 右侧详情（与 CLISettingsView 布局一致）
struct FoldersSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteIndex: Int?

    private var folders: [FolderEntry] { model.config.folders }

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：文件夹列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(folders) { folder in
                        HStack {
                            IconView(icon: folder.icon, defaultIcon: "folder.fill", size: 16)
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
                    .onDelete(perform: requestDeleteFolder)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                // 底部工具栏
                HStack(spacing: 12) {
                    Button(action: addFolder) {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .help(L10n.Folders.addFolder)

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
            if let id = selectedID, let idx = folders.firstIndex(where: { $0.id == id }) {
                Form {
                    Section {
                        HStack(spacing: 12) {
                            IconPicker(icon: bindingForIcon(at: idx), defaultIcon: "folder.fill")
                            TextField(L10n.Folders.displayName, text: bindingForTitle(at: idx))
                        }
                    } header: {
                        Text(L10n.Folders.name)
                    }

                    Section {
                        LabeledContent(L10n.Folders.path) {
                            Text(folders[idx].path)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Button(L10n.Common.change) { browseFolderPath(at: idx) }
                            .controlSize(.small)
                    } header: {
                        Text(L10n.Folders.location)
                    }
                }
                .formStyle(.grouped)
                .id(id)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(L10n.Folders.selectOrAddFolder)
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
        if let idx = pendingDeleteIndex, folders.indices.contains(idx) {
            return L10n.Common.confirmDeleteNamed(folders[idx].title)
        }
        return L10n.Common.confirmDelete
    }

    private func requestRemoveSelected() {
        guard let id = selectedID,
              let idx = folders.firstIndex(where: { $0.id == id }) else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func requestDeleteFolder(at offsets: IndexSet) {
        guard let idx = offsets.first else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func confirmDelete() {
        guard let idx = pendingDeleteIndex, folders.indices.contains(idx) else {
            pendingDeleteIndex = nil
            return
        }
        let removingID = folders[idx].id
        var next = model.config
        next.folders.remove(at: idx)
        if selectedID == removingID { selectedID = nil }
        model.saveConfig(next)
        pendingDeleteIndex = nil
    }

    // MARK: - 操作

    private func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = L10n.Folders.chooseFolder
        guard panel.runModal() == .OK, let url = panel.url else { return }
        // 去重：路径已存在则直接选中，不重复添加
        if let existing = model.config.folders.first(where: { $0.path == url.path }) {
            selectedID = existing.id
            return
        }
        var next = model.config
        let entry = FolderEntry(title: url.lastPathComponent, path: url.path)
        next.folders.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    private func moveFolder(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.folders.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }

    private func browseFolderPath(at idx: Int) {
        guard model.config.folders.indices.contains(idx) else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = L10n.Folders.changePath
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var next = model.config
        next.folders[idx].path = url.path
        // 只有当名称和旧路径最后一部分一样时才自动更新名称
        if next.folders[idx].title == URL(fileURLWithPath: model.config.folders[idx].path).lastPathComponent {
            next.folders[idx].title = url.lastPathComponent
        }
        model.saveConfig(next)
    }

    private func bindingForIcon(at idx: Int) -> Binding<String?> {
        Binding(
            get: {
                guard model.config.folders.indices.contains(idx) else { return nil }
                return model.config.folders[idx].icon
            },
            set: { value in
                guard model.config.folders.indices.contains(idx) else { return }
                var next = model.config
                next.folders[idx].icon = value
                model.saveConfig(next)
            }
        )
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

}
