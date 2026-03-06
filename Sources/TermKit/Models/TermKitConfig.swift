import Foundation
import CoreGraphics

/// 用户可选的触发修饰键
enum TriggerModifierKey: String, Codable, CaseIterable {
    case command  // ⌘
    case option   // ⌥
    case control  // ⌃
    case fn       // fn/Globe

    /// 对应的 CGEventFlags 掩码
    var cgEventFlag: CGEventFlags {
        switch self {
        case .command:  return .maskCommand
        case .option:   return .maskAlternate
        case .control:  return .maskControl
        case .fn:       return .maskSecondaryFn
        }
    }

    /// 显示名称（用于设置界面）
    var displayName: String {
        switch self {
        case .command:  return "⌘ Command"
        case .option:   return "⌥ Option"
        case .control:  return "⌃ Control"
        case .fn:       return "fn Function"
        }
    }
}

struct TermKitConfig: Codable, Equatable {
    var version: Int
    var features: Features
    var timing: Timing
    var folders: [FolderEntry]
    var clis: [CLIEntry]
    var imagePaste: ImagePasteConfig

    static let defaultValue = TermKitConfig(
        version: 1,
        features: Features(enableCmdHoldMenu: false),
        timing: Timing(holdThresholdMs: 300, clipboardRestoreDelayMs: 200),
        folders: [],
        clis: CLIEntry.defaultCLIs,
        imagePaste: ImagePasteConfig(saveDirectory: "Library/Application Support/TermKit/Images")
    )

    struct Features: Codable, Equatable {
        var enableCmdHoldMenu: Bool
        var triggerKey: TriggerModifierKey

        // 向后兼容：旧 config.json 没有 triggerKey 字段时使用默认值
        init(enableCmdHoldMenu: Bool, triggerKey: TriggerModifierKey = .command) {
            self.enableCmdHoldMenu = enableCmdHoldMenu
            self.triggerKey = triggerKey
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            enableCmdHoldMenu = try container.decode(Bool.self, forKey: .enableCmdHoldMenu)
            triggerKey = try container.decodeIfPresent(TriggerModifierKey.self, forKey: .triggerKey) ?? .command
        }
    }

    struct Timing: Codable, Equatable {
        var holdThresholdMs: Int
        var clipboardRestoreDelayMs: Int
    }
}

struct FolderEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var title: String
    var path: String

    init(id: UUID = UUID(), title: String, path: String) {
        self.id = id
        self.title = title
        self.path = path
    }
}

struct CLIEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var startCommand: String?
    var continueCommand: String?
    var resumeCommand: String?
    var customActions: [CLIAction]
    var startLabel: String?
    var continueLabel: String?
    var resumeLabel: String?

    init(
        id: UUID = UUID(),
        name: String,
        startCommand: String? = nil,
        continueCommand: String? = nil,
        resumeCommand: String? = nil,
        customActions: [CLIAction] = [],
        startLabel: String? = nil,
        continueLabel: String? = nil,
        resumeLabel: String? = nil
    ) {
        self.id = id
        self.name = name
        self.startCommand = startCommand
        self.continueCommand = continueCommand
        self.resumeCommand = resumeCommand
        self.customActions = customActions
        self.startLabel = startLabel
        self.continueLabel = continueLabel
        self.resumeLabel = resumeLabel
    }

    static let defaultCLIs: [CLIEntry] = [
        CLIEntry(
            name: "Claude Code",
            startCommand: "claude",
            continueCommand: "claude --continue",
            resumeCommand: "claude --resume",
            customActions: [],
            startLabel: "新建对话",
            continueLabel: "继续上次对话",
            resumeLabel: "恢复历史对话"
        ),
        CLIEntry(
            name: "OpenAI Codex",
            startCommand: "codex",
            continueCommand: nil,
            resumeCommand: nil,
            customActions: [
                CLIAction(title: "Suggest", command: "codex --suggest"),
                CLIAction(title: "Auto Edit", command: "codex --auto-edit"),
                CLIAction(title: "Full Auto", command: "codex --full-auto")
            ],
            startLabel: "启动"
        ),
        CLIEntry(
            name: "Gemini CLI",
            startCommand: "gemini",
            continueCommand: nil,
            resumeCommand: nil,
            customActions: [],
            startLabel: "启动"
        ),
        CLIEntry(
            name: "Aider",
            startCommand: "aider",
            continueCommand: "aider --restore-chat-history",
            resumeCommand: nil,
            customActions: [],
            startLabel: "启动",
            continueLabel: "恢复聊天记录"
        ),
        CLIEntry(
            name: "OpenCode",
            startCommand: "opencode",
            continueCommand: "opencode --continue",
            resumeCommand: nil,
            customActions: [],
            startLabel: "启动",
            continueLabel: "继续上次"
        ),
        CLIEntry(
            name: "OpenClaw",
            startCommand: nil,
            continueCommand: nil,
            resumeCommand: nil,
            customActions: [
                CLIAction(title: "Open TUI", command: "openclaw tui")
            ]
        ),
        CLIEntry(
            name: "GitHub Copilot CLI",
            startCommand: nil,
            continueCommand: nil,
            resumeCommand: nil,
            customActions: []
        )
    ]
}

struct CLIAction: Codable, Equatable, Identifiable {
    var id: UUID
    var title: String
    var command: String

    init(id: UUID = UUID(), title: String, command: String) {
        self.id = id
        self.title = title
        self.command = command
    }
}

struct ImagePasteConfig: Codable, Equatable {
    var saveDirectory: String
}

