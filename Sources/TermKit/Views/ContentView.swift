import SwiftUI

/// 主内容视图，组合搜索栏、分类侧边栏、片段列表和详情面板
struct ContentView: View {
    @ObservedObject var store: SnippetStore
    @ObservedObject var panelManager: PanelManager
    @StateObject private var toast = ToastManager()

    var body: some View {
        VStack(spacing: 0) {
            // 顶部搜索栏
            SearchBar(text: $store.searchText)

            Divider()

            // 中间区域：分类侧边栏 + 片段列表
            HStack(spacing: 0) {
                CategorySidebar(store: store)

                Divider()

                // 片段列表（使用稳定 ID 绑定选中状态）
                List(store.filteredSnippets, selection: $store.selectedSnippetID) { snippet in
                    SnippetRow(snippet: snippet)
                        .tag(snippet.id)
                }
                .listStyle(.plain)
            }

            Divider()

            // 底部详情区域
            SnippetDetailView(snippet: store.selectedSnippet) { command in
                if ClipboardService.copy(command) {
                    toast.show("Copied!")
                    panelManager.toggle()
                } else {
                    toast.show("Copy failed")
                }
            }
            .frame(height: 100)
        }
        .frame(width: 420, height: 520)
        .overlay(ToastView(toast: toast))
    }
}
