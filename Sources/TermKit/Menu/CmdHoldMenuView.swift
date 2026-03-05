import SwiftUI

struct CmdHoldMenuView: View {
    @ObservedObject var state: CmdHoldMenuState

    let onSelectIndex: (Int) -> Void
    let onCommitSelection: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 面包屑导航（非根层级时显示）
            if state.level != .root {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(state.breadcrumb.last ?? "")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)
                .padding(.bottom, 4)

                Divider()
                    .padding(.horizontal, 6)
            }

            // 菜单项列表
            ForEach(Array(state.currentItems.enumerated()), id: \.element.id) { idx, item in
                menuRow(item: item, index: idx, isSelected: idx == state.selectedIndex)
                    .onTapGesture {
                        onSelectIndex(idx)
                        onCommitSelection()
                    }
            }
        }
        .padding(.vertical, 4)
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 0)
        )
    }

    @ViewBuilder
    private func menuRow(item: CmdHoldMenuItem, index: Int, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            // 数字快捷键标注
            Text(index < 9 ? "\(index + 1)" : index == 9 ? "0" : "")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 14, alignment: .trailing)

            Text(item.title)
                .font(.system(size: 13))
                .lineLimit(1)

            Spacer()

            // 有子菜单的项显示箭头
            if hasSubmenu(item) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.accentColor : Color.clear)
                .padding(.horizontal, 4)
        )
        .foregroundStyle(isSelected ? .white : .primary)
    }

    /// 判断菜单项是否有子菜单（显示箭头）
    private func hasSubmenu(_ item: CmdHoldMenuItem) -> Bool {
        switch item.kind {
        case .openFolders, .openCLIs, .folder, .cli:
            return true
        default:
            return false
        }
    }
}
