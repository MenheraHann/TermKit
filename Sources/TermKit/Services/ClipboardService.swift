import AppKit

/// 剪贴板服务，将文本复制到系统剪贴板
enum ClipboardService {
    /// 将指定文本复制到系统剪贴板
    /// - Parameter text: 要复制的文本内容
    /// - Returns: 复制是否成功
    @discardableResult
    static func copy(_ text: String) -> Bool {
        NSPasteboard.general.clearContents()
        return NSPasteboard.general.setString(text, forType: .string)
    }
}
