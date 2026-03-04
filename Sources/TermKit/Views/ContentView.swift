import SwiftUI

/// 主内容视图（占位符），后续任务中将替换为完整的搜索+列表界面
struct ContentView: View {
    @ObservedObject var store: SnippetStore
    @ObservedObject var panelManager: PanelManager

    var body: some View {
        VStack {
            Text("TermKit")
                .font(.title2)
                .padding()
            Text("\(store.allSnippets.count) snippets loaded")
                .foregroundStyle(.secondary)
        }
        .frame(width: 420, height: 520)
    }
}
