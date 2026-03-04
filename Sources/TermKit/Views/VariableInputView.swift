import SwiftUI

/// 变量输入弹窗：让用户填写命令中 {KEY} 占位符的实际值
struct VariableInputView: View {
    let snippet: Snippet
    let onConfirm: ([String: String]) -> Void
    let onCancel: () -> Void

    /// 每个变量 key 对应的用户输入值
    @State private var values: [String: String] = [:]

    /// 从 snippet.variables 中过滤出命令里实际存在的变量
    private var activeVariables: [SnippetVariable] {
        let keys = VariableResolver.extractVariableKeys(from: snippet.command)
        let vars = snippet.variables ?? []
        // 按命令中出现顺序返回
        return keys.compactMap { key in vars.first { $0.key == key } }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("填写变量")
                .font(.headline)

            // 命令预览
            Text(snippet.command)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Divider()

            // 变量输入区
            ForEach(activeVariables) { variable in
                HStack {
                    Text(variable.label)
                        .frame(width: 80, alignment: .trailing)
                        .font(.callout)

                    TextField(
                        variable.default ?? variable.key,
                        text: binding(for: variable.key, default: variable.default)
                    )
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.callout, design: .monospaced))
                }
            }

            Divider()

            // 操作按钮
            HStack {
                Spacer()

                Button("取消") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("确认") {
                    onConfirm(values)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 360)
        .onAppear {
            // 用 default 值初始化
            for v in activeVariables {
                values[v.key] = v.default ?? ""
            }
        }
    }

    /// 为指定 key 创建双向绑定
    private func binding(for key: String, default defaultValue: String?) -> Binding<String> {
        Binding(
            get: { values[key] ?? defaultValue ?? "" },
            set: { values[key] = $0 }
        )
    }
}
