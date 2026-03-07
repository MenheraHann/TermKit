import AppKit
@preconcurrency import CoreFoundation
import CoreGraphics
import Foundation

/// 使用 CGEventTap 监听修饰键长按，支持可配置的触发键。
/// 菜单可见时，通过 defaultTap 拦截键盘事件（吞掉菜单相关按键）。
@MainActor
final class ModifierHoldDetector {

    // MARK: - 公开属性

    var isEnabled: Bool = false {
        didSet {
            if isEnabled { start() } else { stop() }
        }
    }

    var holdThresholdMs: Int = 300

    /// 触发键，修改后会重置当前检测状态
    var triggerKey: TriggerModifierKey = .command {
        didSet { resetState() }
    }

    var onShowMenu: (() -> Void)?
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var onNavigate: ((CmdHoldMenuNavigation) -> Void)?

    /// 数字键选择（带范围守卫，由 coordinator 检查编号范围）
    var onNumberKeySelect: ((Int) -> Void)?
    /// V 键智能粘贴回调
    var onPaste: (() -> Void)?
    /// Delete 键回调
    var onDelete: (() -> Void)?
    /// 关闭快捷键 1h 回调（- 键）
    var onDisableTemporary: (() -> Void)?
    /// 关闭快捷键回调（= 键）
    var onDisablePermanent: (() -> Void)?

    // MARK: - 私有状态

    /// 线程安全的 machPort 引用，供 nonisolated 回调重新启用 tap
    private nonisolated(unsafe) var _machPort: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private nonisolated(unsafe) var _backgroundRunLoop: CFRunLoop?
    private var backgroundThread: Thread?

    private var targetDownAt: Date?
    private var scheduledShow: DispatchWorkItem?
    private var menuVisible: Bool = false
    private var wasTargetDown: Bool = false
    private var permissionPollTimer: DispatchSourceTimer?

    /// 线程安全标志，供后台 C 回调同步读取（决定是否吞掉事件）
    nonisolated(unsafe) var _menuVisible: Bool = false

    // MARK: - 菜单可见性（由 Coordinator 调用）

    /// 菜单显示时调用，同步设置两个标志
    func menuDidShow() {
        menuVisible = true
        _menuVisible = true
    }

    /// 菜单隐藏时调用，同步设置两个标志
    func menuDidHide() {
        menuVisible = false
        _menuVisible = false
    }

    // MARK: - 所有修饰键掩码（用于判断"仅目标键按下"）

    private static let allModifierFlags: [CGEventFlags] = [
        .maskCommand, .maskAlternate, .maskControl, .maskShift
    ]

    // MARK: - 启动 / 停止

    private func start() {
        guard _machPort == nil else { return }

        // 权限检查：需要辅助功能权限才能创建 CGEventTap
        if !AXIsProcessTrusted() {
            // 延迟弹窗，避免 app 初始化阶段 runModal 崩溃
            DispatchQueue.main.async { [weak self] in
                self?.showAccessibilityAlert()
            }
            startPermissionPolling()
            return
        }

        // 通过 Unmanaged 传递 self 给 C 回调
        let selfPtr = Unmanaged.passUnretained(self)

        let eventMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)
                                   | (1 << CGEventType.keyDown.rawValue)

        guard let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: modifierHoldCallback,
            userInfo: selfPtr.toOpaque()
        ) else {
            NSLog("[TermKit] ModifierHoldDetector: CGEventTap 创建失败")
            return
        }

        _machPort = port

        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0) else {
            CGEvent.tapEnable(tap: port, enable: false)
            _machPort = nil
            NSLog("[TermKit] ModifierHoldDetector: RunLoopSource 创建失败")
            return
        }

        runLoopSource = source

        // 在后台线程运行 CGEventTap 的 RunLoop
        let thread = Thread {
            let rl = CFRunLoopGetCurrent()
            // 同步存储 RunLoop 引用，避免 stop() 时还未赋值的竞态
            self._backgroundRunLoop = rl
            CFRunLoopAddSource(rl, source, .commonModes)
            CFRunLoopRun()
        }
        thread.name = "com.termkit.modifier-hold-detector"
        thread.qualityOfService = .userInteractive
        backgroundThread = thread
        thread.start()

        NSLog("[TermKit] ModifierHoldDetector: 已启动（defaultTap），触发键=%@", triggerKey.displayName)
    }

    private func stop() {
        stopPermissionPolling()

        if let port = _machPort {
            CGEvent.tapEnable(tap: port, enable: false)
            CFMachPortInvalidate(port)
            _machPort = nil
        }

        if let rl = _backgroundRunLoop {
            CFRunLoopStop(rl)
            _backgroundRunLoop = nil
        }

        runLoopSource = nil
        backgroundThread = nil

        resetState()

        NSLog("[TermKit] ModifierHoldDetector: 已停止")
    }

    // MARK: - 状态重置

    private func resetState() {
        scheduledShow?.cancel()
        scheduledShow = nil
        targetDownAt = nil
        menuVisible = false
        _menuVisible = false
        wasTargetDown = false
    }

    // MARK: - 事件处理（从后台线程调用，返回值决定吞掉/放行）

    /// C 回调调用此方法，返回 nil 表示吞掉事件，返回事件表示放行
    nonisolated func handleEvent(_ proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // 处理 tap 被系统禁用的情况：重新启用
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let port = _machPort {
                CGEvent.tapEnable(tap: port, enable: true)
                NSLog("[TermKit] ModifierHoldDetector: tap 被系统禁用，已重新启用")
            }
            return Unmanaged.passUnretained(event)
        }

        let flags = event.flags
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        // 菜单可见时拦截菜单相关按键
        if _menuVisible && type == .keyDown {
            let isMenuKey = kNumberKeyCodes[keyCode] != nil
                         || kMenuKeyCodes.contains(keyCode)

            if isMenuKey {
                // 异步派发导航动作到主线程
                Task { @MainActor [weak self] in
                    self?.handleMenuKeyDown(keyCode: keyCode)
                }
                // 吞掉事件，不让终端收到
                return nil
            }
        }

        // 非菜单按键或菜单不可见，正常处理
        Task { @MainActor [weak self] in
            guard let self, self.isEnabled else { return }

            switch type {
            case .flagsChanged:
                self.handleFlagsChanged(flags)
            case .keyDown:
                self.handleKeyDown(flags)
            default:
                break
            }
        }

        return Unmanaged.passUnretained(event)
    }

    // MARK: - 菜单按键处理（MainActor）

    private func handleMenuKeyDown(keyCode: UInt16) {
        // 数字键选择（由 coordinator 检查编号范围）
        if let index = kNumberKeyCodes[keyCode] {
            onNumberKeySelect?(index)
            return
        }

        // 导航/操作键
        switch keyCode {
        case 126: // ↑
            onNavigate?(.up)
        case 125: // ↓
            onNavigate?(.down)
        case 123: // ←
            onNavigate?(.back)
        case 124: // →
            onNavigate?(.forward)
        case 36: // Return
            onConfirm?()
        case 53: // Escape
            onCancel?()
        case 50: // `/~
            onNavigate?(.back)
        case 51: // Delete/Backspace
            onDelete?()
        case 9:  // V
            onPaste?()
        case 27: // -（关闭快捷键 1h）
            onDisableTemporary?()
        case 24: // =（关闭快捷键）
            onDisablePermanent?()
        default:
            break
        }
    }

    private func handleFlagsChanged(_ flags: CGEventFlags) {
        let targetFlag = triggerKey.cgEventFlag
        let isTargetDown = flags.contains(targetFlag)

        // 检查是否有其他修饰键同时按下
        let otherFlags = Self.allModifierFlags.filter { $0 != targetFlag }
        let hasOtherModifiers = otherFlags.contains { flags.contains($0) }

        // 边缘检测：仅在状态变化时触发
        if isTargetDown && !wasTargetDown {
            // 目标键按下
            wasTargetDown = true

            if !hasOtherModifiers {
                // 仅目标键按下，开始计时
                targetDownAt = Date()
                scheduleShow()
            }
        } else if !isTargetDown && wasTargetDown {
            // 验证物理按键状态：sendClearLine 等模拟按键会产生 flagsChanged，
            // 其 flags 可能不含物理按住的修饰键，导致误判为释放
            if CGEventSource.keyState(.hidSystemState, key: triggerKey.cgKeyCode) {
                return  // 目标键仍物理按住，忽略合成事件的假释放
            }

            // 目标键释放
            wasTargetDown = false

            scheduledShow?.cancel()
            scheduledShow = nil
            targetDownAt = nil

            if menuVisible {
                onConfirm?()
                menuVisible = false
                _menuVisible = false
            }
        } else if isTargetDown && hasOtherModifiers {
            // 目标键仍按住但有其他修饰键加入，取消计时
            scheduledShow?.cancel()
            scheduledShow = nil
            targetDownAt = nil
        }
    }

    private func handleKeyDown(_ flags: CGEventFlags) {
        // 菜单已显示时不取消（交由导航逻辑处理）
        if menuVisible { return }

        let targetFlag = triggerKey.cgEventFlag
        if flags.contains(targetFlag) {
            // 用户在做组合键（如 Cmd+C），取消长按检测
            scheduledShow?.cancel()
            scheduledShow = nil
            targetDownAt = nil
        }
    }

    // MARK: - 定时显示菜单

    private func scheduleShow() {
        scheduledShow?.cancel()
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                guard self.targetDownAt != nil else { return }
                self.menuVisible = true
                self._menuVisible = true
                self.onShowMenu?()
            }
        }
        scheduledShow = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(holdThresholdMs), execute: work)
    }

    // MARK: - 权限轮询（用户授权后自动启动 tap）

    /// 弹窗后每 2 秒检查一次权限，授权后自动创建 CGEventTap
    private func startPermissionPolling() {
        stopPermissionPolling()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + 2, repeating: 2)
        timer.setEventHandler { [weak self] in
            Task { @MainActor in
                guard let self, self.isEnabled else {
                    self?.stopPermissionPolling()
                    return
                }
                let trusted = AXIsProcessTrusted()
                NSLog("[TermKit] ModifierHoldDetector: 权限检查 AXIsProcessTrusted()=%@", trusted ? "true" : "false")
                if trusted {
                    NSLog("[TermKit] ModifierHoldDetector: 检测到辅助功能权限已授予，正在启动...")
                    self.stopPermissionPolling()
                    self.start()
                }
            }
        }
        permissionPollTimer = timer
        timer.resume()
        NSLog("[TermKit] ModifierHoldDetector: 开始轮询辅助功能权限...")
    }

    private func stopPermissionPolling() {
        permissionPollTimer?.cancel()
        permissionPollTimer = nil
    }

    // MARK: - 辅助功能权限提示

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = L10n.Permission.accessibilityRequired
        alert.informativeText = L10n.Permission.accessibilityMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: L10n.Permission.openSystemSettings)
        alert.addButton(withTitle: L10n.Common.cancel)

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - 清理

    deinit {
        // deinit 在 MainActor 上执行（因为类是 @MainActor）
        if let port = _machPort {
            CGEvent.tapEnable(tap: port, enable: false)
            CFMachPortInvalidate(port)
        }
        if let rl = _backgroundRunLoop {
            CFRunLoopStop(rl)
        }
    }
}

// MARK: - 按键映射表（文件级，避免 @MainActor 隔离问题）

/// 数字键 1-9, 0 的 keyCode → 对应的选择索引（0-9）
private let kNumberKeyCodes: [UInt16: Int] = [
    18: 0,  // 1
    19: 1,  // 2
    20: 2,  // 3
    21: 3,  // 4
    23: 4,  // 5
    22: 5,  // 6
    26: 6,  // 7
    28: 7,  // 8
    25: 8,  // 9
    29: 9,  // 0
]

/// 导航/操作键的 keyCode 集合
private let kMenuKeyCodes: Set<UInt16> = [
    126,  // ↑
    125,  // ↓
    123,  // ←
    124,  // →
    36,   // Return
    53,   // Escape
    50,   // `/~
    51,   // Delete/Backspace
    9,    // V
    27,   // -（关闭快捷键 1h）
    24,   // =（关闭快捷键）
]

// MARK: - C 回调函数

/// CGEventTap 的 C 函数回调，通过 Unmanaged 转发到 ModifierHoldDetector 实例
private func modifierHoldCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passUnretained(event) }
    let detector = Unmanaged<ModifierHoldDetector>.fromOpaque(userInfo).takeUnretainedValue()
    return detector.handleEvent(proxy, type: type, event: event)
}
