import SwiftUI

/// 设置窗口根视图：自定义 toolbar 标签页 + 窗口标题
struct SettingsView: View {
    @EnvironmentObject private var model: TermKitModel
    @State private var selectedTab = 0

    var body: some View {
        Group {
            switch selectedTab {
            case 0: GeneralSettingsView().environmentObject(model)
            case 1: FoldersSettingsView().environmentObject(model)
            case 2: CLISettingsView().environmentObject(model)
            default: CommandTemplatesSettingsView().environmentObject(model)
            }
        }
        .frame(minWidth: 520, maxWidth: .infinity, minHeight: 360, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $selectedTab) {
                    Label(L10n.Settings.general, systemImage: "gearshape").tag(0)
                    Label(L10n.Settings.folders, systemImage: "folder").tag(1)
                    Label(L10n.Settings.cliTools, systemImage: "terminal").tag(2)
                    Label(L10n.Settings.commandTemplates, systemImage: "doc.text").tag(3)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
