import AppKit
import Foundation

@MainActor
final class ImagePasteService {
    func savePasteboardImage(saveDirectory relativeToHome: String) -> URL? {
        guard let image = NSImage(pasteboard: .general) else { return nil }
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            return nil
        }

        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(relativeToHome, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            print("[TermKit] failed to create image dir: \(error)")
            return nil
        }

        let filename = "termkit-\(timestamp()).png"
        let url = dir.appendingPathComponent(filename)
        do {
            try png.write(to: url, options: [.atomic])
            return url
        } catch {
            print("[TermKit] failed to write image: \(error)")
            return nil
        }
    }

    private func timestamp() -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyyMMdd-HHmmss"
        return fmt.string(from: Date())
    }
}

