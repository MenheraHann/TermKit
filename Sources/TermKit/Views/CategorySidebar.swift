import SwiftUI

/// 两级导航侧边栏：一级显示 tool 列表，二级显示对应 category
struct CategorySidebar: View {
    @ObservedObject var store: SnippetStore
    @ObservedObject var recentManager: RecentManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                // "全部"选项 —— 重置 tool 和 category
                sidebarButton(label: "全部", isSelected: store.selectedTool == nil && store.selectedCategory == nil && !store.showRecent) {
                    store.selectedTool = nil
                    store.selectedCategory = nil
                    store.showRecent = false
                }

                // "最近使用"选项
                sidebarButton(
                    label: "最近使用",
                    systemImage: "clock",
                    isSelected: store.showRecent
                ) {
                    store.selectedTool = nil
                    store.selectedCategory = nil
                    store.showRecent = true
                }

                Divider()
                    .padding(.vertical, 4)

                // 一级分类：工具列表
                ForEach(store.tools, id: \.self) { tool in
                    // 工具按钮：展开时也保持高亮
                    sidebarButton(
                        label: tool,
                        isSelected: store.selectedTool == tool,
                        isBold: true
                    ) {
                        store.selectedTool = tool
                        store.selectedCategory = nil
                        store.showRecent = false
                    }
                    .help(tool) // tooltip 防止长名称截断

                    // 二级分类：选中工具后展开对应 category
                    if store.selectedTool == tool {
                        let cats = store.categories
                        ForEach(cats, id: \.self) { category in
                            sidebarButton(
                                label: category,
                                isSelected: store.selectedCategory == category,
                                indented: true
                            ) {
                                store.selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }

    /// 构建单个侧边栏按钮
    @ViewBuilder
    private func sidebarButton(
        label: String,
        systemImage: String? = nil,
        isSelected: Bool,
        isBold: Bool = false,
        indented: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = systemImage {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(label)
                    .font(isBold ? .callout.bold() : .callout)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, indented ? 20 : 8)
            .padding(.trailing, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
        }
        .buttonStyle(.plain)
    }
}
