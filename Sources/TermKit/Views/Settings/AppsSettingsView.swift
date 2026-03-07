import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// 应用白名单管理面板：左侧列表 + 右侧详情
struct AppsSettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedID: UUID?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteIndex: Int?
    @State private var showResetConfirm = false

    private var apps: [AppEntry] { model.config.allowedApps }

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：应用列表
            VStack(spacing: 0) {
                List(selection: $selectedID) {
                    ForEach(apps) { app in
                        HStack(spacing: 8) {
                            AppIconView(bundleID: app.bundleID, size: 20)
                            Text(app.name)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        .tag(app.id)
                    }
                    .onMove(perform: moveApp)
                    .onDelete(perform: requestDeleteApp)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))

                Divider()

                // 底部工具栏
                HStack(spacing: 12) {
                    Button(action: addApp) {
                        Image(systemName: "plus")
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .help(L10n.Apps.addApp)

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

            // 右侧：详情
            if let id = selectedID, let idx = apps.firstIndex(where: { $0.id == id }) {
                VStack(alignment: .leading, spacing: 0) {
                    // 右上角重置按钮
                    HStack {
                        Spacer()
                        Button(action: { showResetConfirm = true }) {
                            Label(L10n.Apps.resetToDefaults, systemImage: "arrow.counterclockwise")
                        }
                        .controlSize(.small)
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }

                    Form {
                        Section {
                            HStack(spacing: 12) {
                                AppIconView(bundleID: apps[idx].bundleID, size: 32)
                                Text(apps[idx].name)
                                    .font(.title3.weight(.medium))
                            }
                        } header: {
                            Text(L10n.Apps.appInfo)
                        }

                        Section {
                            LabeledContent(L10n.Apps.bundleID) {
                                Text(apps[idx].bundleID)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .formStyle(.grouped)
                }
                .id(id)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(L10n.Apps.selectOrAddApp)
                        .foregroundStyle(.secondary)

                    // 无选中时也显示重置按钮
                    Button(action: { showResetConfirm = true }) {
                        Label(L10n.Apps.resetToDefaults, systemImage: "arrow.counterclockwise")
                    }
                    .controlSize(.small)
                    .padding(.top, 8)
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
        .confirmationDialog(
            L10n.Apps.confirmReset,
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Apps.resetToDefaults, role: .destructive) { resetToDefaults() }
            Button(L10n.Common.cancel, role: .cancel) {}
        }
    }

    // MARK: - 删除确认

    private var deleteConfirmTitle: String {
        if let idx = pendingDeleteIndex, apps.indices.contains(idx) {
            return L10n.Common.confirmDeleteNamed(apps[idx].name)
        }
        return L10n.Common.confirmDelete
    }

    private func requestRemoveSelected() {
        guard let id = selectedID,
              let idx = apps.firstIndex(where: { $0.id == id }) else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func requestDeleteApp(at offsets: IndexSet) {
        guard let idx = offsets.first else { return }
        pendingDeleteIndex = idx
        showDeleteConfirm = true
    }

    private func confirmDelete() {
        guard let idx = pendingDeleteIndex, apps.indices.contains(idx) else {
            pendingDeleteIndex = nil
            return
        }
        let removingID = apps[idx].id
        var next = model.config
        next.allowedApps.remove(at: idx)
        if selectedID == removingID { selectedID = nil }
        model.saveConfig(next)
        pendingDeleteIndex = nil
    }

    // MARK: - 添加应用

    private func addApp() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.prompt = L10n.Apps.chooseApp

        guard panel.runModal() == .OK, let url = panel.url else { return }

        // 从 .app bundle 读取 Info.plist
        guard let bundle = Bundle(url: url),
              let bundleID = bundle.bundleIdentifier else {
            NSLog("[TermKit] AppsSettingsView: 无法读取 bundle identifier from %@", url.path)
            return
        }

        // 去重
        if let existing = model.config.allowedApps.first(where: { $0.bundleID == bundleID }) {
            selectedID = existing.id
            return
        }

        let appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? url.deletingPathExtension().lastPathComponent

        var next = model.config
        let entry = AppEntry(name: appName, bundleID: bundleID)
        next.allowedApps.append(entry)
        model.saveConfig(next)
        selectedID = entry.id
    }

    // MARK: - 移动 & 重置

    private func moveApp(from source: IndexSet, to destination: Int) {
        var next = model.config
        next.allowedApps.move(fromOffsets: source, toOffset: destination)
        model.saveConfig(next)
    }

    private func resetToDefaults() {
        var next = model.config
        next.allowedApps = AppEntry.defaultApps
        model.saveConfig(next)
        selectedID = nil
    }
}

// MARK: - App 图标视图

/// 根据 bundle ID 显示 app 图标，找不到则显示通用图标
struct AppIconView: View {
    let bundleID: String
    let size: CGFloat

    var body: some View {
        Image(nsImage: appIcon)
            .resizable()
            .frame(width: size, height: size)
    }

    private var appIcon: NSImage {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return NSWorkspace.shared.icon(for: .application)
    }
}
