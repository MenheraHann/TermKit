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
    var commandTemplates: [CommandTemplate]

    static let defaultValue = TermKitConfig(
        version: 1,
        features: Features(enableCmdHoldMenu: false),
        timing: Timing(holdThresholdMs: 300, clipboardRestoreDelayMs: 200),
        folders: [],
        clis: CLIEntry.defaultCLIs,
        imagePaste: ImagePasteConfig(saveDirectory: "Library/Application Support/TermKit/Images"),
        commandTemplates: []
    )

    // 向后兼容：旧 config.json 没有 commandTemplates 字段时使用空数组
    init(
        version: Int,
        features: Features,
        timing: Timing,
        folders: [FolderEntry],
        clis: [CLIEntry],
        imagePaste: ImagePasteConfig,
        commandTemplates: [CommandTemplate] = []
    ) {
        self.version = version
        self.features = features
        self.timing = timing
        self.folders = folders
        self.clis = clis
        self.imagePaste = imagePaste
        self.commandTemplates = commandTemplates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        features = try container.decode(Features.self, forKey: .features)
        timing = try container.decode(Timing.self, forKey: .timing)
        folders = try container.decode([FolderEntry].self, forKey: .folders)
        clis = try container.decode([CLIEntry].self, forKey: .clis)
        imagePaste = try container.decode(ImagePasteConfig.self, forKey: .imagePaste)
        commandTemplates = try container.decodeIfPresent([CommandTemplate].self, forKey: .commandTemplates) ?? []
    }

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

/// 命令模板：支持 {变量} 占位符的预设命令
struct CommandTemplate: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String              // 模板名称，如 "Git checkout"
    var command: String            // 命令，如 "git checkout {branch}"
    var variables: [TemplateVariable]  // 从 command 中解析的变量列表

    init(id: UUID = UUID(), name: String, command: String, variables: [TemplateVariable] = []) {
        self.id = id
        self.name = name
        self.command = command
        self.variables = variables
    }

    /// 用正则 \{([^}]+)\} 从 command 中解析占位符，同步 variables 列表
    mutating func syncVariables() {
        let pattern = try! NSRegularExpression(pattern: "\\{([^}]+)\\}")
        let range = NSRange(command.startIndex..., in: command)
        let matches = pattern.matches(in: command, range: range)
        let placeholders = matches.compactMap { match -> String? in
            guard let r = Range(match.range(at: 1), in: command) else { return nil }
            return String(command[r])
        }
        // 去重：同一占位符出现多次只保留一个变量条目
        var seen = Set<String>()
        let uniquePlaceholders = placeholders.filter { seen.insert($0).inserted }
        // 保留已有变量的 label/defaultValue，新增的用空值
        var updated: [TemplateVariable] = []
        for ph in uniquePlaceholders {
            if let existing = variables.first(where: { $0.placeholder == ph }) {
                updated.append(existing)
            } else {
                updated.append(TemplateVariable(placeholder: ph))
            }
        }
        variables = updated
    }

    /// 替换变量生成最终命令（有默认值的替换，无默认值的保留原样）
    func resolvedCommand() -> String {
        var result = command
        for v in variables {
            if !v.defaultValue.isEmpty {
                result = result.replacingOccurrences(of: "{\(v.placeholder)}", with: v.defaultValue)
            }
        }
        return result
    }
}

/// 模板变量
struct TemplateVariable: Codable, Equatable, Identifiable {
    var id: UUID
    var placeholder: String       // 占位符名（不含花括号），如 "branch"
    var label: String             // 显示名称，如 "分支名"
    var defaultValue: String      // 默认值

    init(id: UUID = UUID(), placeholder: String, label: String = "", defaultValue: String = "") {
        self.id = id
        self.placeholder = placeholder
        self.label = label
        self.defaultValue = defaultValue
    }
}

