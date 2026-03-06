import SwiftUI

/// 设置界面侧边栏分区
enum SettingsSection: String, CaseIterable, Identifiable {
    case general = "通用"
    case folders = "文件夹"
    case cliTools = "CLI 工具"
    case templates = "命令模板"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general:   return "gearshape"
        case .folders:   return "folder"
        case .cliTools:  return "terminal"
        case .templates: return "doc.text"
        }
    }
}

/// 设置窗口根视图：侧边栏 + 详情面板
struct SettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedSection: SettingsSection? = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 150, ideal: 170, max: 200)
        } detail: {
            switch selectedSection {
            case .general:
                GeneralSettingsView()
                    .environmentObject(model)
            case .folders:
                FoldersSettingsView()
                    .environmentObject(model)
            case .cliTools:
                CLISettingsView()
                    .environmentObject(model)
            case .templates:
                CommandTemplatesSettingsView()
                    .environmentObject(model)
            case .none:
                Text("请在左侧选择一个分区")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .frame(width: 700, height: 500)
    }
}
