# App Whitelist Feature Design

## 概述

让用户自定义哪些 app 聚焦时可以触发 TermKit 的长按 Cmd 菜单。内置 13 个常见终端/编辑器作为默认值，用户可增删，也可一键重置。

## 数据模型

在 `TermKitConfig` 新增：

```swift
var allowedApps: [AppEntry]  // 默认 = 内置 13 个终端 app
```

```swift
struct AppEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String       // app 名称
    var bundleID: String   // bundle identifier
    var path: String?      // .app 路径（提取图标用，可选）
}
```

首次启动或字段缺失时，自动填充默认列表。

## 默认 App 列表

| App | Bundle ID |
|-----|-----------|
| macOS Terminal | com.apple.Terminal |
| iTerm2 | com.googlecode.iterm2 |
| Warp | dev.warp.Warp-Stable |
| kitty | net.kovidgoyal.kitty |
| Alacritty | org.alacritty |
| Hyper | co.zeit.hyper |
| WezTerm | com.github.wez.wezterm |
| Rio | com.raphaelamorim.rio |
| Ghostty | com.mitchellh.ghostty |
| MacTerm | dev.kdrag0n.MacTerm |
| JetBrains Fleet | com.jetbrains.fleet |
| VS Code | com.microsoft.VSCode |
| Cursor | com.todesktop.230313mzl4w4u92 |

## 设置窗口 UI

新增第 5 个 Tab："应用"（图标 `app.badge.checkmark`）

布局参照 FoldersSettingsView 主-详模式：
- **左侧列表**：app 图标（从 .app 路径提取）+ 名称
- **底部 +/- 按钮**：+ 打开 NSOpenPanel 选 .app 文件，- 删除选中项
- **右上角重置按钮**：恢复为默认 13 个 app，需确认对话框
- **右侧详情**：名称、Bundle ID（只读）、路径（只读）

## NSOpenPanel 配置

- `canChooseFiles = true`，`canChooseDirectories = false`
- `allowedContentTypes = [.application]`
- `directoryURL = /Applications`
- 选中后从 Info.plist 提取 CFBundleIdentifier 和 CFBundleName

## ModifierHoldDetector 集成

去掉硬编码 `supportedBundleIDs`，改为动态读取：

```swift
private static var allowedBundleIDs: Set<String> = []

static func updateAllowedApps(_ apps: [AppEntry]) {
    allowedBundleIDs = Set(apps.map(\.bundleID))
}
```

`isFrontmostAppSupported()` 改为查询 `allowedBundleIDs`。
在 TermKitModel 初始化和 saveConfig 时调用 updateAllowedApps。

## 涉及文件

| 文件 | 改动 |
|------|------|
| TermKitConfig.swift | 新增 AppEntry 结构体 + allowedApps 字段 + 默认值 |
| ModifierHoldDetector.swift | 去掉硬编码，改用动态 allowedBundleIDs |
| TermKitModel.swift | saveConfig/init 时同步 allowedApps 到 detector |
| SettingsView.swift | 新增"应用"Tab |
| AppsSettingsView.swift（新文件）| 白名单管理界面 |
| Localizable.xcstrings | 新增本地化字符串 |
