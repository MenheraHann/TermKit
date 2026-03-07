import SwiftUI

/// 设置窗口根视图：原生 TabView 标签页样式
struct SettingsView: View {
    @EnvironmentObject private var model: TermKitModel

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label(L10n.Settings.general, systemImage: "gearshape") }
                .environmentObject(model)

            FoldersSettingsView()
                .tabItem { Label(L10n.Settings.folders, systemImage: "folder") }
                .environmentObject(model)

            CLISettingsView()
                .tabItem { Label(L10n.Settings.cliTools, systemImage: "terminal") }
                .environmentObject(model)

            CommandTemplatesSettingsView()
                .tabItem { Label(L10n.Settings.commandTemplates, systemImage: "doc.text") }
                .environmentObject(model)
        }
        .frame(minWidth: 520, maxWidth: .infinity, minHeight: 360, maxHeight: .infinity)
    }
}
