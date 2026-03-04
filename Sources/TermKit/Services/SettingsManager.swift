import SwiftUI

/// 全局设置管理器，使用 @AppStorage 持久化用户偏好
/// 手动触发 objectWillChange 确保 @ObservedObject 消费者正确刷新
@MainActor
class SettingsManager: ObservableObject {
    /// 是否显示 Run 按钮（默认关闭）
    @AppStorage("showRunButton") var showRunButton: Bool = false {
        didSet { objectWillChange.send() }
    }
    /// 执行危险命令前是否弹出确认弹窗（默认开启）
    @AppStorage("confirmDangerousCommands") var confirmDangerousCommands: Bool = true {
        didSet { objectWillChange.send() }
    }
}
