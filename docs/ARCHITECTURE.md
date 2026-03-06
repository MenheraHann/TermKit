# Architecture (Cmd Hold Menu)

## Overview
TermKit is a menu-bar-only macOS app. The primary feature is a global “hold ⌘ to open a hierarchical menu” interaction that generates a command (or image path) and pastes it into the frontmost app via `⌘V`, then restores the clipboard.

## Main runtime objects
- `Sources/TermKit/TermKitModel.swift:1` — top-level `ObservableObject` holding the current `TermKitConfig`, plus a `CmdHoldMenuCoordinator`.
- `Sources/TermKit/Menu/CmdHoldMenuCoordinator.swift:1` — wires together:
  - `CmdHoldDetector` (global hold-⌘ trigger)
  - `CmdHoldMenuWindowController` (floating panel with SwiftUI view)
  - `CmdHoldMenuState` (menu navigation + selected action)
  - `PasteService` (paste-with-clipboard-restore)
  - `ImagePasteService` (clipboard image → file)
- `Sources/TermKit/Services/ConfigStore.swift:1` — load/save `config.json` in `~/Library/Application Support/TermKit/`.

## Module layout
- `Sources/TermKit/Models/` — config/data models (`TermKitConfig`, `FolderEntry`, `CLIEntry`, …)
- `Sources/TermKit/Services/` — clipboard, image, persistence, permissions
- `Sources/TermKit/Input/` — global key detection (future: event tap)
- `Sources/TermKit/Menu/` — menu window, SwiftUI view, state machine, coordinator

## Key design decisions
- Config is user-editable and the source of truth for:
  - folder list
  - CLI list
  - action templates (`Start/Continue/Resume/custom`)
  - timing (`holdThresholdMs`, `clipboardRestoreDelayMs`)
  - image save directory
- Menu UI is driven by `CmdHoldMenuState.currentItems` and `CmdHoldMenuState.currentAction`.
- Pasting is performed by temporarily replacing the pasteboard + simulating `⌘V`, then restoring the pasteboard snapshot.

