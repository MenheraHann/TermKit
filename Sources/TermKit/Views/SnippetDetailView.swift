import SwiftUI

/// 片段详情视图，显示完整命令和复制按钮
struct SnippetDetailView: View {
    let snippet: Snippet?
    let onCopy: (String) -> Void

    var body: some View {
        if let snippet = snippet {
            VStack(alignment: .leading, spacing: 8) {
                // 命令预览区：等宽字体 + 深色背景
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(snippet.command)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundStyle(.white)
                        .textSelection(.enabled)
                        .padding(10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.8))
                )

                // 复制按钮
                Button {
                    onCopy(snippet.command)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.callout)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(10)
        } else {
            // 未选中片段时的占位
            Text("Select a snippet")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
        }
    }
}
