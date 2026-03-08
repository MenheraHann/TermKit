import AppKit
import Foundation

@MainActor
final class ConfigStore {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() -> TermKitConfig? {
        let url = configFileURL
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(TermKitConfig.self, from: data)
        } catch {
            NSLog("[TermKit] config decode failed: %@", error.localizedDescription)
            // 备份损坏的配置文件（带时间戳），防止被默认值覆盖后丢失
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyyMMdd-HHmmss"
            let stamp = fmt.string(from: Date())
            let backupName = "config.backup-\(stamp).json"
            let backupURL = url.deletingLastPathComponent()
                .appendingPathComponent(backupName)
            try? fileManager.copyItem(at: url, to: backupURL)
            NSLog("[TermKit] 已备份损坏配置到 %@", backupName)
            return nil
        }
    }

    func save(_ config: TermKitConfig) {
        do {
            try ensureConfigDirectoryExists()
            let data = try encoder.encode(config)
            try data.write(to: configFileURL, options: [.atomic])
        } catch {
            NSLog("[TermKit] failed to save config: %@", error.localizedDescription)
        }
    }

    var configFileURL: URL {
        configDirectoryURL.appendingPathComponent("config.json")
    }

    var configDirectoryURL: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("TermKit", isDirectory: true)
    }

    private func ensureConfigDirectoryExists() throws {
        let dir = configDirectoryURL
        if fileManager.fileExists(atPath: dir.path) { return }
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    static func openConfigFolderInFinder() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("TermKit", isDirectory: true)
        NSWorkspace.shared.open(dir)
    }
}

