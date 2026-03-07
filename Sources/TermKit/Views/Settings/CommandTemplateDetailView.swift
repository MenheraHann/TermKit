import SwiftUI

/// 单个命令模板的编辑表单
struct CommandTemplateDetailView: View {
    @EnvironmentObject private var model: TermKitModel
    let templateIndex: Int

    private var tmpl: CommandTemplate {
        guard model.config.commandTemplates.indices.contains(templateIndex) else { return CommandTemplate(name: "", command: "") }
        return model.config.commandTemplates[templateIndex]
    }

    var body: some View {
        Form {
            Section(L10n.Templates.configuration) {
                TextField(L10n.Templates.templateName, text: templateBinding(\.name))
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading) {
                    Text(L10n.Templates.commandPattern)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField(L10n.Templates.commandPlaceholder, text: commandBinding(), axis: .vertical)
                        .lineLimit(2...5)
                        .font(.system(.body, design: .monospaced))
                        .textFieldStyle(.roundedBorder)
                }
            }

            Section(L10n.Templates.preview) {
                GroupBox {
                    HStack {
                        Text(tmpl.resolvedCommand().isEmpty ? L10n.Templates.awaitingInput : tmpl.resolvedCommand())
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(tmpl.resolvedCommand().isEmpty ? .tertiary : .primary)
                            .textSelection(.enabled)
                        Spacer()
                    }
                    .padding(4)
                }
            }

            Section(L10n.Templates.variableParameters) {
                if tmpl.variables.isEmpty {
                    Text(L10n.Templates.variableHint)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.vertical, 4)
                } else {
                    Grid(alignment: .leading, verticalSpacing: 12) {
                        GridRow {
                            Text(L10n.Templates.placeholder).fontWeight(.medium)
                            Text(L10n.Folders.displayName).fontWeight(.medium)
                            Text(L10n.Templates.defaultValue).fontWeight(.medium)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Divider()

                        ForEach(Array(tmpl.variables.enumerated()), id: \.element.id) { varIdx, variable in
                            GridRow {
                                Text("{\(variable.placeholder)}")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.blue)

                                TextField(L10n.Templates.varNamePlaceholder, text: variableBinding(varIdx, \.label))
                                    .textFieldStyle(.roundedBorder)
                                    .controlSize(.small)

                                TextField(L10n.Templates.optional, text: variableBinding(varIdx, \.defaultValue))
                                    .textFieldStyle(.roundedBorder)
                                    .controlSize(.small)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Bindings

    private func templateBinding<T>(_ keyPath: WritableKeyPath<CommandTemplate, T>) -> Binding<T> {
        Binding(
            get: { tmpl[keyPath: keyPath] },
            set: { value in
                guard model.config.commandTemplates.indices.contains(templateIndex) else { return }
                var next = model.config
                next.commandTemplates[templateIndex][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }

    /// 命令字段绑定：写入时自动同步变量列表
    private func commandBinding() -> Binding<String> {
        Binding(
            get: {
                guard model.config.commandTemplates.indices.contains(templateIndex) else { return "" }
                return model.config.commandTemplates[templateIndex].command
            },
            set: { value in
                guard model.config.commandTemplates.indices.contains(templateIndex) else { return }
                var next = model.config
                next.commandTemplates[templateIndex].command = value
                next.commandTemplates[templateIndex].syncVariables()
                model.saveConfig(next)
            }
        )
    }

    private func variableBinding(_ varIdx: Int, _ keyPath: WritableKeyPath<TemplateVariable, String>) -> Binding<String> {
        Binding(
            get: {
                guard model.config.commandTemplates.indices.contains(templateIndex),
                      model.config.commandTemplates[templateIndex].variables.indices.contains(varIdx) else { return "" }
                return model.config.commandTemplates[templateIndex].variables[varIdx][keyPath: keyPath]
            },
            set: { value in
                guard model.config.commandTemplates.indices.contains(templateIndex),
                      model.config.commandTemplates[templateIndex].variables.indices.contains(varIdx) else { return }
                var next = model.config
                next.commandTemplates[templateIndex].variables[varIdx][keyPath: keyPath] = value
                model.saveConfig(next)
            }
        )
    }
}
