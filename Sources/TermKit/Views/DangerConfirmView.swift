import SwiftUI

/// 危险命令确认视图，根据 dangerLevel 显示不同级别的警告
struct DangerConfirmView: View {
    let snippet: Snippet
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 警告图标和标题
            warningHeader

            // 命令预览
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

            // 确认/取消按钮
            HStack(spacing: 12) {
                Button("取消") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Button(confirmButtonTitle) {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                .tint(confirmButtonColor)
                .controlSize(.regular)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    // MARK: - 警告头部

    @ViewBuilder
    private var warningHeader: some View {
        switch snippet.dangerLevel {
        case .danger:
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                Text("危险命令")
                    .font(.headline)
                    .foregroundStyle(.red)
            }
        case .caution:
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("注意")
                    .font(.headline)
                    .foregroundStyle(.yellow)
            }
        case .safe:
            EmptyView()
        }
    }

    // MARK: - 按钮样式

    private var confirmButtonTitle: String {
        snippet.dangerLevel == .danger ? "确认执行" : "执行"
    }

    private var confirmButtonColor: Color {
        snippet.dangerLevel == .danger ? .red : .orange
    }
}
