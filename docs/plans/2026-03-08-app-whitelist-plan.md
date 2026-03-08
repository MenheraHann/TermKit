# App Whitelist Implementation Plan

**Goal:** Let users customize which apps trigger TermKit's hold-menu, with a settings UI tab for managing the whitelist.

**Architecture:** New `AppEntry` model stored in `TermKitConfig.allowedApps`. `ModifierHoldDetector` reads from a dynamic `Set<String>` synced via `applyConfig`. New SwiftUI tab mirrors FoldersSettingsView pattern.

**Tech Stack:** Swift, SwiftUI, AppKit (NSOpenPanel), NSWorkspace

---

### Task 1: Add AppEntry model and allowedApps to TermKitConfig

**Files:**
- Modify: `Sources/TermKit/Models/TermKitConfig.swift`

**Step 1: Add AppEntry struct after FolderEntry (line ~134)**

```swift
struct AppEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String       // app 显示名称
    var bundleID: String   // bundle identifier

    init(id: UUID = UUID(), name: String, bundleID: String) {
        self.id = id
        self.name = name
        self.bundleID = bundleID
    }

    /// 内置默认白名单（终端 + 内置终端的编辑器）
    static let defaultApps: [AppEntry] = [
        AppEntry(name: "Terminal", bundleID: "com.apple.Terminal"),
        AppEntry(name: "iTerm2", bundleID: "com.googlecode.iterm2"),
        AppEntry(name: "Warp", bundleID: "dev.warp.Warp-Stable"),
        AppEntry(name: "kitty", bundleID: "net.kovidgoyal.kitty"),
        AppEntry(name: "Alacritty", bundleID: "org.alacritty"),
        AppEntry(name: "Hyper", bundleID: "co.zeit.hyper"),
        AppEntry(name: "WezTerm", bundleID: "com.github.wez.wezterm"),
        AppEntry(name: "Rio", bundleID: "com.raphaelamorim.rio"),
        AppEntry(name: "Ghostty", bundleID: "com.mitchellh.ghostty"),
        AppEntry(name: "MacTerm", bundleID: "dev.kdrag0n.MacTerm"),
        AppEntry(name: "JetBrains Fleet", bundleID: "com.jetbrains.fleet"),
        AppEntry(name: "VS Code", bundleID: "com.microsoft.VSCode"),
        AppEntry(name: "Cursor", bundleID: "com.todesktop.230313mzl4w4u92"),
    ]
}
```

**Step 2: Add `allowedApps` field to TermKitConfig**

Add to struct properties (after `language`):
```swift
var allowedApps: [AppEntry]
```

Update `defaultValue`:
```swift
static var defaultValue: TermKitConfig { TermKitConfig(
    ...existing fields...,
    language: .zhHans,
    allowedApps: AppEntry.defaultApps
) }
```

Update `init(...)` — add parameter with default:
```swift
init(
    ...existing params...,
    language: AppLanguage = .zhHans,
    allowedApps: [AppEntry] = AppEntry.defaultApps
) {
    ...existing assignments...,
    self.allowedApps = allowedApps
}
```

Update `init(from decoder:)` — backward-compatible:
```swift
allowedApps = try container.decodeIfPresent([AppEntry].self, forKey: .allowedApps) ?? AppEntry.defaultApps
```

**Step 3: Build to verify**

Run: `swift build -c release 2>&1 | tail -5`
Expected: Build complete

**Step 4: Commit**

```
feat: add AppEntry model and allowedApps config field
```

---

### Task 2: Replace hardcoded supportedBundleIDs in ModifierHoldDetector

**Files:**
- Modify: `Sources/TermKit/Input/ModifierHoldDetector.swift`

**Step 1: Replace the static set + method with dynamic version**

Remove the entire `// MARK: - 支持的 app 检测` section (the `supportedBundleIDs` set and `isFrontmostAppSupported()` method). Replace with:

```swift
// MARK: - 支持的 app 检测

/// 动态白名单，由 applyConfig 同步更新
private static var allowedBundleIDs: Set<String> = Set(AppEntry.defaultApps.map(\.bundleID))

/// 从 config 更新白名单
static func updateAllowedApps(_ apps: [AppEntry]) {
    allowedBundleIDs = Set(apps.map(\.bundleID))
}

/// 检查当前前台 app 是否在白名单中
private static func isFrontmostAppSupported() -> Bool {
    guard let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else {
        return false
    }
    return allowedBundleIDs.contains(bundleID)
}
```

**Step 2: Build to verify**

Run: `swift build -c release 2>&1 | tail -5`
Expected: Build complete

**Step 3: Commit**

```
refactor: ModifierHoldDetector uses dynamic app whitelist
```

---

### Task 3: Wire applyConfig to sync allowedApps

**Files:**
- Modify: `Sources/TermKit/Menu/CmdHoldMenuCoordinator.swift`

**Step 1: Add sync call in applyConfig method**

In `applyConfig(_ config:)`, after `detector.triggerKey = config.features.triggerKey`, add:

```swift
ModifierHoldDetector.updateAllowedApps(config.allowedApps)
```

**Step 2: Build to verify**

Run: `swift build -c release 2>&1 | tail -5`
Expected: Build complete

**Step 3: Commit**

```
feat: sync allowedApps to detector via applyConfig
```

---

### Task 4: Add L10n strings for Apps tab

**Files:**
- Modify: `Sources/TermKit/L10n/L10n.swift`

**Step 1: Add `apps` key to `L10n.Settings` enum**

Follow the existing pattern (9-language switch). Add after the last existing key in `Settings`:

```swift
static var apps: String {
    switch L10n.current {
    case .zhHans: return "应用"
    case .zhHant: return "應用"
    case .en:     return "Apps"
    case .ja:     return "アプリ"
    case .ko:     return "앱"
    case .es:     return "Apps"
    case .fr:     return "Apps"
    case .de:     return "Apps"
    case .pt:     return "Apps"
    }
}
```

**Step 2: Add new `L10n.Apps` enum**

Add a new enum after the `Folders` enum block, with these keys:

```swift
enum Apps {
    static var addApp: String {
        switch L10n.current {
        case .zhHans: return "添加应用"
        case .zhHant: return "新增應用"
        case .en:     return "Add App"
        case .ja:     return "アプリを追加"
        case .ko:     return "앱 추가"
        case .es:     return "Agregar app"
        case .fr:     return "Ajouter une app"
        case .de:     return "App hinzufügen"
        case .pt:     return "Adicionar app"
        }
    }

    static var selectOrAddApp: String {
        switch L10n.current {
        case .zhHans: return "选择或添加一个应用"
        case .zhHant: return "選擇或新增一個應用"
        case .en:     return "Select or add an app"
        case .ja:     return "アプリを選択または追加"
        case .ko:     return "앱을 선택하거나 추가하세요"
        case .es:     return "Selecciona o agrega una app"
        case .fr:     return "Sélectionnez ou ajoutez une app"
        case .de:     return "App auswählen oder hinzufügen"
        case .pt:     return "Selecione ou adicione um app"
        }
    }

    static var chooseApp: String {
        switch L10n.current {
        case .zhHans: return "选择应用"
        case .zhHant: return "選擇應用"
        case .en:     return "Choose App"
        case .ja:     return "アプリを選択"
        case .ko:     return "앱 선택"
        case .es:     return "Elegir app"
        case .fr:     return "Choisir une app"
        case .de:     return "App auswählen"
        case .pt:     return "Escolher app"
        }
    }

    static var bundleID: String {
        switch L10n.current {
        case .zhHans: return "Bundle ID"
        case .zhHant: return "Bundle ID"
        case .en:     return "Bundle ID"
        case .ja:     return "Bundle ID"
        case .ko:     return "Bundle ID"
        case .es:     return "Bundle ID"
        case .fr:     return "Bundle ID"
        case .de:     return "Bundle ID"
        case .pt:     return "Bundle ID"
        }
    }

    static var appInfo: String {
        switch L10n.current {
        case .zhHans: return "应用信息"
        case .zhHant: return "應用資訊"
        case .en:     return "App Info"
        case .ja:     return "アプリ情報"
        case .ko:     return "앱 정보"
        case .es:     return "Información de la app"
        case .fr:     return "Infos de l'app"
        case .de:     return "App-Info"
        case .pt:     return "Informações do app"
        }
    }

    static var resetToDefaults: String {
        switch L10n.current {
        case .zhHans: return "重置为默认"
        case .zhHant: return "重置為預設"
        case .en:     return "Reset to Defaults"
        case .ja:     return "デフォルトに戻す"
        case .ko:     return "기본값으로 재설정"
        case .es:     return "Restablecer"
        case .fr:     return "Réinitialiser"
        case .de:     return "Zurücksetzen"
        case .pt:     return "Redefinir"
        }
    }

    static var confirmReset: String {
        switch L10n.current {
        case .zhHans: return "确定要重置为默认应用列表吗？"
        case .zhHant: return "確定要重置為預設應用列表嗎？"
        case .en:     return "Reset to default app list?"
        case .ja:     return "デフォルトのアプリリストに戻しますか？"
        case .ko:     return "기본 앱 목록으로 재설정하시겠습니까?"
        case .es:     return "¿Restablecer la lista de apps predeterminada?"
        case .fr:     return "Réinitialiser la liste d'apps par défaut ?"
        case .de:     return "Auf Standard-App-Liste zurücksetzen?"
        case .pt:     return "Redefinir para a lista padrão de apps?"
        }
    }

    static var appAlreadyExists: String {
        switch L10n.current {
        case .zhHans: return "该应用已在列表中"
        case .zhHant: return "該應用已在列表中"
        case .en:     return "This app is already in the list"
        case .ja:     return "このアプリは既にリストにあります"
        case .ko:     return "이 앱은 이미 목록에 있습니다"
        case .es:     return "Esta app ya está en la lista"
        case .fr:     return "Cette app est déjà dans la liste"
        case .de:     return "Diese App ist bereits in der Liste"
        case .pt:     return "Este app já está na lista"
        }
    }
}
```

**Step 3: Build to verify**

Run: `swift build -c release 2>&1 | tail -5`
Expected: Build complete

**Step 4: Commit**

```
feat: add L10n strings for Apps settings tab
```

---

### Task 5: Create AppsSettingsView

**Files:**
- Create: `Sources/TermKit/Views/Settings/AppsSettingsView.swift`

**Step 1: Create the view file**

Mirror the FoldersSettingsView pattern. Key differences:
- NSOpenPanel opens `/Applications`, allows `.app` files only
- Reads bundle ID from selected app's `Info.plist`
- Right side shows app name + bundle ID (both read-only)
- Right top has a "Reset to Defaults" button
- App icon extracted via `NSWorkspace.shared.icon(forFile:)`

```swift
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
        let bundleURL = url
        guard let bundle = Bundle(url: bundleURL),
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
        // 通过 bundle ID 找到 app 路径，提取图标
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return NSWorkspace.shared.icon(for: .application)
    }
}
```

**Step 2: Build to verify**

Run: `swift build -c release 2>&1 | tail -5`
Expected: Build complete

**Step 3: Commit**

```
feat: add AppsSettingsView for app whitelist management
```

---

### Task 6: Add Apps tab to SettingsView

**Files:**
- Modify: `Sources/TermKit/Views/Settings/SettingsView.swift`

**Step 1: Add the new tab**

In the `Group` switch, add case 4 before `default`:
```swift
case 0: GeneralSettingsView().environmentObject(model)
case 1: FoldersSettingsView().environmentObject(model)
case 2: CLISettingsView().environmentObject(model)
case 3: CommandTemplatesSettingsView().environmentObject(model)
default: AppsSettingsView().environmentObject(model)
```

In the Picker, add a new Label:
```swift
Label(L10n.Settings.apps, systemImage: "app.badge.checkmark").tag(4)
```

**Step 2: Build and install to verify**

Run: `make uninstall && make install`
Expected: Build complete, app restarts with new "应用" tab visible

**Step 3: Commit**

```
feat: add Apps tab to settings window
```

---

### Task 7: Manual verification & final commit

**Verification checklist:**
1. Open settings → "应用" tab visible with 13 default apps
2. Click an app → right side shows name + bundle ID
3. Click "+" → NSOpenPanel opens to /Applications, only .app files visible
4. Select an app (e.g. Safari) → added to list with correct icon and name
5. Select the new app → delete with "-" → removed
6. Click "重置为默认" → list restores to 13 defaults
7. Switch to Terminal → long-press Cmd → menu appears
8. Switch to Finder → long-press Cmd → no menu
9. Add Finder to whitelist → switch to Finder → long-press Cmd → menu appears
10. Remove Finder from whitelist → switch to Finder → long-press Cmd → no menu
