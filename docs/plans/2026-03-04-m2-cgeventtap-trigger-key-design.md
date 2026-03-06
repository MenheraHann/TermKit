# M2 Design: CGEventTap + Configurable Trigger Key

## Summary

Replace `NSEvent.addGlobalMonitorForEvents` with `CGEventTap` for robust modifier-key hold detection, and allow users to choose which modifier key (⌘ / ⌥ / ⌃ / fn) triggers the menu.

## Config Model

New enum `TriggerModifierKey` with cases: `command` (default), `option`, `control`, `fn`.

Added to `TermKitConfig.Features.triggerKey`. Uses `String` raw value for readable JSON. Backwards-compatible: missing field decodes to `.command` via `init(from:)` with `decodeIfPresent`.

## Detection Layer: `ModifierHoldDetector`

Rename `CmdHoldDetector` → `ModifierHoldDetector` to reflect it's no longer ⌘-specific.

### CGEventTap Setup

- Create a **passive** (`listenOnly`) event tap on `cghidEventTap` location.
- Listen to `flagsChanged` and `keyDown` events.
- Run on a dedicated `CFRunLoop` background thread; dispatch callbacks to `@MainActor`.
- On `deinit` / `stop()`: invalidate tap, stop run loop, join thread.

### Detection Logic

```
flagsChanged event:
  if target modifier is NOW pressed (and wasn't before):
    record timestamp, schedule show after T ms
  if target modifier is NOW released:
    cancel scheduled show
    if menu is visible → onConfirm()

keyDown event (while target modifier is held, menu not yet visible):
  cancel scheduled show (user is doing a key combo, not a hold)
```

The "target modifier" is determined by `TriggerModifierKey`:
- `.command` → `CGEventFlags.maskCommand`
- `.option` → `CGEventFlags.maskAlternate`
- `.control` → `CGEventFlags.maskControl`
- `.fn` → `CGEventFlags.maskSecondaryFn`

### Fn Key Caveat

macOS intercepts fn/Globe for input source switching. Detection may be unreliable on some machines. This is documented in Settings UI as a tooltip.

## Permission Handling

On `start()`, check `AXIsProcessTrusted()`:
- If trusted: create CGEventTap normally.
- If not trusted: show an `NSAlert` explaining the need for Accessibility permission, with a button that opens `System Settings > Privacy & Security > Accessibility`. Do NOT create the tap (it would fail anyway).

Re-check on each `start()` call so that once the user grants permission and toggles the feature, it works immediately.

## Settings UI

Add a `Picker` below the existing toggle:

```
Trigger Key: [⌘ Command ▾]
```

Options: ⌘ Command / ⌥ Option / ⌃ Control / fn Function

Disabled (grayed out) when "Enable Cmd Hold Menu" is off.

Label of the toggle updated from "Enable Cmd Hold Menu" to "Enable Hold Menu" (since it's no longer ⌘-specific).

## Coordinator Changes

`CmdHoldMenuCoordinator.applyConfig()` passes the new `triggerKey` to the detector. The coordinator itself is unchanged otherwise.

## Files Changed

| File | Change |
|------|--------|
| `Models/TermKitConfig.swift` | Add `TriggerModifierKey` enum, add `triggerKey` to `Features` |
| `Input/CmdHoldDetector.swift` | Rename to `ModifierHoldDetector.swift`, rewrite with CGEventTap |
| `Menu/CmdHoldMenuCoordinator.swift` | Pass `triggerKey` to detector |
| `SettingsView.swift` | Add trigger key picker |

## Acceptance Criteria

1. Long-hold of configured modifier key shows menu; release confirms.
2. Normal key combos (⌘C, ⌘V, ⌘Tab) do NOT trigger the menu.
3. Switching trigger key in Settings takes effect immediately.
4. Without Accessibility permission: alert shown, feature does not crash.
5. Config persists across app restart; old config without `triggerKey` loads as `.command`.
