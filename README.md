# TermKit

A macOS menu bar utility for terminal power users. Long-press a modifier key to summon a hierarchical quick-access menu — navigate folders, launch CLI tools, run command templates, and paste commands into your terminal, all without leaving the keyboard.

## Features

- **Long-press trigger** — Hold ⌘ (or ⌥/⌃/fn) to activate the menu; release to confirm
- **Folder shortcuts** — Quick `cd` into your favorite directories
- **CLI tool launcher** — Launch Claude Code, Gemini CLI, Aider, and more with pre-configured actions
- **Command templates** — Parameterized commands with `{variable}` placeholders
- **Smart paste** — Commands are pasted directly into your active terminal
- **App whitelist** — Only triggers in terminals and editors you choose
- **Keyboard navigation** — Arrow keys, number keys, and shortcuts for fast access
- **9 languages** — 简体中文, 繁體中文, English, 日本語, 한국어, Español, Français, Deutsch, Português

## Requirements

- macOS 13.0 (Ventura) or later
- **Accessibility permission** — Required for global keyboard monitoring
- **Input Monitoring permission** — Required for keystroke detection

## Installation

### From Source

```bash
git clone https://github.com/MenheraHann/TermKit.git
cd TermKit
make install
```

This builds, code-signs (ad-hoc), and installs TermKit to `/Applications`. The app launches automatically after installation.

### Uninstall

```bash
make uninstall
```

## Usage

1. Launch TermKit — it appears as a menu bar icon
2. Grant Accessibility and Input Monitoring permissions when prompted
3. Long-press your trigger key (default: ⌘ Command) for 300ms
4. Navigate the menu with arrow keys or number keys
5. Release the trigger key to confirm your selection

### Settings

Click the menu bar icon → Settings to configure:
- **General** — Trigger key, hold threshold, language
- **Folders** — Add directories for quick `cd`
- **CLI Tools** — Configure command-line tool launchers
- **Templates** — Create parameterized command templates
- **Apps** — Manage which apps trigger the menu

## Building for Development

```bash
# Build only
make build

# Build + package .app
make app

# Build + install to /Applications
make install

# Clean build artifacts
make clean
```

**Prerequisites:** Xcode Command Line Tools or a full Xcode installation with Swift 5.9+.

## License

[MIT](LICENSE) © 2026 MenheraHann

## Trademark Notice

TermKit includes icon assets for third-party CLI tools (Claude/Anthropic, Gemini/Google, GitHub Copilot/Microsoft, OpenAI, OpenClaw, OpenCode) for identification purposes only. All trademarks and brand assets belong to their respective owners. TermKit is not affiliated with or endorsed by any of these companies.
