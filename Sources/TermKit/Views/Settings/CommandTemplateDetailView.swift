import SwiftUI

/// 单个命令模板的编辑表单
struct CommandTemplateDetailView: View {
    @EnvironmentObject private var model: TermKitModel
    let templateIndex: Int

    private var tmpl: CommandTemplate { model.config.commandTemplates[templateIndex] }

    var body: some View {
        ScrollView {
            Form {
                Section("基本信息") {
                    TextField("名称", text: templateBinding(\.name))
                    TextField("命令", text: commandBinding(), prompt: Text("如 git checkout {branch}"))
                        .font(.system(.body, design: .monospaced))
                }

                Section("预览") {
                    Text(tmpl.resolvedCommand())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Section("变量（从命令中自动检测）") {
                    if tmpl.variables.isEmpty {
                        Text("命令中没有 {变量} 占位符")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    } else {
                        ForEach(Array(tmpl.variables.enumerated()), id: \.element.id) { varIdx, variable in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("{\(variable.placeholder)}")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack {
                                    Text("显示名")
                                        .frame(width: 50, alignment: .trailing)
                                        .font(.caption)
                                    TextField("如 分支名", text: variableBinding(varIdx, \.label))
                                        .textFieldStyle(.roundedBorder)
                                        .controlSize(.small)
                                }
                                HStack {
                                    Text("默认值")
                                        .frame(width: 50, alignment: .trailing)
                                        .font(.caption)
                                    TextField("留空则执行时需要输入", text: variableBinding(varIdx, \.defaultValue))
                                        .textFieldStyle(.roundedBorder)
                                        .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
        }
    }

    // MARK: - Bindings

    private func templateBinding<T>(_ keyPath: WritableKeyPath<CommandTemplate, T>) -> Binding<T> {
        Binding(
            get: { model.config.commandTemplates[templateIndex][keyPath: keyPath] },
            set: { value in
                var next = model.config
                next.commandTemplates[templateIndex][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }

    /// 命令字段绑定：写入时自动同步变量列表
    private func commandBinding() -> Binding<String> {
        Binding(
            get: { model.config.commandTemplates[templateIndex].command },
            set: { value in
                var next = model.config
                next.commandTemplates[templateIndex].command = value
                next.commandTemplates[templateIndex].syncVariables()
                model.saveConfig(next)
            }
        )
    }

    private func variableBinding(_ varIdx: Int, _ keyPath: WritableKeyPath<TemplateVariable, String>) -> Binding<String> {
        Binding(
            get: { model.config.commandTemplates[templateIndex].variables[varIdx][keyPath: keyPath] },
            set: { value in
                var next = model.config
                next.commandTemplates[templateIndex].variables[varIdx][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }
}
