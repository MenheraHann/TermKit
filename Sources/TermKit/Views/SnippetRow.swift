import SwiftUI

/// 片段列表行视图，显示标题、标签、描述和危险等级指示器
struct SnippetRow: View {
    let snippet: Snippet

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // 危险等级指示圆点
            Circle()
                .fill(dangerColor)
                .frame(width: 8, height: 8)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 3) {
                // 标题
                Text(snippet.title)
                    .font(.callout.bold())
                    .lineLimit(1)

                // 标签
                if !snippet.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(snippet.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule()
                                        .fill(Color.primary.opacity(0.08))
                                )
                        }
                    }
                }

                // 描述
                Text(snippet.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 3)
    }

    /// 根据危险等级返回对应的颜色
    private var dangerColor: Color {
        switch snippet.dangerLevel {
        case .safe:    return .green
        case .caution: return .orange
        case .danger:  return .red
        }
    }
}
