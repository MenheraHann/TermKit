import Foundation
import SwiftUI

@MainActor
final class TermKitModel: ObservableObject {
    @Published private(set) var config: TermKitConfig

    let configStore: ConfigStore
    let menu: CmdHoldMenuCoordinator

    init() {
        self.configStore = ConfigStore()
        self.config = configStore.load() ?? TermKitConfig.defaultValue
        self.menu = CmdHoldMenuCoordinator(configStore: configStore)
        L10n.current = self.config.language
        self.menu.applyConfig(self.config)
        self.menu.onConfigDidChange = { [weak self] newConfig in
            guard let self else { return }
            self.config = newConfig
            // 即使 config 未变（如暂停状态切换），也需刷新 UI
            self.objectWillChange.send()
        }
    }

    func reloadConfig() {
        let loaded = configStore.load() ?? TermKitConfig.defaultValue
        config = loaded
        L10n.current = loaded.language
        menu.applyConfig(loaded)
    }

    func saveConfig(_ newConfig: TermKitConfig) {
        config = newConfig
        L10n.current = newConfig.language
        configStore.save(newConfig)
        menu.applyConfig(newConfig)
    }
}

