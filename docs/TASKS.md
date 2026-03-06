# Task Breakdown (handoff)

This repo is intentionally scaffolded for multi-agent development. The product spec is `TermKit_prd.md`.

## Milestone M0 — Config + Settings UI
- Add/edit/delete/reorder folders (used by “打开文件夹”).
- Add/edit/delete/reorder CLIs and their templates (`Start/Continue/Resume`) + custom actions.
- Persist to `~/Library/Application Support/TermKit/config.json`.
- Wire: config changes immediately affect the menu.

Acceptance
- Can add a folder in Settings, and it appears in the menu.
- Can add a CLI action template, and it appears in the menu.

## Milestone M1 — Menu window UX
- Improve panel appearance (non-activating vs key window tradeoff).
- Close-on-click-outside.
- Breadcrumb + command preview polish.
- Mouse hover selection (optional).

Acceptance
- Menu feels stable and visually consistent; no focus glitches.

## Milestone M2 — Hold-⌘ trigger (robust)
Current scaffold uses `NSEvent.addGlobalMonitorForEvents`. It can’t prevent the foreground app from receiving key combos and may miss some interactions.

- Implement a robust global input layer (recommended: `CGEventTap`).
- Detect: “⌘ held alone for T ms” → show.
- Cancel if any other key combo starts before showing.
- On ⌘ release: confirm if menu visible.

Acceptance
- No accidental trigger during normal `⌘C/⌘V/⌘Tab/⌘1..` usage.

## Milestone M3 — Paste with clipboard restore (harden)
Current scaffold:
- captures pasteboard items by type/data
- sets string
- posts `CGEvent` for `⌘V`
- restores after delay

Tasks
- Verify snapshot/restore works for common data types (text, image, files).
- Add adaptive delay or “restore on paste completed” heuristics.
- Add permission check UX (Accessibility not granted).

Acceptance
- User clipboard content remains unchanged after a paste, for text + images.

## Milestone M4 — Paste image
- Confirm pasteboard image detection is reliable.
- Save to `~/Library/Application Support/TermKit/Images/` (default).
- Generate unique filename.
- Paste the file path (not image data).

Acceptance
- Selecting “粘贴图片” pastes a valid path; file exists on disk.

## Milestone M5 — Add-from-menu flows
- “添加文件夹…” / “添加 CLI…” / “添加动作…” should open a lightweight input UI and save.
- Validate paths and required fields.

Acceptance
- Add-from-menu works without visiting Settings.

## Optional — Tests
- Unit tests for `ShellQuote.single`, command building, config load/save.
- Manual test checklist doc for permissions and paste behavior.

