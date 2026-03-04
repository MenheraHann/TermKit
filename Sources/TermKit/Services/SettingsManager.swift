import SwiftUI

/// 全局设置管理器，使用 @AppStorage 持久化用户偏好
@MainActor
class SettingsManager: ObservableObject {
    /// 是否显示 Run 按钮（默认关闭）
    @AppStorage("showRunButton") var showRunButton: Bool = false
    /// 执行危险命令前是否弹出确认弹窗（默认开启）
    @AppStorage("confirmDangerousCommands") var confirmDangerousCommands: Bool = true
}
