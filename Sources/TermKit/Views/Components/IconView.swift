import SwiftUI
import AppKit

/// 统一图标渲染组件
/// - `nil` / 普通字符串 → SF Symbol（如 "terminal"、"folder.fill"）
/// - `"custom:名称"` → 品牌 PNG 图标（从 app bundle 加载 CLIIcons/{名称}.png）
struct IconView: View {
    let icon: String?
    var defaultIcon: String
    var size: CGFloat

    var body: some View {
        if let icon = icon, icon.hasPrefix("custom:") {
            let name = String(icon.dropFirst("custom:".count))
            if let nsImage = loadBrandIcon(name: name) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: size, height: size)
            } else {
                // PNG 加载失败时回退到默认 SF Symbol
                Image(systemName: defaultIcon)
                    .font(.system(size: size * 0.85))
                    .frame(width: size, height: size)
            }
        } else {
            Image(systemName: icon ?? defaultIcon)
                .font(.system(size: size * 0.85))
                .frame(width: size, height: size)
        }
    }

    /// 从 app bundle 的 CLIIcons 目录加载品牌 PNG 图标
    private func loadBrandIcon(name: String) -> NSImage? {
        guard let resourceURL = Bundle.main.resourceURL else { return nil }
        let url = resourceURL.appendingPathComponent("CLIIcons/\(name).png")
        guard let image = NSImage(contentsOf: url) else { return nil }
        image.size = NSSize(width: size, height: size)
        return image
    }
}
