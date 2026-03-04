import SwiftUI

/// Toast 覆盖层视图，在底部居中显示短暂提示信息
struct ToastView: View {
    @ObservedObject var toast: ToastManager

    var body: some View {
        VStack {
            Spacer()
            if let message = toast.message {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.75))
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 12)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toast.message)
        .allowsHitTesting(toast.message != nil)
    }
}
