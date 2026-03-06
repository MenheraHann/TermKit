import Foundation

@MainActor
final class CmdHoldMenuState: ObservableObject {
    @Published private(set) var config: TermKitConfig = .defaultValue
    @Published private(set) var breadcrumb: [String] = ["TermKit"]
    @Published private(set) var level: CmdHoldMenuLevel = .root
    @Published private(set) var selectedIndex: Int = -1

    private var selectedFolder: FolderEntry?
    private var selectedCLI: CLIEntry?

    /// 编号项数量（根菜单中排除工具项，子菜单中全部编号）
    var numberedItemCount: Int {
        if level == .root {
            return currentItems.filter { item in
                switch item.kind {
                case .pasteImage, .deleteInput: return false
                default: return true
                }
            }.count
        }
        return currentItems.count
    }

    var currentItems: [CmdHoldMenuItem] {
        switch level {
        case .root:
            return [
                CmdHoldMenuItem(title: "打开文件夹", kind: .openFolders),
                CmdHoldMenuItem(title: "选择启动 CLI", kind: .openCLIs),
                CmdHoldMenuItem(title: "粘贴", kind: .pasteImage),
                CmdHoldMenuItem(title: "清空输入", kind: .deleteInput)
            ]
        case .folders:
            var items = config.folders.map { folder in
                CmdHoldMenuItem(title: folder.title, subtitle: folder.path, kind: .folder(folder))
            }
            items.append(CmdHoldMenuItem(title: "添加文件夹…", kind: .addFolder))
            return items
        case .clis:
            var items = config.clis.map { cli in
                CmdHoldMenuItem(title: cli.name, kind: .cli(cli))
            }
            items.append(CmdHoldMenuItem(title: "添加 CLI…", kind: .addCLI))
            return items
        case .actions:
            guard let cli = selectedCLI else { return [] }
            var items: [CmdHoldMenuItem] = []
            if let cmd = cli.startCommand, !cmd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(CmdHoldMenuItem(title: cli.startLabel ?? "启动", subtitle: cmd, kind: .actionCommand(cmd)))
            }
            if let cmd = cli.continueCommand, !cmd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(CmdHoldMenuItem(title: cli.continueLabel ?? "继续上次", subtitle: cmd, kind: .actionCommand(cmd)))
            }
            if let cmd = cli.resumeCommand, !cmd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(CmdHoldMenuItem(title: cli.resumeLabel ?? "恢复对话", subtitle: cmd, kind: .actionCommand(cmd)))
            }
            for action in cli.customActions {
                items.append(CmdHoldMenuItem(title: action.title, subtitle: action.command, kind: .actionCommand(action.command)))
            }
            items.append(CmdHoldMenuItem(title: "添加动作…", kind: .addAction(cli.id)))
            return items
        }
    }

    var releaseHint: String? {
        switch currentAction {
        case .pasteText(let text):
            return "⏎ " + abbreviateCommand(text)
        case .pasteImagePath:
            return "⏎ 粘贴剪贴板里的 文字 或 图片"
        case .deleteInput:
            return "⏎ 清空输入"
        case .showAddFolder, .showAddCLI, .showAddAction, .none:
            return nil
        }
    }

    var currentAction: CmdHoldMenuConfirmedAction? {
        guard currentItems.indices.contains(selectedIndex) else {
            // CLI 层且有已选文件夹 → 返回 cd 命令
            if level == .clis, let folder = selectedFolder {
                let command = "cd \(ShellQuote.single((folder.path as NSString).expandingTildeInPath))"
                return .pasteText(command)
            }
            return nil
        }
        let item = currentItems[selectedIndex]
        switch item.kind {
        case .pasteImage:
            return .pasteImagePath
        case .deleteInput:
            return .deleteInput
        case .addFolder:
            return .showAddFolder
        case .addCLI:
            return .showAddCLI
        case .addAction(let cliID):
            return .showAddAction(cliID)
        case .folder(let folder):
            let command = "cd \(ShellQuote.single((folder.path as NSString).expandingTildeInPath))"
            return .pasteText(command)
        case .actionCommand(let actionCmd):
            return .pasteText(buildCommand(actionCmd))
        case .cli:
            // 选中 CLI 但有已选文件夹 → 显示/执行 cd
            if let folder = selectedFolder {
                let command = "cd \(ShellQuote.single((folder.path as NSString).expandingTildeInPath))"
                return .pasteText(command)
            }
            return nil
        case .openFolders, .openCLIs:
            return nil
        }
    }

    func applyConfig(_ config: TermKitConfig) {
        self.config = config
    }

    func reset() {
        breadcrumb = ["TermKit"]
        level = .root
        selectedIndex = -1
        selectedFolder = nil
        selectedCLI = nil
    }

    func select(index: Int) {
        guard !currentItems.isEmpty else { return }
        selectedIndex = min(max(index, 0), currentItems.count - 1)
    }

    func commitSelection() {
        guard currentItems.indices.contains(selectedIndex) else { return }
        let item = currentItems[selectedIndex]
        switch item.kind {
        case .openFolders:
            level = .folders
            breadcrumb = ["TermKit", "打开文件夹"]
            selectedIndex = -1
        case .openCLIs:
            level = .clis
            breadcrumb = ["TermKit", "选择启动 CLI"]
            selectedIndex = -1
        case .folder(let folder):
            selectedFolder = folder
            level = .clis
            breadcrumb = ["TermKit", folder.title, "选择启动 CLI"]
            selectedIndex = -1
        case .cli(let cli):
            selectedCLI = cli
            level = .actions
            breadcrumb = (selectedFolder != nil ? ["TermKit", selectedFolder!.title, cli.name] : ["TermKit", cli.name])
            selectedIndex = -1
        case .pasteImage, .deleteInput, .addFolder, .addCLI, .addAction, .actionCommand:
            break
        }
    }

    func navigate(_ nav: CmdHoldMenuNavigation) {
        switch nav {
        case .up:
            if selectedIndex < 0 {
                select(index: currentItems.count - 1)
            } else {
                select(index: selectedIndex - 1)
            }
        case .down:
            if selectedIndex < 0 {
                select(index: 0)
            } else {
                select(index: selectedIndex + 1)
            }
        case .forward:
            if selectedIndex < 0 {
                select(index: 0)
            } else {
                commitSelection()
            }
        case .back:
            goBack()
        }
    }

    private func goBack() {
        switch level {
        case .root:
            break
        case .folders:
            reset()
        case .clis:
            if let folder = selectedFolder {
                level = .folders
                breadcrumb = ["TermKit", "打开文件夹"]
                if let idx = config.folders.firstIndex(where: { $0.id == folder.id }) {
                    selectedIndex = idx
                } else {
                    selectedIndex = 0
                }
            } else {
                reset()
            }
        case .actions:
            level = .clis
            if let folder = selectedFolder {
                breadcrumb = ["TermKit", folder.title, "选择启动 CLI"]
            } else {
                breadcrumb = ["TermKit", "选择启动 CLI"]
            }
            if let cli = selectedCLI, let idx = config.clis.firstIndex(where: { $0.id == cli.id }) {
                selectedIndex = idx
            } else {
                selectedIndex = 0
            }
        }
    }

    /// 智能缩略命令：保留最后一段命令，cd 路径用 … 替代
    private func abbreviateCommand(_ text: String, maxLength: Int = 40) -> String {
        if text.count <= maxLength { return text }

        // 有 && → 保留最后一段命令，前面缩略为 "cd …"
        if let range = text.range(of: " && ", options: .backwards) {
            let tail = String(text[range.upperBound...])
            let abbreviated = "cd … && " + tail
            if abbreviated.count <= maxLength { return abbreviated }
            return String(abbreviated.suffix(maxLength - 1)) + "…"
        }

        // 纯 cd 命令 → "cd …/文件夹名"
        if text.hasPrefix("cd ") {
            let pathPart = text.dropFirst(3)
                .trimmingCharacters(in: CharacterSet(charactersIn: "' \""))
            let lastComponent = URL(fileURLWithPath: pathPart).lastPathComponent
            return "cd …/\(lastComponent)"
        }

        // 其他 → 从尾部截取
        return "…" + String(text.suffix(maxLength - 1))
    }

    private func buildCommand(_ action: String) -> String {
        let actionTrimmed = action.trimmingCharacters(in: .whitespacesAndNewlines)
        if let folder = selectedFolder {
            let expanded = (folder.path as NSString).expandingTildeInPath
            let cd = "cd \(ShellQuote.single(expanded))"
            if actionTrimmed.isEmpty { return cd }
            return "\(cd) && \(actionTrimmed)"
        }
        return actionTrimmed
    }
}

enum CmdHoldMenuLevel: Equatable {
    case root
    case folders
    case clis
    case actions
}

enum CmdHoldMenuNavigation: Equatable {
    case up
    case down
    case back
    case forward
}

struct CmdHoldMenuItem: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var subtitle: String?
    var kind: Kind

    enum Kind: Equatable {
        case openFolders
        case openCLIs
        case pasteImage
        case deleteInput
        case addFolder
        case addCLI
        case addAction(UUID)
        case folder(FolderEntry)
        case cli(CLIEntry)
        case actionCommand(String)
    }
}

enum CmdHoldMenuConfirmedAction: Equatable {
    case pasteText(String)
    case pasteImagePath
    case deleteInput
    case showAddFolder
    case showAddCLI
    case showAddAction(UUID)
}

enum ShellQuote {
    static func single(_ text: String) -> String {
        if text.isEmpty { return "''" }
        return "'" + text.replacingOccurrences(of: "'", with: "'\"'\"'") + "'"
    }
}
