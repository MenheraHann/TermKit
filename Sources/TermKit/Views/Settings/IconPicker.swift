import SwiftUI

/// 从预设 SF Symbol 集中选择图标
/// 点击当前图标弹出 Popover，显示图标网格供选择
struct IconPicker: View {
    @Binding var icon: String?
    var defaultIcon: String
    @State private var showPopover = false

    /// 可选图标集
    private static let availableIcons: [String] = [
        // 终端 & 开发
        "terminal", "terminal.fill",
        "chevron.left.forwardslash.chevron.right",
        "curlybraces", "command",
        "apple.terminal", "apple.terminal.fill",
        // 文件 & 文件夹
        "folder", "folder.fill",
        "doc", "doc.fill", "doc.text", "doc.text.fill",
        "doc.on.doc", "doc.on.doc.fill",
        // 工具
        "wrench", "wrench.fill",
        "hammer", "hammer.fill",
        "gearshape", "gearshape.fill",
        "slider.horizontal.3",
        // 通信
        "bolt", "bolt.fill",
        "paperplane", "paperplane.fill",
        "bubble.left", "bubble.left.fill",
        // 媒体
        "play", "play.fill",
        "arrow.triangle.2.circlepath",
        "arrow.clockwise",
        // 符号
        "star", "star.fill",
        "heart", "heart.fill",
        "flag", "flag.fill",
        "bookmark", "bookmark.fill",
        "tag", "tag.fill",
        // 几何
        "circle", "circle.fill",
        "square", "square.fill",
        "diamond", "diamond.fill",
        // 其他
        "cpu", "memorychip",
        "network", "globe",
        "cloud", "cloud.fill",
        "lock", "lock.fill",
        "key", "key.fill",
        "person", "person.fill",
        "ant", "ant.fill",
        "ladybug", "ladybug.fill",
    ]

    var body: some View {
        Button {
            showPopover = true
        } label: {
            Image(systemName: icon ?? defaultIcon)
                .font(.title2)
                .frame(width: 36, height: 36)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .help(L10n.IconPicker.clickToSelectIcon)
        .popover(isPresented: $showPopover) {
            VStack(spacing: 8) {
                Text(L10n.IconPicker.selectIcon)
                    .font(.headline)
                    .padding(.top, 8)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 8), count: 8), spacing: 8) {
                        ForEach(Self.availableIcons, id: \.self) { name in
                            Button {
                                icon = name
                                showPopover = false
                            } label: {
                                Image(systemName: name)
                                    .font(.system(size: 16))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        (icon ?? defaultIcon) == name
                                            ? Color.accentColor.opacity(0.2)
                                            : Color.clear
                                    )
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                }

                Divider()

                Button(L10n.IconPicker.restoreDefault) {
                    icon = nil
                    showPopover = false
                }
                .controlSize(.small)
                .padding(.bottom, 8)
            }
            .frame(width: 340, height: 300)
        }
    }
}
