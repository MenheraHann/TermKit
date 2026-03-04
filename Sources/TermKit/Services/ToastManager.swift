import SwiftUI

/// Toast 消息管理器，控制短暂提示信息的显示和自动消失
@MainActor
class ToastManager: ObservableObject {
    /// 当前显示的消息文本，nil 表示无消息显示
    @Published var message: String?

    /// 显示一条 Toast 消息，1.5 秒后自动消失
    /// - Parameter text: 要显示的消息文本
    func show(_ text: String) {
        message = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.message = nil
        }
    }
}
