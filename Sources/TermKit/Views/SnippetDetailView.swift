import SwiftUI

/// 片段详情视图，显示完整命令、复制按钮和运行按钮
struct SnippetDetailView: View {
    let snippet: Snippet?
    let onCopy: (String) -> Void
    let onRun: (Snippet) -> Void

    /// 是否显示危险确认弹窗
    @State private var showDangerConfirm = false

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

                // 操作按钮区
                HStack(spacing: 8) {
                    // 复制按钮
                    Button {
                        onCopy(snippet.command)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.callout)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    // 运行按钮
                    Button {
                        handleRun(snippet)
                    } label: {
                        Label("Run", systemImage: "play.fill")
                            .font(.callout)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.small)
                }
            }
            .padding(10)
            .sheet(isPresented: $showDangerConfirm) {
                DangerConfirmView(
                    snippet: snippet,
                    onConfirm: {
                        showDangerConfirm = false
                        onRun(snippet)
                    },
                    onCancel: {
                        showDangerConfirm = false
                    }
                )
            }
        } else {
            // 未选中片段时的占位
            Text("Select a snippet")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
        }
    }

    // MARK: - Run 流程

    /// 处理运行按钮点击：safe 直接执行，danger/caution 弹确认
    private func handleRun(_ snippet: Snippet) {
        switch snippet.dangerLevel {
        case .safe:
            onRun(snippet)
        case .caution, .danger:
            showDangerConfirm = true
        }
    }
}
