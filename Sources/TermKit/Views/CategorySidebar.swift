import SwiftUI

/// 分类侧边栏视图，显示"全部"和各分类选项
struct CategorySidebar: View {
    @ObservedObject var store: SnippetStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                // "全部"选项
                categoryButton(label: "All", isSelected: store.selectedCategory == nil) {
                    store.selectedCategory = nil
                }

                // 各分类选项
                ForEach(store.categories, id: \.self) { category in
                    categoryButton(label: category, isSelected: store.selectedCategory == category) {
                        store.selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
        }
        .frame(width: 100)
    }

    /// 构建单个分类按钮
    @ViewBuilder
    private func categoryButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.callout)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
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
