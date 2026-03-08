# M2: CGEventTap + Configurable Trigger Key — Implementation Plan

**Goal:** Replace NSEvent-based modifier detection with CGEventTap, and let users pick which modifier key (⌘/⌥/⌃/fn) triggers the menu.

**Architecture:** A new `TriggerModifierKey` enum maps each option to `CGEventFlags`. `ModifierHoldDetector` (renamed from `CmdHoldDetector`) uses a CGEventTap on a background thread, dispatching to MainActor. Permission check via `AXIsProcessTrusted()` with alert on failure.

**Tech Stack:** Swift 5.9, AppKit (CGEventTap, AXIsProcessTrusted), SwiftUI (Settings Picker)

---

### Task 1: Add TriggerModifierKey enum to config

**Files:**
- Modify: `Sources/TermKit/Models/TermKitConfig.swift`

**Step 1: Add TriggerModifierKey enum**

Add before `struct TermKitConfig`:

```swift
/// 用户可选的触发修饰键
enum TriggerModifierKey: String, Codable, CaseIterable {
    case command  // ⌘
    case option   // ⌥
    case control  // ⌃
    case fn       // fn/Globe

    /// 对应的 CGEventFlags 掩码
    var cgEventFlag: CGEventFlags {
        switch self {
        case .command:  return .maskCommand
        case .option:   return .maskAlternate
        case .control:  return .maskControl
        case .fn:       return .maskSecondaryFn
        }
    }

    /// 显示名称（用于设置界面）
    var displayName: String {
        switch self {
        case .command:  return "⌘ Command"
        case .option:   return "⌥ Option"
        case .control:  return "⌃ Control"
        case .fn:       return "fn Function"
        }
    }
}
```

**Step 2: Add triggerKey to Features struct**

Change `Features` from:

```swift
struct Features: Codable, Equatable {
    var enableCmdHoldMenu: Bool
}
```

To:

```swift
struct Features: Codable, Equatable {
    var enableCmdHoldMenu: Bool
    var triggerKey: TriggerModifierKey

    // 向后兼容：旧 config.json 没有 triggerKey 字段时默认 .command
    init(enableCmdHoldMenu: Bool, triggerKey: TriggerModifierKey = .command) {
        self.enableCmdHoldMenu = enableCmdHoldMenu
        self.triggerKey = triggerKey
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enableCmdHoldMenu = try container.decode(Bool.self, forKey: .enableCmdHoldMenu)
        triggerKey = try container.decodeIfPresent(TriggerModifierKey.self, forKey: .triggerKey) ?? .command
    }
}
```

**Step 3: Verify default config still works**

The `defaultValue` already passes `Features(enableCmdHoldMenu: false)` — the new default parameter `.command` kicks in automatically. No change needed.

**Step 4: Build to verify**

Run: `cd . && swift build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add Sources/TermKit/Models/TermKitConfig.swift
git commit -m "feat(config): add TriggerModifierKey enum with 4 modifier options"
```

---

### Task 2: Rewrite detector with CGEventTap

**Files:**
- Delete: `Sources/TermKit/Input/CmdHoldDetector.swift`
- Create: `Sources/TermKit/Input/ModifierHoldDetector.swift`

**Step 1: Create ModifierHoldDetector.swift**

```swift
import AppKit
import Foundation

/// 使用 CGEventTap 检测修饰键长按的全局检测器
/// 替代原有的 NSEvent.addGlobalMonitorForEvents 方案，更可靠
@MainActor
final class ModifierHoldDetector {

    // MARK: - 公有属性

    var isEnabled: Bool = false {
        didSet {
            if isEnabled { start() } else { stop() }
        }
    }

    /// 长按触发阈值（毫秒）
    var holdThresholdMs: Int = 300

    /// 当前监听的修饰键
    var triggerKey: TriggerModifierKey = .command {
        didSet {
            // 切换键时重置状态，避免残留
            resetState()
        }
    }

    // MARK: - 回调

    var onShowMenu: (() -> Void)?
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var onNavigate: ((CmdHoldMenuNavigation) -> Void)?

    // MARK: - 私有状态

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var tapThread: Thread?

    private var modifierDownAt: Date?
    private var scheduledShow: DispatchWorkItem?
    private var menuVisible: Bool = false

    /// 上一次 flagsChanged 中目标修饰键是否处于按下状态（用于边缘检测）
    private var wasTargetDown: Bool = false

    // MARK: - 启动 / 停止

    private func start() {
        guard eventTap == nil else { return }

        // 检查辅助功能权限
        guard checkAccessibilityPermission() else { return }

        // 创建 CGEventTap（被动监听，不拦截事件）
        let eventMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue) | (1 << CGEventType.keyDown.rawValue)

        // 用 Unmanaged 传递 self 指针给 C 回调
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { _, eventType, event, userInfo -> Unmanaged<CGEvent>? in
                guard let userInfo else { return Unmanaged.passUnretained(event) }
                let detector = Unmanaged<ModifierHoldDetector>.fromOpaque(userInfo).takeUnretainedValue()
                detector.handleCGEvent(type: eventType, event: event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: selfPtr
        ) else {
            print("[TermKit] CGEventTap 创建失败，可能缺少辅助功能权限")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        // 在后台线程运行 CFRunLoop，避免阻塞主线程
        let thread = Thread { [weak self] in
            guard let self, let source = self.runLoopSource else { return }
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopAddSource(runLoop, source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            CFRunLoopRun()
        }
        thread.name = "com.termkit.eventtap"
        thread.qualityOfService = .userInteractive
        tapThread = thread
        thread.start()

        print("[TermKit] ModifierHoldDetector 已启动，监听键: \(triggerKey.displayName)")
    }

    private func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource, let thread = tapThread {
            // 停止后台 RunLoop
            CFRunLoopStop(CFRunLoopGetMain()) // 这里需要拿到后台线程的 RunLoop
            // 实际上我们需要在后台线程中停止，这里用一个更安全的方式
        }

        // 清理 CFMachPort
        if let tap = eventTap {
            CFMachPortInvalidate(tap)
        }
        eventTap = nil
        runLoopSource = nil
        tapThread = nil

        resetState()
        print("[TermKit] ModifierHoldDetector 已停止")
    }

    // MARK: - 权限检查

    /// 检查辅助功能权限，未授权时弹窗引导
    private func checkAccessibilityPermission() -> Bool {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            showAccessibilityAlert()
        }
        return trusted
    }

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "TermKit 需要「辅助功能」权限来检测键盘按键。\n\n请前往 系统设置 → 隐私与安全性 → 辅助功能，找到 TermKit 并开启。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "稍后再说")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // 打开系统设置的辅助功能页面
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - 事件处理（在后台线程调用，需 dispatch 到主线程）

    private nonisolated func handleCGEvent(type: CGEventType, event: CGEvent) {
        switch type {
        case .flagsChanged:
            let rawFlags = event.flags
            let targetDown = rawFlags.contains(triggerKey.cgEventFlag)
            Task { @MainActor in
                self.handleFlagsChanged(targetDown: targetDown, rawFlags: rawFlags)
            }
        case .keyDown:
            Task { @MainActor in
                self.handleKeyDown()
            }
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            // EventTap 被系统禁用时重新启用
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
        default:
            break
        }
    }

    private func handleFlagsChanged(targetDown: Bool, rawFlags: CGEventFlags) {
        guard isEnabled else { return }

        // 检查是否有其他修饰键同时按下（排除目标键本身）
        let otherModifiers: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl, .maskShift]
            .filter { $0 != triggerKey.cgEventFlag }
        let hasOtherModifiers = otherModifiers.contains { rawFlags.contains($0) }

        if targetDown && !wasTargetDown {
            // 目标键刚按下（上升沿）
            if hasOtherModifiers {
                // 同时有其他修饰键，忽略
                wasTargetDown = targetDown
                return
            }
            modifierDownAt = Date()
            scheduleShow()
        } else if !targetDown && wasTargetDown {
            // 目标键刚松开（下降沿）
            scheduledShow?.cancel()
            scheduledShow = nil
            modifierDownAt = nil

            if menuVisible {
                onConfirm?()
                menuVisible = false
            }
        }

        wasTargetDown = targetDown
    }

    private func handleKeyDown() {
        guard isEnabled else { return }
        // 菜单还没显示时，按了其他键 = 用户在做组合快捷键，取消触发
        if !menuVisible {
            scheduledShow?.cancel()
            scheduledShow = nil
            modifierDownAt = nil
        }
    }

    // MARK: - 定时触发

    private func scheduleShow() {
        scheduledShow?.cancel()
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                guard self.modifierDownAt != nil else { return }
                self.menuVisible = true
                self.onShowMenu?()
            }
        }
        scheduledShow = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(holdThresholdMs), execute: work)
    }

    // MARK: - 状态重置

    private func resetState() {
        scheduledShow?.cancel()
        scheduledShow = nil
        modifierDownAt = nil
        menuVisible = false
        wasTargetDown = false
    }
}
```

**Step 2: Delete old CmdHoldDetector.swift**

```bash
git rm Sources/TermKit/Input/CmdHoldDetector.swift
```

**Step 3: Build to verify**

Run: `cd . && swift build`
Expected: Build errors in `CmdHoldMenuCoordinator.swift` referencing `CmdHoldDetector` — this is expected, fixed in Task 3.

**Step 4: Commit (WIP)**

```bash
git add Sources/TermKit/Input/
git commit -m "feat(input): replace CmdHoldDetector with CGEventTap-based ModifierHoldDetector"
```

---

### Task 3: Update Coordinator to use ModifierHoldDetector

**Files:**
- Modify: `Sources/TermKit/Menu/CmdHoldMenuCoordinator.swift:8,16-18,32-35`

**Step 1: Update type reference and pass triggerKey**

Change line 8:
```swift
// 旧
private let detector: CmdHoldDetector
// 新
private let detector: ModifierHoldDetector
```

Change line 16-18 (in `init`):
```swift
// 旧
self.detector = CmdHoldDetector()
// 新
self.detector = ModifierHoldDetector()
```

Change `applyConfig` method (lines 32-35):
```swift
func applyConfig(_ config: TermKitConfig) {
    self.config = config
    detector.holdThresholdMs = config.timing.holdThresholdMs
    detector.triggerKey = config.features.triggerKey  // 新增：传递触发键配置
    detector.isEnabled = config.features.enableCmdHoldMenu
    state.applyConfig(config)
    window.update(state: state)
}
```

Note: `detector.isEnabled` 赋值必须放在 `triggerKey` 之后，因为 `isEnabled = true` 会触发 `start()`，此时 `triggerKey` 需要已经是正确的值。

**Step 2: Build to verify**

Run: `cd . && swift build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Sources/TermKit/Menu/CmdHoldMenuCoordinator.swift
git commit -m "feat(coordinator): wire ModifierHoldDetector with triggerKey config"
```

---

### Task 4: Update Settings UI with trigger key picker

**Files:**
- Modify: `Sources/TermKit/SettingsView.swift`

**Step 1: Add trigger key Picker**

After the existing Toggle, add:

```swift
Picker("Trigger Key", selection: Binding(
    get: { model.config.features.triggerKey },
    set: { value in
        var next = model.config
        next.features.triggerKey = value
        model.saveConfig(next)
    }
)) {
    ForEach(TriggerModifierKey.allCases, id: \.self) { key in
        Text(key.displayName).tag(key)
    }
}
.disabled(!model.config.features.enableCmdHoldMenu)
```

**Step 2: Update toggle label**

Change:
```swift
Toggle("Enable Cmd Hold Menu", isOn: ...
```
To:
```swift
Toggle("Enable Hold Menu", isOn: ...
```

Since the trigger key is no longer hardcoded to ⌘.

**Step 3: Build to verify**

Run: `cd . && swift build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add Sources/TermKit/SettingsView.swift
git commit -m "feat(settings): add trigger key picker (⌘/⌥/⌃/fn)"
```

---

### Task 5: Fix CGEventTap thread lifecycle

The `stop()` method in Task 2 has a known issue: it can't cleanly stop the background CFRunLoop. This task fixes the thread lifecycle.

**Files:**
- Modify: `Sources/TermKit/Input/ModifierHoldDetector.swift`

**Step 1: Add a stored reference to the background RunLoop**

Add a private property:

```swift
private var tapRunLoop: CFRunLoop?
```

**Step 2: Capture RunLoop in thread block**

In `start()`, change the thread block to:

```swift
let thread = Thread { [weak self] in
    guard let self, let source = self.runLoopSource else { return }
    let runLoop = CFRunLoopGetCurrent()
    // 保存后台 RunLoop 的引用，以便 stop() 时调用 CFRunLoopStop
    Task { @MainActor in
        self.tapRunLoop = runLoop
    }
    CFRunLoopAddSource(runLoop, source, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)
    CFRunLoopRun()
}
```

**Step 3: Fix stop() to use stored RunLoop**

```swift
private func stop() {
    if let tap = eventTap {
        CGEvent.tapEnable(tap: tap, enable: false)
        CFMachPortInvalidate(tap)
    }

    if let runLoop = tapRunLoop {
        CFRunLoopStop(runLoop)
    }

    eventTap = nil
    runLoopSource = nil
    tapRunLoop = nil
    tapThread = nil

    resetState()
    print("[TermKit] ModifierHoldDetector 已停止")
}
```

**Step 4: Build to verify**

Run: `cd . && swift build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add Sources/TermKit/Input/ModifierHoldDetector.swift
git commit -m "fix(input): proper CFRunLoop lifecycle in ModifierHoldDetector stop()"
```

---

### Task 6: Manual smoke test

**No code changes.** Verify the feature works end-to-end.

**Step 1: Build and run**

```bash
cd . && make run
```

Or: `swift run`

**Step 2: Test checklist**

1. App launches without crash
2. Grant Accessibility permission when prompted
3. Open Settings → see "Trigger Key" picker, default is ⌘ Command
4. Enable "Hold Menu" toggle
5. Long-press ⌘ → menu appears
6. Release ⌘ → menu confirms/closes
7. ⌘C / ⌘V / ⌘Tab → menu does NOT appear (no false triggers)
8. Change trigger key to ⌥ Option → long-press ⌥ → menu appears
9. Change trigger key to ⌃ Control → long-press ⌃ → menu appears
10. Quit and relaunch → trigger key setting persisted

**Step 3: Report results**

Note any issues for follow-up fixes.
