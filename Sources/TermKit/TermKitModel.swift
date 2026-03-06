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
        self.menu.applyConfig(self.config)
    }

    func reloadConfig() {
        let loaded = configStore.load() ?? TermKitConfig.defaultValue
        config = loaded
        menu.applyConfig(loaded)
    }

    func saveConfig(_ newConfig: TermKitConfig) {
        config = newConfig
        configStore.save(newConfig)
        menu.applyConfig(newConfig)
    }
}

