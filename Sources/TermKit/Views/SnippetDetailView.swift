import SwiftUI

/// 片段详情视图，显示完整命令、复制按钮和运行按钮
struct SnippetDetailView: View {
    let snippet: Snippet?
    let onCopy: (String) -> Void
    let onRun: (Snippet) -> Void

    /// 是否显示危险确认弹窗
    @State private var showDangerConfirm = false
    /// 是否显示变量输入弹窗
    @State private var showVariableInput = false
    /// 记录触发变量输入的操作类型（copy / run）
    @State private var pendingAction: PendingAction?
    /// 变量替换后的命令（用于危险确认流程）
    @State private var resolvedCommand: String?

    /// 延迟操作类型
    private enum PendingAction {
        case copy
        case run
    }

    var body: some View {
        if let snippet = snippet {
            VStack(alignment: .leading, spacing: 8) {
                // 命令预览区：等宽字体 + 深色背景（保留占位符原文）
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
                        handleAction(.copy, snippet: snippet)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.callout)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    // 运行按钮
                    Button {
                        handleAction(.run, snippet: snippet)
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
                        let cmd = resolvedCommand ?? snippet.command
                        let resolved = makeResolvedSnippet(snippet, command: cmd)
                        resolvedCommand = nil
                        onRun(resolved)
                    },
                    onCancel: {
                        showDangerConfirm = false
                        resolvedCommand = nil
                        pendingAction = nil
                    }
                )
            }
            .sheet(isPresented: $showVariableInput) {
                VariableInputView(
                    snippet: snippet,
                    onConfirm: { values in
                        showVariableInput = false
                        let cmd = VariableResolver.resolveCommand(
                            snippet.command,
                            variables: snippet.variables,
                            values: values
                        )
                        finishWithResolvedCommand(cmd, snippet: snippet)
                    },
                    onCancel: {
                        showVariableInput = false
                        pendingAction = nil
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

    // MARK: - 操作分发

    /// 处理按钮点击：有变量时先弹输入框，无变量时直接执行
    private func handleAction(_ action: PendingAction, snippet: Snippet) {
        pendingAction = action

        let hasVariables = snippet.variables != nil
            && !VariableResolver.extractVariableKeys(from: snippet.command).isEmpty

        if hasVariables {
            showVariableInput = true
        } else {
            finishWithResolvedCommand(snippet.command, snippet: snippet)
        }
    }

    /// 拿到最终命令后，根据操作类型和危险等级决定下一步
    private func finishWithResolvedCommand(_ command: String, snippet: Snippet) {
        guard let action = pendingAction else { return }

        switch action {
        case .copy:
            pendingAction = nil
            onCopy(command)
        case .run:
            switch snippet.dangerLevel {
            case .safe:
                pendingAction = nil
                onRun(makeResolvedSnippet(snippet, command: command))
            case .caution, .danger:
                // 暂存替换后的命令，等危险确认后再执行
                resolvedCommand = command
                showDangerConfirm = true
            }
        }
    }

    /// 用替换后的命令构造临时 Snippet
    private func makeResolvedSnippet(_ snippet: Snippet, command: String) -> Snippet {
        Snippet(
            id: snippet.id,
            title: snippet.title,
            description: snippet.description,
            tool: snippet.tool,
            category: snippet.category,
            tags: snippet.tags,
            command: command,
            variables: nil,
            dangerLevel: snippet.dangerLevel,
            enabled: snippet.enabled
        )
    }
}
