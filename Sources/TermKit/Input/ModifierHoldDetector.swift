import AppKit
import CoreGraphics
import Foundation

/// 使用 CGEventTap 监听修饰键长按，支持可配置的触发键。
/// 替代旧的 CmdHoldDetector（基于 NSEvent.addGlobalMonitorForEvents）。
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

    // MARK: - 所有修饰键掩码（用于判断"仅目标键按下"）

    private static let allModifierFlags: [CGEventFlags] = [
        .maskCommand, .maskAlternate, .maskControl, .maskShift
    ]

    // MARK: - 启动 / 停止

    private func start() {
        guard _machPort == nil else { return }

        // 权限检查：需要辅助功能权限才能创建 CGEventTap
        if !AXIsProcessTrusted() {
            showAccessibilityAlert()
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
            options: .listenOnly,
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

        NSLog("[TermKit] ModifierHoldDetector: 已启动，触发键=%@", triggerKey.displayName)
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
        wasTargetDown = false
    }

    // MARK: - 事件处理（从后台线程 dispatch 到 MainActor）

    /// C 回调无法直接调用 @MainActor 方法，通过 nonisolated 中转
    nonisolated func handleEvent(_ proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) {
        // 处理 tap 被系统禁用的情况：重新启用
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let port = _machPort {
                CGEvent.tapEnable(tap: port, enable: true)
                NSLog("[TermKit] ModifierHoldDetector: tap 被系统禁用，已重新启用")
            }
            return
        }

        let flags = event.flags

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
            // 目标键释放
            wasTargetDown = false

            scheduledShow?.cancel()
            scheduledShow = nil
            targetDownAt = nil

            if menuVisible {
                onConfirm?()
                menuVisible = false
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
                if AXIsProcessTrusted() {
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
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "TermKit 需要辅助功能权限来检测修饰键长按。请在系统设置中授权后重新启用此功能。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "取消")

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
    detector.handleEvent(proxy, type: type, event: event)
    return Unmanaged.passUnretained(event)
}
