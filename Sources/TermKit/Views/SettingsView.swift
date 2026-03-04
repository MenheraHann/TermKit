import SwiftUI

/// 设置面板视图
struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text("设置")
                    .font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // 快捷键
            HStack {
                Label("快捷键", systemImage: "keyboard")
                    .font(.callout)
                Spacer()
                Text("⌥ Space")
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Run 按钮开关
            Toggle(isOn: $settings.showRunButton) {
                Label("显示 Run 按钮", systemImage: "play.fill")
                    .font(.callout)
            }

            // 危险命令确认开关
            Toggle(isOn: $settings.confirmDangerousCommands) {
                Label("危险命令确认", systemImage: "exclamationmark.triangle")
                    .font(.callout)
            }

            Divider()

            // 打开片段目录
            Button {
                let url = FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                ).first!.appendingPathComponent("TermKit")
                NSWorkspace.shared.open(url)
            } label: {
                Label("打开片段目录", systemImage: "folder")
                    .font(.callout)
            }

            Spacer()

            // 版本信息
            HStack {
                Spacer()
                Text("TermKit v0.5.0")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(20)
        .frame(width: 320, height: 340)
    }
}
