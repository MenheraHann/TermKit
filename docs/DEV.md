# Development

## Build
- `swift build -c debug`
- `make app` (packages `TermKit.app` from `.build/release/TermKit`)
- `make install` (copies `TermKit.app` to `/Applications`)

## Config location
- Folder: `~/Library/Application Support/TermKit/`
- File: `config.json`

## macOS permissions (required for full functionality)
- Input Monitoring: detect global ⌘ hold reliably (future: event tap)
- Accessibility: simulate `⌘V` into the frontmost app

## Notes
- The current codebase is a scaffold aligned with `TermKit_prd.md`.
- Some features (event tap, robust permission UX) are intentionally left as tasks in `docs/TASKS.md`.

