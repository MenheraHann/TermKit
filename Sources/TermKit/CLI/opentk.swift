import Foundation

// CLI 入口：向已运行的 TermKit 发送分布式通知，触发面板切换
@main
struct OpenTKCLI {
    static func main() {
        let center = DistributedNotificationCenter.default()
        center.post(name: Notification.Name("com.termkit.toggle"), object: nil)
    }
}
