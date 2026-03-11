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

    /// 对应的物理按键 keyCode（左侧 + 右侧），用于 CGEventSource.keyState 查询
    var cgKeyCodes: [CGKeyCode] {
        switch self {
        case .command:  return [55, 54]   // 0x37 Left Cmd, 0x36 Right Cmd
        case .option:   return [58, 61]   // 0x3A Left Opt, 0x3D Right Opt
        case .control:  return [59, 62]   // 0x3B Left Ctrl, 0x3E Right Ctrl
        case .fn:       return [63]       // 0x3F fn/Globe（无左右区分）
        }
    }

    /// 保持兼容：返回左侧 keyCode
    var cgKeyCode: CGKeyCode { cgKeyCodes[0] }

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
    var language: AppLanguage
    var allowedApps: [AppEntry]

    static var defaultValue: TermKitConfig { TermKitConfig(
        version: 1,
        features: Features(enableCmdHoldMenu: false),
        timing: Timing(holdThresholdMs: 0, clipboardRestoreDelayMs: 200),
        folders: [],
        clis: CLIEntry.defaultCLIs,
        imagePaste: ImagePasteConfig(saveDirectory: "Library/Application Support/TermKit/Images"),
        commandTemplates: [],
        language: .zhHans,
        allowedApps: AppEntry.defaultApps
    ) }

    // 向后兼容：旧 config.json 没有 commandTemplates / language 字段时使用默认值
    init(
        version: Int,
        features: Features,
        timing: Timing,
        folders: [FolderEntry],
        clis: [CLIEntry],
        imagePaste: ImagePasteConfig,
        commandTemplates: [CommandTemplate] = [],
        language: AppLanguage = .zhHans,
        allowedApps: [AppEntry] = AppEntry.defaultApps
    ) {
        self.version = version
        self.features = features
        self.timing = timing
        self.folders = folders
        self.clis = clis
        self.imagePaste = imagePaste
        self.commandTemplates = commandTemplates
        self.language = language
        self.allowedApps = allowedApps
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
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .zhHans
        allowedApps = try container.decodeIfPresent([AppEntry].self, forKey: .allowedApps) ?? AppEntry.defaultApps
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
    var icon: String?

    init(id: UUID = UUID(), title: String, path: String, icon: String? = nil) {
        self.id = id
        self.title = title
        self.path = path
        self.icon = icon
    }
}

struct AppEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String       // app 显示名称
    var bundleID: String   // bundle identifier

    init(id: UUID = UUID(), name: String, bundleID: String) {
        self.id = id
        self.name = name
        self.bundleID = bundleID
    }

    /// 内置默认白名单（终端 + 内置终端的编辑器）
    static let defaultApps: [AppEntry] = [
        AppEntry(name: "Terminal", bundleID: "com.apple.Terminal"),
        AppEntry(name: "iTerm2", bundleID: "com.googlecode.iterm2"),
        AppEntry(name: "Warp", bundleID: "dev.warp.Warp-Stable"),
        AppEntry(name: "kitty", bundleID: "net.kovidgoyal.kitty"),
        AppEntry(name: "Alacritty", bundleID: "org.alacritty"),
        AppEntry(name: "Hyper", bundleID: "co.zeit.hyper"),
        AppEntry(name: "WezTerm", bundleID: "com.github.wez.wezterm"),
        AppEntry(name: "Rio", bundleID: "com.raphaelamorim.rio"),
        AppEntry(name: "Ghostty", bundleID: "com.mitchellh.ghostty"),
        AppEntry(name: "MacTerm", bundleID: "dev.kdrag0n.MacTerm"),
        AppEntry(name: "JetBrains Fleet", bundleID: "com.jetbrains.fleet"),
        AppEntry(name: "VS Code", bundleID: "com.microsoft.VSCode"),
        AppEntry(name: "Cursor", bundleID: "com.todesktop.230313mzl4w4u92"),
    ]
}

struct CLIEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var note: String
    var actions: [CLIAction]
    var icon: String?

    init(id: UUID = UUID(), name: String, note: String = "", actions: [CLIAction] = [], icon: String? = nil) {
        self.id = id
        self.name = name
        self.note = note
        self.actions = actions
        self.icon = icon
    }

    // 向后兼容解码：先尝试新格式，失败则回退读取旧字段并转换
    private enum CodingKeys: String, CodingKey {
        case id, name, note, actions, icon
        // 旧字段
        case startCommand, continueCommand, resumeCommand
        case startLabel, continueLabel, resumeLabel
        case customActions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        icon = try container.decodeIfPresent(String.self, forKey: .icon)

        // 优先解码新格式
        if let newActions = try container.decodeIfPresent([CLIAction].self, forKey: .actions) {
            actions = newActions
        } else {
            // 回退读取旧字段
            var migrated: [CLIAction] = []
            let startCmd = try container.decodeIfPresent(String.self, forKey: .startCommand)
            let startLabel = try container.decodeIfPresent(String.self, forKey: .startLabel)
            if let cmd = startCmd, !cmd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                migrated.append(CLIAction(title: startLabel ?? L10n.DefaultCLI.launch, command: cmd))
            }
            let contCmd = try container.decodeIfPresent(String.self, forKey: .continueCommand)
            let contLabel = try container.decodeIfPresent(String.self, forKey: .continueLabel)
            if let cmd = contCmd, !cmd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                migrated.append(CLIAction(title: contLabel ?? L10n.DefaultCLI.continueLast, command: cmd))
            }
            let resumeCmd = try container.decodeIfPresent(String.self, forKey: .resumeCommand)
            let resumeLabel = try container.decodeIfPresent(String.self, forKey: .resumeLabel)
            if let cmd = resumeCmd, !cmd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                migrated.append(CLIAction(title: resumeLabel ?? L10n.DefaultCLI.resumeHistory, command: cmd))
            }
            let oldCustom = try container.decodeIfPresent([CLIAction].self, forKey: .customActions) ?? []
            migrated.append(contentsOf: oldCustom)
            actions = migrated
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(note, forKey: .note)
        try container.encode(actions, forKey: .actions)
        try container.encodeIfPresent(icon, forKey: .icon)
    }

    static var defaultCLIs: [CLIEntry] {
        [
            CLIEntry(name: "Claude Code", actions: [
                CLIAction(title: L10n.DefaultCLI.newChat, command: "claude"),
                CLIAction(title: L10n.DefaultCLI.continueLast, command: "claude --continue"),
                CLIAction(title: L10n.DefaultCLI.resumeHistory, command: "claude --resume"),
                CLIAction(title: L10n.DefaultCLI.showVersion, command: "claude --version"),
                CLIAction(title: L10n.DefaultCLI.showHelp, command: "claude --help"),
                CLIAction(title: L10n.DefaultCLI.listMCPServers, command: "claude mcp list"),
                CLIAction(title: L10n.DefaultCLI.checkHealth, command: "claude doctor"),
                CLIAction(title: L10n.DefaultCLI.checkUpdate, command: "claude update"),
                CLIAction(title: L10n.DefaultCLI.viewConfig, command: "claude config"),
            ], icon: "custom:claude"),
            CLIEntry(name: "OpenAI Codex", actions: [
                CLIAction(title: L10n.DefaultCLI.launch, command: "codex"),
                CLIAction(title: L10n.DefaultCLI.resumeHistory, command: "codex --resume"),
                CLIAction(title: "Suggest", command: "codex --suggest"),
                CLIAction(title: "Auto Edit", command: "codex --auto-edit"),
                CLIAction(title: "Full Auto", command: "codex --full-auto"),
                CLIAction(title: L10n.DefaultCLI.showVersion, command: "codex --version"),
            ], icon: "custom:openai"),
            CLIEntry(name: "Gemini CLI", actions: [
                CLIAction(title: L10n.DefaultCLI.launch, command: "gemini"),
                CLIAction(title: L10n.DefaultCLI.resumeHistory, command: "gemini --resume"),
                CLIAction(title: L10n.DefaultCLI.showVersion, command: "gemini --version"),
                CLIAction(title: L10n.DefaultCLI.showHelp, command: "gemini --help"),
            ], icon: "custom:gemini"),
            CLIEntry(name: "OpenCode", actions: [
                CLIAction(title: L10n.DefaultCLI.launch, command: "opencode"),
                CLIAction(title: L10n.DefaultCLI.continueLast, command: "opencode --continue"),
                CLIAction(title: "Init", command: "opencode init"),
                CLIAction(title: L10n.DefaultCLI.showVersion, command: "opencode --version"),
                CLIAction(title: L10n.DefaultCLI.showHelp, command: "opencode --help"),
            ], icon: "custom:opencode-logo-light"),
            CLIEntry(name: "OpenClaw", actions: [
                CLIAction(title: "Open TUI", command: "openclaw tui"),
                CLIAction(title: "Setup", command: "openclaw setup"),
                CLIAction(title: "Status", command: "openclaw status"),
                CLIAction(title: "Sessions", command: "openclaw sessions"),
                CLIAction(title: L10n.DefaultCLI.checkHealth, command: "openclaw doctor"),
                CLIAction(title: L10n.DefaultCLI.checkUpdate, command: "openclaw update"),
            ], icon: "custom:openclaw"),
            CLIEntry(name: "GitHub Copilot CLI", actions: [
                CLIAction(title: "Suggest", command: "gh copilot suggest"),
                CLIAction(title: "Explain", command: "gh copilot explain"),
            ], icon: "custom:githubcopilot"),
        ]
    }
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
    var icon: String?

    init(id: UUID = UUID(), name: String, command: String, variables: [TemplateVariable] = [], icon: String? = nil) {
        self.id = id
        self.name = name
        self.command = command
        self.variables = variables
        self.icon = icon
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

/// 路径缩略：将 home 目录前缀替换为 ~
func abbreviatePath(_ path: String) -> String {
    let home = NSHomeDirectory()
    if path.hasPrefix(home) {
        return "~" + path.dropFirst(home.count)
    }
    return path
}

