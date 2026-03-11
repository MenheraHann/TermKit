<p align="center">
  <img src="assets/banner.png" alt="TermKit Banner" width="100%" />
</p>

<p align="center">
  <b>A command palette for your AI CLI workflow on macOS.</b><br/>
  长按 ⌘ → 弹出分层菜单 → 选择 → 松开 ⌘ → 命令粘贴到终端
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#features">Features</a> •
  <a href="#keyboard-shortcuts">Shortcuts</a> •
  <a href="#settings">Settings</a> •
  <a href="LICENSE">License</a>
</p>

---

## Why TermKit?

从 VS Code 插件转到 CLI，上手并不轻松。打开文件要手动输路径，粘贴图片得先存本地，删文字也没有光标选区——很多 GUI 里一键搞定的操作，在终端都要手动完成。

但 CLI 有它的好：独立窗口，不与浏览器、IDE 混杂，多项目并行时不用在标签页里来回切换。

**TermKit 让终端更好用——把重复操作压缩到一次按键里。**

---

## Features

### Hierarchical Menu & CLI Launcher

一级菜单列出文件夹、CLI 工具、命令模板。逐层选择后生成完整命令：

```
cd '/Users/you/Projects/MyApp' && claude --resume
```
<img src="assets/打开文件演示.gif" alt="Open File Demo" width="100%" />

开箱即有 Claude Code、Gemini CLI、OpenAI Codex、OpenCode、OpenClaw、GitHub Copilot CLI 的预置配置，每个 CLI 的常用操作都已预设好，也可以随意增删改。

<img src="assets/演示cli启动.gif" alt="CLI Launch Demo" width="100%" />

<img src="assets/查看CLI的所有命令.gif" alt="CLI Commands" width="100%" />

### Folder Shortcuts

添加常用项目目录，快速 `cd` 进入。

<img src="assets/添加文件界面.png" alt="Add Folder" width="100%" />

### Slash Commands

内置交互式命令（`/clear`、`/exit`、`/compact` 等），菜单中直接选择粘贴。

<img src="assets/交互式命令演示.gif" alt="Slash Commands Demo" width="100%" />

### Smart Paste

剪贴板有文字 → 直接粘贴；有图片 → 自动保存到本地并粘贴路径，方便喂给 AI 读取。

<img src="assets/截图快速粘贴.gif" alt="Smart Paste Demo" width="100%" />

### Open Selected Path

选中终端里的文件路径 → 弹出菜单按 `L` → 直接用 Finder 或默认应用打开。支持带引号路径、`~/` 展开、`file:line:col` 格式。

<img src="assets/打开链接快捷方式.gif" alt="Open Link Shortcut" width="100%" />

### Clear Line Input

弹出菜单按 `Delete`，一键清空当前行输入。连续点击可快速删除多行。

<img src="assets/清楚此行输入功能.gif" alt="Clear Line Demo" width="100%" />

### Clipboard Protection

所有粘贴操作完成后，TermKit 自动还原剪贴板原始内容，不打断工作流。

### App Whitelist

只在指定 app（终端、编辑器）前台时触发，其他应用完全不受影响。

<img src="assets/应用白名单.png" alt="App Whitelist" width="100%" />

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `1-9` / `0` | 选择菜单项 |
| `↑` `↓` | 上下移动 |
| `←` `→` | 返回 / 进入下一层 |
| `` ` `` `~` | 返回上一层 |
| `V` | 智能粘贴 |
| `L` | 打开选中路径 |
| `⌫` | 清空此行输入 |
| `-` | 暂停快捷键 1 小时 |
| `=` | 永久关闭快捷键 |
| `Esc` | 取消 |
| 释放 ⌘ | 确认执行 |

---

## Installation

```bash
git clone https://github.com/MenheraHann/TermKit.git
cd TermKit
make install
```

编译后自动安装到 `/Applications` 并启动。

```bash
# Uninstall
make uninstall
```

**Requirements:**
- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools (Swift 5.9+)
- Accessibility + Input Monitoring permissions

---

## Settings

点击菜单栏图标 → 配置：

<img src="assets/设置演示.png" alt="Settings" width="100%" />

| Tab | Description |
|-----|-------------|
| **General** | 触发键、长按阈值、语言 |
| **Folders** | 添加项目目录，快速 `cd` |
| **CLI Tools** | 配置 CLI 工具及动作 |
| **Templates** | 带 `{变量}` 的命令模板 |
| **Apps** | 应用白名单管理 |

---

## Tech Stack

| | |
|---|---|
| Language | Swift, SwiftUI |
| Key Detection | CGEventTap (defaultTap) |
| Min OS | macOS 13 (Ventura) |
| Languages | 9 (简中/繁中/EN/日/韩/西/法/德/葡) |

---

## Building

```bash
make build     # Build only
make app       # Build + package .app
make install   # Build + install to /Applications
make clean     # Clean build artifacts
```

---

## License

[MIT](LICENSE) © 2026 MenheraHann

## Trademark Notice

TermKit includes icon assets for third-party CLI tools (Claude/Anthropic, Gemini/Google, GitHub Copilot/Microsoft, OpenAI, OpenClaw, OpenCode) for identification purposes only. All trademarks and brand assets belong to their respective owners. TermKit is not affiliated with or endorsed by any of these companies.
