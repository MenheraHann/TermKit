# TermKit M0-M2 Design

## Scope
M0 (skeleton) + M1 (snippet display) + M2 (copy). Minimal viable product that lets users search and copy command snippets.

## Architecture
- macOS SwiftUI App with Xcode project
- NSPanel floating window, toggled via global hotkey ⌥Space
- Menu bar icon (no Dock icon)
- Snippet data loaded from local JSON file

## Components
1. **TermKitApp** — App entry, registers global hotkey, manages panel
2. **PanelManager** — NSPanel creation, show/hide/toggle
3. **ContentView** — Main UI: search bar, category sidebar, snippet list, detail area
4. **SnippetStore** — ObservableObject, loads/filters snippets
5. **Snippet** — Codable model matching PRD JSON schema
6. **default_snippets.json** — 10 built-in snippets per PRD

## Key Decisions
- Global hotkey: NSEvent.addGlobalMonitorForEvents + addLocalMonitorForEvents
- Panel: NSPanel with .floating level, non-activating when clicking outside
- Search: in-memory fuzzy match on title/tags/description
- Copy: NSPasteboard.general, toast feedback
- Data path: ~/Library/Application Support/TermKit/snippets.json
- First launch: copy default_snippets.json to data path if missing

## Not In Scope
- Run (iTerm2/Terminal execution)
- Variable substitution
- Settings UI
