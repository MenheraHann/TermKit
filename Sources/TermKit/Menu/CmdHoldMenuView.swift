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

            // 菜单项列表（编号段 + 工具段）
            let numbered = Array(state.currentItems.prefix(state.numberedItemCount).enumerated())
            let utility = Array(state.currentItems.dropFirst(state.numberedItemCount).enumerated())

            ForEach(numbered, id: \.element.id) { idx, item in
                menuRow(item: item, index: idx, isSelected: idx == state.selectedIndex)
                    .onHover { hovering in if hovering { onSelectIndex(idx) } }
                    .onTapGesture {
                        onSelectIndex(idx)
                        onCommitSelection()
                    }
            }

            if !numbered.isEmpty && !utility.isEmpty {
                Divider().padding(.horizontal, 6)
            }

            ForEach(utility, id: \.element.id) { offset, item in
                if item.kind == .disableTemporary {
                    Divider().padding(.horizontal, 6)
                }
                let idx = state.numberedItemCount + offset
                menuRow(item: item, index: idx, isSelected: idx == state.selectedIndex)
                    .onHover { hovering in if hovering { onSelectIndex(idx) } }
                    .onTapGesture {
                        onSelectIndex(idx)
                        onCommitSelection()
                    }
            }

            // 松开执行预览
            if let hint = state.releaseHint {
                Divider()
                    .padding(.horizontal, 6)
                Text(hint)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
            }

            Text(L10n.Menu.navigationHint)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
        }
        .padding(.vertical, 4)
        .frame(minWidth: 240, maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private func menuRow(item: CmdHoldMenuItem, index: Int, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            // 数字快捷键标注（仅编号段显示数字，工具段留空对齐）
            if index < state.numberedItemCount {
                Text(index < 9 ? "\(index + 1)" : index == 9 ? "0" : "")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.6))
                    .frame(width: 14, alignment: .trailing)
            } else {
                Spacer().frame(width: 14)
            }

            // SF Symbol 图标
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 14, alignment: .center)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.system(size: 13))
                    .lineLimit(1)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer()

            // 有子菜单的项显示箭头，工具项显示快捷键提示
            if hasSubmenu(item) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            } else if let hint = shortcutHint(for: item) {
                Text(hint)
                    .font(.system(size: 10, design: .monospaced))
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

    /// 工具项的快捷键提示
    private func shortcutHint(for item: CmdHoldMenuItem) -> String? {
        switch item.kind {
        case .pasteImage:         return "V"
        case .deleteInput:        return "⌫"
        case .disableTemporary:   return "-"
        case .disablePermanent:   return "="
        default:                  return nil
        }
    }

    /// 判断菜单项是否有子菜单（显示箭头）
    private func hasSubmenu(_ item: CmdHoldMenuItem) -> Bool {
        switch item.kind {
        case .openFolders, .openCLIs, .openTemplates, .openSlashCommands, .folder, .cli:
            return true
        default:
            return false
        }
    }
}
