import AppKit
import CoreGraphics
import Foundation

@MainActor
final class PasteService {
    func pasteTextWithClipboardRestore(_ text: String, restoreDelayMs: Int) {
        let pasteboard = NSPasteboard.general
        let snapshot = PasteboardSnapshot.capture(from: pasteboard)

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        sendPaste()

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(max(restoreDelayMs, 0))) {
            snapshot.restore(to: pasteboard)
        }
    }

    /// 发送 Ctrl+E（移到行尾）+ Ctrl+U（删除到行首）清空终端输入行
    func sendClearLine() {
        let src = CGEventSource(stateID: .combinedSessionState)
        let ctrlKey: CGKeyCode = 0x3B  // Left Control
        let eKey: CGKeyCode = 14
        let uKey: CGKeyCode = 32

        // Ctrl+E — 移到行尾
        let ctrlDown1 = CGEvent(keyboardEventSource: src, virtualKey: ctrlKey, keyDown: true)
        let eDown = CGEvent(keyboardEventSource: src, virtualKey: eKey, keyDown: true)
        let eUp = CGEvent(keyboardEventSource: src, virtualKey: eKey, keyDown: false)
        let ctrlUp1 = CGEvent(keyboardEventSource: src, virtualKey: ctrlKey, keyDown: false)

        ctrlDown1?.post(tap: .cghidEventTap)
        eDown?.flags = .maskControl
        eDown?.post(tap: .cghidEventTap)
        eUp?.flags = .maskControl
        eUp?.post(tap: .cghidEventTap)
        ctrlUp1?.post(tap: .cghidEventTap)

        // Ctrl+U — 删除到行首
        let ctrlDown2 = CGEvent(keyboardEventSource: src, virtualKey: ctrlKey, keyDown: true)
        let uDown = CGEvent(keyboardEventSource: src, virtualKey: uKey, keyDown: true)
        let uUp = CGEvent(keyboardEventSource: src, virtualKey: uKey, keyDown: false)
        let ctrlUp2 = CGEvent(keyboardEventSource: src, virtualKey: ctrlKey, keyDown: false)

        ctrlDown2?.post(tap: .cghidEventTap)
        uDown?.flags = .maskControl
        uDown?.post(tap: .cghidEventTap)
        uUp?.flags = .maskControl
        uUp?.post(tap: .cghidEventTap)
        ctrlUp2?.post(tap: .cghidEventTap)
    }

    func sendPaste() {
        let src = CGEventSource(stateID: .combinedSessionState)
        let vKey: CGKeyCode = 9
        let cmdDown = CGEvent(keyboardEventSource: src, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: src, virtualKey: vKey, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: src, virtualKey: vKey, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: src, virtualKey: 0x37, keyDown: false)

        cmdDown?.post(tap: .cghidEventTap)
        vDown?.flags = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        vUp?.flags = .maskCommand
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}

struct PasteboardSnapshot: Equatable {
    struct Item: Equatable {
        var typeToData: [String: Data]
    }

    var items: [Item]

    static func capture(from pasteboard: NSPasteboard) -> PasteboardSnapshot {
        let items: [Item] = (pasteboard.pasteboardItems ?? []).map { pbItem in
            var dict: [String: Data] = [:]
            for type in pbItem.types {
                if let data = pbItem.data(forType: type) {
                    dict[type.rawValue] = data
                }
            }
            return Item(typeToData: dict)
        }
        return PasteboardSnapshot(items: items)
    }

    func restore(to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        guard !items.isEmpty else { return }
        let pbItems: [NSPasteboardItem] = items.map { item in
            let pbItem = NSPasteboardItem()
            for (type, data) in item.typeToData {
                pbItem.setData(data, forType: NSPasteboard.PasteboardType(type))
            }
            return pbItem
        }
        pasteboard.writeObjects(pbItems)
    }
}

