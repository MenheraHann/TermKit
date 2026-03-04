import SwiftUI

/// 主内容视图，组合搜索栏、分类侧边栏、片段列表和详情面板
struct ContentView: View {
    @ObservedObject var store: SnippetStore
    @ObservedObject var panelManager: PanelManager
    @ObservedObject var settings: SettingsManager
    @ObservedObject var recentManager: RecentManager
    @StateObject private var toast = ToastManager()
    /// 是否显示设置面板
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部搜索栏 + 设置按钮
            HStack(spacing: 4) {
                SearchBar(text: $store.searchText)
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                .help("设置")
            }

            Divider()

            // 中间区域：分类侧边栏 + 片段列表
            HStack(spacing: 0) {
                CategorySidebar(store: store, recentManager: recentManager)

                Divider()

                // 片段列表（使用稳定 ID 绑定选中状态）
                List(displayedSnippets, selection: $store.selectedSnippetID) { snippet in
                    SnippetRow(snippet: snippet)
                        .tag(snippet.id)
                }
                .listStyle(.plain)
            }

            Divider()

            // 底部详情区域
            SnippetDetailView(
                snippet: store.selectedSnippet,
                onCopy: { command in
                    if let snippet = store.selectedSnippet {
                        recentManager.addRecent(snippet.id)
                    }
                    if ClipboardService.copy(command) {
                        toast.show("Copied!")
                        panelManager.toggle()
                    } else {
                        toast.show("Copy failed")
                    }
                },
                onRun: { snippet in
                    recentManager.addRecent(snippet.id)
                    let result = TerminalService.executeCommand(snippet.command)
                    switch result {
                    case .success:
                        toast.show("已发送到终端")
                        panelManager.toggle()
                    case .failure(let error):
                        toast.show(error.localizedDescription)
                    }
                },
                settings: settings
            )
            .frame(height: 120)
        }
        .frame(width: 420, height: 520)
        .overlay(ToastView(toast: toast))
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
    }

    /// 当前显示的片段列表（最近使用模式或正常过滤）
    private var displayedSnippets: [Snippet] {
        if store.selectedTool == nil && store.selectedCategory == nil
            && store.searchText.isEmpty && store.showRecent {
            return recentManager.recentSnippets(from: store)
        }
        return store.filteredSnippets
    }
}
