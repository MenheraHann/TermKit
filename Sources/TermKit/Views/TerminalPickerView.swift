import SwiftUI

/// 终端选择弹窗：让用户选择要发送命令的终端
struct TerminalPickerView: View {
    let onSelect: (TerminalType) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 标题
            Label("选择终端", systemImage: "terminal")
                .font(.headline)

            Text("将命令发送到哪个终端？")
                .font(.callout)
                .foregroundStyle(.secondary)

            Divider()

            // 终端选项
            HStack(spacing: 12) {
                terminalButton(
                    name: "iTerm2",
                    icon: "rectangle.topthird.inset.filled",
                    type: .iTerm2
                )

                terminalButton(
                    name: "Terminal",
                    icon: "apple.terminal",
                    type: .terminal
                )
            }

            Divider()

            Button("取消") { onCancel() }
                .keyboardShortcut(.cancelAction)
        }
        .padding(20)
        .frame(width: 280)
    }

    @ViewBuilder
    private func terminalButton(name: String, icon: String, type: TerminalType) -> some View {
        Button {
            onSelect(type)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                Text(name)
                    .font(.callout.bold())
            }
            .frame(width: 100, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}
