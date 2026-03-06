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
        guard let data = try? Data(contentsOf: configFileURL) else { return nil }
        return try? decoder.decode(TermKitConfig.self, from: data)
    }

    func save(_ config: TermKitConfig) {
        do {
            try ensureConfigDirectoryExists()
            let data = try encoder.encode(config)
            try data.write(to: configFileURL, options: [.atomic])
        } catch {
            print("[TermKit] failed to save config: \(error)")
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

