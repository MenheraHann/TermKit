import SwiftUI

/// macOS 14+ 移除侧边栏 toggle 按钮，低版本无操作
private struct HideSidebarToggleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.toolbar(removing: .sidebarToggle)
        } else {
            content
        }
    }
}

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

    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedSection) {
                Section {
                    ForEach(SettingsSection.allCases) { section in
                        Label(section.rawValue, systemImage: section.icon)
                            .tag(section)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 144, ideal: 160, max: 200)
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
        .modifier(HideSidebarToggleModifier())
        .navigationTitle("TermKit 设置")
        .frame(minWidth: 520, minHeight: 360)
        .frame(width: 600, height: 440)
        .onChange(of: columnVisibility) { newValue in
            if newValue != .all { columnVisibility = .all }
        }
    }
}
