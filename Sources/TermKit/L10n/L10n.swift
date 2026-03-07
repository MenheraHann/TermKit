import Foundation

/// 自定义字典式本地化引擎
/// 通过 L10n.current 切换语言，所有 UI 字符串即时更新
enum L10n {
    /// 当前语言，由 TermKitModel 在 init/save/reload 时同步
    static var current: AppLanguage = .zhHans

    // MARK: - 菜单栏

    enum MenuBar {
        static var settingsWindowTitle: String {
            switch L10n.current {
            case .zhHans: return "TermKit 设置"
            case .zhHant: return "TermKit 設定"
            case .en:     return "TermKit Settings"
            case .ja:     return "TermKit 設定"
            case .ko:     return "TermKit 설정"
            case .es:     return "Ajustes de TermKit"
            case .fr:     return "Réglages TermKit"
            case .de:     return "TermKit Einstellungen"
            case .pt:     return "Configurações do TermKit"
            }
        }

        static var enableQuickMenu: String {
            switch L10n.current {
            case .zhHans: return "启用快捷菜单"
            case .zhHant: return "啟用快捷選單"
            case .en:     return "Enable Quick Menu"
            case .ja:     return "クイックメニューを有効化"
            case .ko:     return "빠른 메뉴 활성화"
            case .es:     return "Activar menú rápido"
            case .fr:     return "Activer le menu rapide"
            case .de:     return "Schnellmenü aktivieren"
            case .pt:     return "Ativar menu rápido"
            }
        }

        static var configure: String {
            switch L10n.current {
            case .zhHans: return "配置…"
            case .zhHant: return "設定…"
            case .en:     return "Settings…"
            case .ja:     return "設定…"
            case .ko:     return "설정…"
            case .es:     return "Ajustes…"
            case .fr:     return "Réglages…"
            case .de:     return "Einstellungen…"
            case .pt:     return "Configurações…"
            }
        }

        static var quit: String {
            switch L10n.current {
            case .zhHans: return "退出 TermKit"
            case .zhHant: return "結束 TermKit"
            case .en:     return "Quit TermKit"
            case .ja:     return "TermKit を終了"
            case .ko:     return "TermKit 종료"
            case .es:     return "Salir de TermKit"
            case .fr:     return "Quitter TermKit"
            case .de:     return "TermKit beenden"
            case .pt:     return "Sair do TermKit"
            }
        }
    }

    // MARK: - 设置 Tab

    enum Settings {
        static var general: String {
            switch L10n.current {
            case .zhHans: return "通用"
            case .zhHant: return "一般"
            case .en:     return "General"
            case .ja:     return "一般"
            case .ko:     return "일반"
            case .es:     return "General"
            case .fr:     return "Général"
            case .de:     return "Allgemein"
            case .pt:     return "Geral"
            }
        }

        static var folders: String {
            switch L10n.current {
            case .zhHans: return "文件夹"
            case .zhHant: return "檔案夾"
            case .en:     return "Folders"
            case .ja:     return "フォルダ"
            case .ko:     return "폴더"
            case .es:     return "Carpetas"
            case .fr:     return "Dossiers"
            case .de:     return "Ordner"
            case .pt:     return "Pastas"
            }
        }

        static var cliTools: String {
            switch L10n.current {
            case .zhHans: return "CLI 工具"
            case .zhHant: return "CLI 工具"
            case .en:     return "CLI Tools"
            case .ja:     return "CLI ツール"
            case .ko:     return "CLI 도구"
            case .es:     return "Herramientas CLI"
            case .fr:     return "Outils CLI"
            case .de:     return "CLI-Tools"
            case .pt:     return "Ferramentas CLI"
            }
        }

        static var commandTemplates: String {
            switch L10n.current {
            case .zhHans: return "命令模板"
            case .zhHant: return "命令範本"
            case .en:     return "Templates"
            case .ja:     return "テンプレート"
            case .ko:     return "명령 템플릿"
            case .es:     return "Plantillas"
            case .fr:     return "Modèles"
            case .de:     return "Vorlagen"
            case .pt:     return "Modelos"
            }
        }

        static var apps: String {
            switch L10n.current {
            case .zhHans: return "应用"
            case .zhHant: return "應用"
            case .en:     return "Apps"
            case .ja:     return "アプリ"
            case .ko:     return "앱"
            case .es:     return "Apps"
            case .fr:     return "Apps"
            case .de:     return "Apps"
            case .pt:     return "Apps"
            }
        }
    }

    // MARK: - 通用设置

    enum General {
        static var language: String {
            switch L10n.current {
            case .zhHans: return "语言"
            case .zhHant: return "語言"
            case .en:     return "Language"
            case .ja:     return "言語"
            case .ko:     return "언어"
            case .es:     return "Idioma"
            case .fr:     return "Langue"
            case .de:     return "Sprache"
            case .pt:     return "Idioma"
            }
        }

        static var interfaceLanguage: String {
            switch L10n.current {
            case .zhHans: return "界面语言"
            case .zhHant: return "介面語言"
            case .en:     return "Interface Language"
            case .ja:     return "表示言語"
            case .ko:     return "인터페이스 언어"
            case .es:     return "Idioma de la interfaz"
            case .fr:     return "Langue de l'interface"
            case .de:     return "Sprache der Oberfläche"
            case .pt:     return "Idioma da interface"
            }
        }

        static var launchAtLogin: String {
            switch L10n.current {
            case .zhHans: return "开机自动启动"
            case .zhHant: return "登入時自動啟動"
            case .en:     return "Launch at Login"
            case .ja:     return "ログイン時に起動"
            case .ko:     return "로그인 시 실행"
            case .es:     return "Abrir al iniciar sesión"
            case .fr:     return "Ouvrir à la connexion"
            case .de:     return "Beim Anmelden starten"
            case .pt:     return "Abrir ao iniciar sessão"
            }
        }

        static var quickMenu: String {
            switch L10n.current {
            case .zhHans: return "快捷菜单"
            case .zhHant: return "快捷選單"
            case .en:     return "Quick Menu"
            case .ja:     return "クイックメニュー"
            case .ko:     return "빠른 메뉴"
            case .es:     return "Menú rápido"
            case .fr:     return "Menu rapide"
            case .de:     return "Schnellmenü"
            case .pt:     return "Menu rápido"
            }
        }

        static var triggerKey: String {
            switch L10n.current {
            case .zhHans: return "触发修饰键"
            case .zhHant: return "觸發修飾鍵"
            case .en:     return "Trigger Key"
            case .ja:     return "トリガーキー"
            case .ko:     return "트리거 키"
            case .es:     return "Tecla de activación"
            case .fr:     return "Touche de déclenchement"
            case .de:     return "Auslösetaste"
            case .pt:     return "Tecla de ativação"
            }
        }

        static var timingParameters: String {
            switch L10n.current {
            case .zhHans: return "时间参数"
            case .zhHant: return "時間參數"
            case .en:     return "Timing"
            case .ja:     return "タイミング"
            case .ko:     return "타이밍"
            case .es:     return "Temporización"
            case .fr:     return "Temporisation"
            case .de:     return "Zeiteinstellungen"
            case .pt:     return "Temporização"
            }
        }

        static var holdThreshold: String {
            switch L10n.current {
            case .zhHans: return "长按阈值"
            case .zhHant: return "長按閾值"
            case .en:     return "Hold Threshold"
            case .ja:     return "長押ししきい値"
            case .ko:     return "길게 누르기 임계값"
            case .es:     return "Umbral de pulsación"
            case .fr:     return "Seuil de maintien"
            case .de:     return "Halteschwelle"
            case .pt:     return "Limiar de pressão"
            }
        }

        static var clipboardRestoreDelay: String {
            switch L10n.current {
            case .zhHans: return "剪贴板恢复延迟"
            case .zhHant: return "剪貼簿還原延遲"
            case .en:     return "Clipboard Restore Delay"
            case .ja:     return "クリップボード復元遅延"
            case .ko:     return "클립보드 복원 지연"
            case .es:     return "Retardo de restauración"
            case .fr:     return "Délai de restauration"
            case .de:     return "Wiederherstellungsverzögerung"
            case .pt:     return "Atraso de restauração"
            }
        }

        static var images: String {
            switch L10n.current {
            case .zhHans: return "图片"
            case .zhHant: return "圖片"
            case .en:     return "Images"
            case .ja:     return "画像"
            case .ko:     return "이미지"
            case .es:     return "Imágenes"
            case .fr:     return "Images"
            case .de:     return "Bilder"
            case .pt:     return "Imagens"
            }
        }

        static var saveDirectory: String {
            switch L10n.current {
            case .zhHans: return "保存目录"
            case .zhHant: return "儲存目錄"
            case .en:     return "Save Directory"
            case .ja:     return "保存先"
            case .ko:     return "저장 디렉토리"
            case .es:     return "Directorio de guardado"
            case .fr:     return "Répertoire de sauvegarde"
            case .de:     return "Speicherverzeichnis"
            case .pt:     return "Diretório de salvamento"
            }
        }

        static var configFile: String {
            switch L10n.current {
            case .zhHans: return "配置文件"
            case .zhHant: return "設定檔"
            case .en:     return "Config File"
            case .ja:     return "設定ファイル"
            case .ko:     return "설정 파일"
            case .es:     return "Archivo de configuración"
            case .fr:     return "Fichier de configuration"
            case .de:     return "Konfigurationsdatei"
            case .pt:     return "Arquivo de configuração"
            }
        }

        static var showInFinder: String {
            switch L10n.current {
            case .zhHans: return "在 Finder 中显示"
            case .zhHant: return "在 Finder 中顯示"
            case .en:     return "Show in Finder"
            case .ja:     return "Finder で表示"
            case .ko:     return "Finder에서 보기"
            case .es:     return "Mostrar en Finder"
            case .fr:     return "Afficher dans le Finder"
            case .de:     return "Im Finder anzeigen"
            case .pt:     return "Mostrar no Finder"
            }
        }

        static var chooseSaveDirectory: String {
            switch L10n.current {
            case .zhHans: return "选择保存目录"
            case .zhHant: return "選擇儲存目錄"
            case .en:     return "Choose Save Directory"
            case .ja:     return "保存先を選択"
            case .ko:     return "저장 디렉토리 선택"
            case .es:     return "Elegir directorio"
            case .fr:     return "Choisir le répertoire"
            case .de:     return "Verzeichnis wählen"
            case .pt:     return "Escolher diretório"
            }
        }
    }

    // MARK: - 文件夹设置

    enum Folders {
        static var addFolder: String {
            switch L10n.current {
            case .zhHans: return "添加文件夹"
            case .zhHant: return "新增檔案夾"
            case .en:     return "Add Folder"
            case .ja:     return "フォルダを追加"
            case .ko:     return "폴더 추가"
            case .es:     return "Añadir carpeta"
            case .fr:     return "Ajouter un dossier"
            case .de:     return "Ordner hinzufügen"
            case .pt:     return "Adicionar pasta"
            }
        }

        static var displayName: String {
            switch L10n.current {
            case .zhHans: return "显示名称"
            case .zhHant: return "顯示名稱"
            case .en:     return "Display Name"
            case .ja:     return "表示名"
            case .ko:     return "표시 이름"
            case .es:     return "Nombre"
            case .fr:     return "Nom affiché"
            case .de:     return "Anzeigename"
            case .pt:     return "Nome de exibição"
            }
        }

        static var name: String {
            switch L10n.current {
            case .zhHans: return "名称"
            case .zhHant: return "名稱"
            case .en:     return "Name"
            case .ja:     return "名前"
            case .ko:     return "이름"
            case .es:     return "Nombre"
            case .fr:     return "Nom"
            case .de:     return "Name"
            case .pt:     return "Nome"
            }
        }

        static var path: String {
            switch L10n.current {
            case .zhHans: return "路径"
            case .zhHant: return "路徑"
            case .en:     return "Path"
            case .ja:     return "パス"
            case .ko:     return "경로"
            case .es:     return "Ruta"
            case .fr:     return "Chemin"
            case .de:     return "Pfad"
            case .pt:     return "Caminho"
            }
        }

        static var location: String {
            switch L10n.current {
            case .zhHans: return "位置"
            case .zhHant: return "位置"
            case .en:     return "Location"
            case .ja:     return "場所"
            case .ko:     return "위치"
            case .es:     return "Ubicación"
            case .fr:     return "Emplacement"
            case .de:     return "Speicherort"
            case .pt:     return "Localização"
            }
        }

        static var selectOrAddFolder: String {
            switch L10n.current {
            case .zhHans: return "选择或添加一个文件夹"
            case .zhHant: return "選擇或新增一個檔案夾"
            case .en:     return "Select or add a folder"
            case .ja:     return "フォルダを選択または追加"
            case .ko:     return "폴더를 선택하거나 추가하세요"
            case .es:     return "Selecciona o añade una carpeta"
            case .fr:     return "Sélectionnez ou ajoutez un dossier"
            case .de:     return "Ordner auswählen oder hinzufügen"
            case .pt:     return "Selecione ou adicione uma pasta"
            }
        }

        static var chooseFolder: String {
            switch L10n.current {
            case .zhHans: return "选择文件夹"
            case .zhHant: return "選擇檔案夾"
            case .en:     return "Choose Folder"
            case .ja:     return "フォルダを選択"
            case .ko:     return "폴더 선택"
            case .es:     return "Elegir carpeta"
            case .fr:     return "Choisir un dossier"
            case .de:     return "Ordner wählen"
            case .pt:     return "Escolher pasta"
            }
        }

        static var changePath: String {
            switch L10n.current {
            case .zhHans: return "修改路径"
            case .zhHant: return "修改路徑"
            case .en:     return "Change Path"
            case .ja:     return "パスを変更"
            case .ko:     return "경로 변경"
            case .es:     return "Cambiar ruta"
            case .fr:     return "Modifier le chemin"
            case .de:     return "Pfad ändern"
            case .pt:     return "Alterar caminho"
            }
        }
    }

    // MARK: - 应用设置

    enum Apps {
        static var addApp: String {
            switch L10n.current {
            case .zhHans: return "添加应用"
            case .zhHant: return "新增應用"
            case .en:     return "Add App"
            case .ja:     return "アプリを追加"
            case .ko:     return "앱 추가"
            case .es:     return "Agregar app"
            case .fr:     return "Ajouter une app"
            case .de:     return "App hinzufügen"
            case .pt:     return "Adicionar app"
            }
        }

        static var selectOrAddApp: String {
            switch L10n.current {
            case .zhHans: return "选择或添加一个应用"
            case .zhHant: return "選擇或新增一個應用"
            case .en:     return "Select or add an app"
            case .ja:     return "アプリを選択または追加"
            case .ko:     return "앱을 선택하거나 추가하세요"
            case .es:     return "Selecciona o agrega una app"
            case .fr:     return "Sélectionnez ou ajoutez une app"
            case .de:     return "App auswählen oder hinzufügen"
            case .pt:     return "Selecione ou adicione um app"
            }
        }

        static var chooseApp: String {
            switch L10n.current {
            case .zhHans: return "选择应用"
            case .zhHant: return "選擇應用"
            case .en:     return "Choose App"
            case .ja:     return "アプリを選択"
            case .ko:     return "앱 선택"
            case .es:     return "Elegir app"
            case .fr:     return "Choisir une app"
            case .de:     return "App auswählen"
            case .pt:     return "Escolher app"
            }
        }

        static var bundleID: String {
            switch L10n.current {
            case .zhHans: return "Bundle ID"
            case .zhHant: return "Bundle ID"
            case .en:     return "Bundle ID"
            case .ja:     return "Bundle ID"
            case .ko:     return "Bundle ID"
            case .es:     return "Bundle ID"
            case .fr:     return "Bundle ID"
            case .de:     return "Bundle ID"
            case .pt:     return "Bundle ID"
            }
        }

        static var appInfo: String {
            switch L10n.current {
            case .zhHans: return "应用信息"
            case .zhHant: return "應用資訊"
            case .en:     return "App Info"
            case .ja:     return "アプリ情報"
            case .ko:     return "앱 정보"
            case .es:     return "Información de la app"
            case .fr:     return "Infos de l'app"
            case .de:     return "App-Info"
            case .pt:     return "Informações do app"
            }
        }

        static var resetToDefaults: String {
            switch L10n.current {
            case .zhHans: return "重置为默认"
            case .zhHant: return "重置為預設"
            case .en:     return "Reset to Defaults"
            case .ja:     return "デフォルトに戻す"
            case .ko:     return "기본값으로 재설정"
            case .es:     return "Restablecer"
            case .fr:     return "Réinitialiser"
            case .de:     return "Zurücksetzen"
            case .pt:     return "Redefinir"
            }
        }

        static var confirmReset: String {
            switch L10n.current {
            case .zhHans: return "确定要重置为默认应用列表吗？"
            case .zhHant: return "確定要重置為預設應用列表嗎？"
            case .en:     return "Reset to default app list?"
            case .ja:     return "デフォルトのアプリリストに戻しますか？"
            case .ko:     return "기본 앱 목록으로 재설정하시겠습니까?"
            case .es:     return "¿Restablecer la lista de apps predeterminada?"
            case .fr:     return "Réinitialiser la liste d'apps par défaut ?"
            case .de:     return "Auf Standard-App-Liste zurücksetzen?"
            case .pt:     return "Redefinir para a lista padrão de apps?"
            }
        }

        static var appAlreadyExists: String {
            switch L10n.current {
            case .zhHans: return "该应用已在列表中"
            case .zhHant: return "該應用已在列表中"
            case .en:     return "This app is already in the list"
            case .ja:     return "このアプリは既にリストにあります"
            case .ko:     return "이 앱은 이미 목록에 있습니다"
            case .es:     return "Esta app ya está en la lista"
            case .fr:     return "Cette app est déjà dans la liste"
            case .de:     return "Diese App ist bereits in der Liste"
            case .pt:     return "Este app já está na lista"
            }
        }
    }

    // MARK: - CLI 设置

    enum CLI {
        static func actionCount(_ n: Int) -> String {
            switch L10n.current {
            case .zhHans: return "\(n) 个动作"
            case .zhHant: return "\(n) 個動作"
            case .en:     return "\(n) action\(n == 1 ? "" : "s")"
            case .ja:     return "\(n) 個のアクション"
            case .ko:     return "\(n)개의 액션"
            case .es:     return "\(n) acción\(n == 1 ? "" : "es")"
            case .fr:     return "\(n) action\(n == 1 ? "" : "s")"
            case .de:     return "\(n) Aktion\(n == 1 ? "" : "en")"
            case .pt:     return n == 1 ? "1 ação" : "\(n) ações"
            }
        }

        static var addCLI: String {
            switch L10n.current {
            case .zhHans: return "添加 CLI 工具"
            case .zhHant: return "新增 CLI 工具"
            case .en:     return "Add CLI Tool"
            case .ja:     return "CLI ツールを追加"
            case .ko:     return "CLI 도구 추가"
            case .es:     return "Añadir herramienta CLI"
            case .fr:     return "Ajouter un outil CLI"
            case .de:     return "CLI-Tool hinzufügen"
            case .pt:     return "Adicionar ferramenta CLI"
            }
        }

        static var selectOrCreateCLI: String {
            switch L10n.current {
            case .zhHans: return "选择或创建一个 CLI 工具"
            case .zhHant: return "選擇或建立一個 CLI 工具"
            case .en:     return "Select or create a CLI tool"
            case .ja:     return "CLI ツールを選択または作成"
            case .ko:     return "CLI 도구를 선택하거나 만드세요"
            case .es:     return "Selecciona o crea una herramienta CLI"
            case .fr:     return "Sélectionnez ou créez un outil CLI"
            case .de:     return "CLI-Tool auswählen oder erstellen"
            case .pt:     return "Selecione ou crie uma ferramenta CLI"
            }
        }

        static var newCLI: String {
            switch L10n.current {
            case .zhHans: return "新 CLI 工具"
            case .zhHant: return "新 CLI 工具"
            case .en:     return "New CLI Tool"
            case .ja:     return "新しい CLI ツール"
            case .ko:     return "새 CLI 도구"
            case .es:     return "Nueva herramienta CLI"
            case .fr:     return "Nouvel outil CLI"
            case .de:     return "Neues CLI-Tool"
            case .pt:     return "Nova ferramenta CLI"
            }
        }

        static var basicInfo: String {
            switch L10n.current {
            case .zhHans: return "基本信息"
            case .zhHant: return "基本資訊"
            case .en:     return "Basic Info"
            case .ja:     return "基本情報"
            case .ko:     return "기본 정보"
            case .es:     return "Información básica"
            case .fr:     return "Informations"
            case .de:     return "Grundinfo"
            case .pt:     return "Informações básicas"
            }
        }

        static var toolName: String {
            switch L10n.current {
            case .zhHans: return "工具名称"
            case .zhHant: return "工具名稱"
            case .en:     return "Tool Name"
            case .ja:     return "ツール名"
            case .ko:     return "도구 이름"
            case .es:     return "Nombre"
            case .fr:     return "Nom de l'outil"
            case .de:     return "Toolname"
            case .pt:     return "Nome da ferramenta"
            }
        }

        static var noteOptional: String {
            switch L10n.current {
            case .zhHans: return "备注（可选）"
            case .zhHant: return "備註（可選）"
            case .en:     return "Note (optional)"
            case .ja:     return "メモ（任意）"
            case .ko:     return "메모 (선택)"
            case .es:     return "Nota (opcional)"
            case .fr:     return "Note (facultatif)"
            case .de:     return "Notiz (optional)"
            case .pt:     return "Nota (opcional)"
            }
        }

        static var noActions: String {
            switch L10n.current {
            case .zhHans: return "暂无动作"
            case .zhHant: return "暫無動作"
            case .en:     return "No actions"
            case .ja:     return "アクションなし"
            case .ko:     return "액션 없음"
            case .es:     return "Sin acciones"
            case .fr:     return "Aucune action"
            case .de:     return "Keine Aktionen"
            case .pt:     return "Sem ações"
            }
        }

        static var actionName: String {
            switch L10n.current {
            case .zhHans: return "动作名称"
            case .zhHant: return "動作名稱"
            case .en:     return "Action Name"
            case .ja:     return "アクション名"
            case .ko:     return "액션 이름"
            case .es:     return "Nombre de acción"
            case .fr:     return "Nom de l'action"
            case .de:     return "Aktionsname"
            case .pt:     return "Nome da ação"
            }
        }

        static var command: String {
            switch L10n.current {
            case .zhHans: return "命令"
            case .zhHant: return "命令"
            case .en:     return "Command"
            case .ja:     return "コマンド"
            case .ko:     return "명령"
            case .es:     return "Comando"
            case .fr:     return "Commande"
            case .de:     return "Befehl"
            case .pt:     return "Comando"
            }
        }

        static var deleteAction: String {
            switch L10n.current {
            case .zhHans: return "删除此动作"
            case .zhHant: return "刪除此動作"
            case .en:     return "Delete this action"
            case .ja:     return "このアクションを削除"
            case .ko:     return "이 액션 삭제"
            case .es:     return "Eliminar esta acción"
            case .fr:     return "Supprimer cette action"
            case .de:     return "Diese Aktion löschen"
            case .pt:     return "Excluir esta ação"
            }
        }

        static var addAction: String {
            switch L10n.current {
            case .zhHans: return "添加动作"
            case .zhHant: return "新增動作"
            case .en:     return "Add Action"
            case .ja:     return "アクションを追加"
            case .ko:     return "액션 추가"
            case .es:     return "Añadir acción"
            case .fr:     return "Ajouter une action"
            case .de:     return "Aktion hinzufügen"
            case .pt:     return "Adicionar ação"
            }
        }

        static var actionList: String {
            switch L10n.current {
            case .zhHans: return "动作列表"
            case .zhHant: return "動作列表"
            case .en:     return "Actions"
            case .ja:     return "アクション一覧"
            case .ko:     return "액션 목록"
            case .es:     return "Lista de acciones"
            case .fr:     return "Liste des actions"
            case .de:     return "Aktionsliste"
            case .pt:     return "Lista de ações"
            }
        }

        static var done: String {
            switch L10n.current {
            case .zhHans: return "完成"
            case .zhHant: return "完成"
            case .en:     return "Done"
            case .ja:     return "完了"
            case .ko:     return "완료"
            case .es:     return "Listo"
            case .fr:     return "Terminé"
            case .de:     return "Fertig"
            case .pt:     return "Concluído"
            }
        }

        static var edit: String {
            switch L10n.current {
            case .zhHans: return "编辑"
            case .zhHant: return "編輯"
            case .en:     return "Edit"
            case .ja:     return "編集"
            case .ko:     return "편집"
            case .es:     return "Editar"
            case .fr:     return "Modifier"
            case .de:     return "Bearbeiten"
            case .pt:     return "Editar"
            }
        }

        static var newAction: String {
            switch L10n.current {
            case .zhHans: return "新动作"
            case .zhHant: return "新動作"
            case .en:     return "New Action"
            case .ja:     return "新しいアクション"
            case .ko:     return "새 액션"
            case .es:     return "Nueva acción"
            case .fr:     return "Nouvelle action"
            case .de:     return "Neue Aktion"
            case .pt:     return "Nova ação"
            }
        }
    }

    // MARK: - 命令模板设置

    enum Templates {
        static var addTemplate: String {
            switch L10n.current {
            case .zhHans: return "添加模板"
            case .zhHant: return "新增範本"
            case .en:     return "Add Template"
            case .ja:     return "テンプレートを追加"
            case .ko:     return "템플릿 추가"
            case .es:     return "Añadir plantilla"
            case .fr:     return "Ajouter un modèle"
            case .de:     return "Vorlage hinzufügen"
            case .pt:     return "Adicionar modelo"
            }
        }

        static var moveUp: String {
            switch L10n.current {
            case .zhHans: return "上移"
            case .zhHant: return "上移"
            case .en:     return "Move Up"
            case .ja:     return "上へ移動"
            case .ko:     return "위로 이동"
            case .es:     return "Mover arriba"
            case .fr:     return "Monter"
            case .de:     return "Nach oben"
            case .pt:     return "Mover acima"
            }
        }

        static var moveDown: String {
            switch L10n.current {
            case .zhHans: return "下移"
            case .zhHant: return "下移"
            case .en:     return "Move Down"
            case .ja:     return "下へ移動"
            case .ko:     return "아래로 이동"
            case .es:     return "Mover abajo"
            case .fr:     return "Descendre"
            case .de:     return "Nach unten"
            case .pt:     return "Mover abaixo"
            }
        }

        static var selectOrCreateTemplate: String {
            switch L10n.current {
            case .zhHans: return "选择或创建一个命令模板"
            case .zhHant: return "選擇或建立一個命令範本"
            case .en:     return "Select or create a template"
            case .ja:     return "テンプレートを選択または作成"
            case .ko:     return "템플릿을 선택하거나 만드세요"
            case .es:     return "Selecciona o crea una plantilla"
            case .fr:     return "Sélectionnez ou créez un modèle"
            case .de:     return "Vorlage auswählen oder erstellen"
            case .pt:     return "Selecione ou crie um modelo"
            }
        }

        static var newTemplate: String {
            switch L10n.current {
            case .zhHans: return "新模板"
            case .zhHant: return "新範本"
            case .en:     return "New Template"
            case .ja:     return "新しいテンプレート"
            case .ko:     return "새 템플릿"
            case .es:     return "Nueva plantilla"
            case .fr:     return "Nouveau modèle"
            case .de:     return "Neue Vorlage"
            case .pt:     return "Novo modelo"
            }
        }

        static var configuration: String {
            switch L10n.current {
            case .zhHans: return "配置"
            case .zhHant: return "設定"
            case .en:     return "Configuration"
            case .ja:     return "設定"
            case .ko:     return "설정"
            case .es:     return "Configuración"
            case .fr:     return "Configuration"
            case .de:     return "Konfiguration"
            case .pt:     return "Configuração"
            }
        }

        static var templateName: String {
            switch L10n.current {
            case .zhHans: return "模板名称"
            case .zhHant: return "範本名稱"
            case .en:     return "Template Name"
            case .ja:     return "テンプレート名"
            case .ko:     return "템플릿 이름"
            case .es:     return "Nombre de plantilla"
            case .fr:     return "Nom du modèle"
            case .de:     return "Vorlagenname"
            case .pt:     return "Nome do modelo"
            }
        }

        static var commandPattern: String {
            switch L10n.current {
            case .zhHans: return "命令模式"
            case .zhHant: return "命令模式"
            case .en:     return "Command Pattern"
            case .ja:     return "コマンドパターン"
            case .ko:     return "명령 패턴"
            case .es:     return "Patrón de comando"
            case .fr:     return "Modèle de commande"
            case .de:     return "Befehlsmuster"
            case .pt:     return "Padrão de comando"
            }
        }

        static var commandPlaceholder: String {
            switch L10n.current {
            case .zhHans: return "如 git checkout {branch}"
            case .zhHant: return "如 git checkout {branch}"
            case .en:     return "e.g. git checkout {branch}"
            case .ja:     return "例: git checkout {branch}"
            case .ko:     return "예: git checkout {branch}"
            case .es:     return "Ej. git checkout {branch}"
            case .fr:     return "Ex. git checkout {branch}"
            case .de:     return "z.B. git checkout {branch}"
            case .pt:     return "Ex. git checkout {branch}"
            }
        }

        static var preview: String {
            switch L10n.current {
            case .zhHans: return "预览"
            case .zhHant: return "預覽"
            case .en:     return "Preview"
            case .ja:     return "プレビュー"
            case .ko:     return "미리보기"
            case .es:     return "Vista previa"
            case .fr:     return "Aperçu"
            case .de:     return "Vorschau"
            case .pt:     return "Pré-visualização"
            }
        }

        static var awaitingInput: String {
            switch L10n.current {
            case .zhHans: return "(等待输入命令)"
            case .zhHant: return "（等待輸入命令）"
            case .en:     return "(awaiting command)"
            case .ja:     return "（コマンド入力待ち）"
            case .ko:     return "(명령 입력 대기 중)"
            case .es:     return "(esperando comando)"
            case .fr:     return "(en attente de commande)"
            case .de:     return "(warte auf Befehl)"
            case .pt:     return "(aguardando comando)"
            }
        }

        static var variableParameters: String {
            switch L10n.current {
            case .zhHans: return "变量参数"
            case .zhHant: return "變數參數"
            case .en:     return "Variables"
            case .ja:     return "変数パラメータ"
            case .ko:     return "변수 매개변수"
            case .es:     return "Variables"
            case .fr:     return "Variables"
            case .de:     return "Variablen"
            case .pt:     return "Variáveis"
            }
        }

        static var variableHint: String {
            switch L10n.current {
            case .zhHans: return "在命令中使用 {variable} 来创建动态参数"
            case .zhHant: return "在命令中使用 {variable} 來建立動態參數"
            case .en:     return "Use {variable} in the command to create dynamic parameters"
            case .ja:     return "コマンドで {variable} を使用して動的パラメータを作成"
            case .ko:     return "명령에서 {variable}을 사용하여 동적 매개변수를 만드세요"
            case .es:     return "Usa {variable} en el comando para crear parámetros dinámicos"
            case .fr:     return "Utilisez {variable} dans la commande pour créer des paramètres"
            case .de:     return "Verwenden Sie {variable} im Befehl für dynamische Parameter"
            case .pt:     return "Use {variable} no comando para criar parâmetros dinâmicos"
            }
        }

        static var placeholder: String {
            switch L10n.current {
            case .zhHans: return "占位符"
            case .zhHant: return "佔位符"
            case .en:     return "Placeholder"
            case .ja:     return "プレースホルダー"
            case .ko:     return "플레이스홀더"
            case .es:     return "Marcador"
            case .fr:     return "Espace réservé"
            case .de:     return "Platzhalter"
            case .pt:     return "Espaço reservado"
            }
        }

        static var defaultValue: String {
            switch L10n.current {
            case .zhHans: return "默认值"
            case .zhHant: return "預設值"
            case .en:     return "Default"
            case .ja:     return "デフォルト値"
            case .ko:     return "기본값"
            case .es:     return "Valor por defecto"
            case .fr:     return "Valeur par défaut"
            case .de:     return "Standardwert"
            case .pt:     return "Valor padrão"
            }
        }

        static var varNamePlaceholder: String {
            switch L10n.current {
            case .zhHans: return "名称"
            case .zhHant: return "名稱"
            case .en:     return "Name"
            case .ja:     return "名前"
            case .ko:     return "이름"
            case .es:     return "Nombre"
            case .fr:     return "Nom"
            case .de:     return "Name"
            case .pt:     return "Nome"
            }
        }

        static var optional: String {
            switch L10n.current {
            case .zhHans: return "可选"
            case .zhHant: return "可選"
            case .en:     return "Optional"
            case .ja:     return "任意"
            case .ko:     return "선택"
            case .es:     return "Opcional"
            case .fr:     return "Facultatif"
            case .de:     return "Optional"
            case .pt:     return "Opcional"
            }
        }
    }

    // MARK: - 快捷菜单

    enum Menu {
        static var openFolders: String {
            switch L10n.current {
            case .zhHans: return "打开文件夹"
            case .zhHant: return "開啟檔案夾"
            case .en:     return "Open Folder"
            case .ja:     return "フォルダを開く"
            case .ko:     return "폴더 열기"
            case .es:     return "Abrir carpeta"
            case .fr:     return "Ouvrir un dossier"
            case .de:     return "Ordner öffnen"
            case .pt:     return "Abrir pasta"
            }
        }

        static var selectCLI: String {
            switch L10n.current {
            case .zhHans: return "选择启动 CLI"
            case .zhHant: return "選擇啟動 CLI"
            case .en:     return "Launch CLI"
            case .ja:     return "CLI を起動"
            case .ko:     return "CLI 실행"
            case .es:     return "Iniciar CLI"
            case .fr:     return "Lancer CLI"
            case .de:     return "CLI starten"
            case .pt:     return "Iniciar CLI"
            }
        }

        static var commandTemplates: String {
            switch L10n.current {
            case .zhHans: return "命令模板"
            case .zhHant: return "命令範本"
            case .en:     return "Templates"
            case .ja:     return "テンプレート"
            case .ko:     return "명령 템플릿"
            case .es:     return "Plantillas"
            case .fr:     return "Modèles"
            case .de:     return "Vorlagen"
            case .pt:     return "Modelos"
            }
        }

        static var slashCommands: String {
            switch L10n.current {
            case .zhHans: return "交互式命令"
            case .zhHant: return "互動式命令"
            case .en:     return "Slash Commands"
            case .ja:     return "スラッシュコマンド"
            case .ko:     return "슬래시 명령"
            case .es:     return "Comandos rápidos"
            case .fr:     return "Commandes slash"
            case .de:     return "Slash-Befehle"
            case .pt:     return "Comandos rápidos"
            }
        }

        static var paste: String {
            switch L10n.current {
            case .zhHans: return "粘贴"
            case .zhHant: return "貼上"
            case .en:     return "Paste"
            case .ja:     return "ペースト"
            case .ko:     return "붙여넣기"
            case .es:     return "Pegar"
            case .fr:     return "Coller"
            case .de:     return "Einfügen"
            case .pt:     return "Colar"
            }
        }

        static var clearInput: String {
            switch L10n.current {
            case .zhHans: return "清空此行输入"
            case .zhHant: return "清空此行輸入"
            case .en:     return "Clear Line"
            case .ja:     return "行をクリア"
            case .ko:     return "줄 지우기"
            case .es:     return "Borrar línea"
            case .fr:     return "Effacer la saisie"
            case .de:     return "Eingabe löschen"
            case .pt:     return "Limpar entrada"
            }
        }

        static var disableTemporary: String {
            switch L10n.current {
            case .zhHans: return "关闭快捷键 1h"
            case .zhHant: return "關閉快捷鍵 1h"
            case .en:     return "Disable Shortcut 1h"
            case .ja:     return "ショートカット無効化 1h"
            case .ko:     return "단축키 1시간 비활성화"
            case .es:     return "Desactivar atajo 1h"
            case .fr:     return "Désactiver raccourci 1h"
            case .de:     return "Shortcut deaktivieren 1h"
            case .pt:     return "Desativar atalho 1h"
            }
        }

        static var disablePermanent: String {
            switch L10n.current {
            case .zhHans: return "关闭快捷键"
            case .zhHant: return "關閉快捷鍵"
            case .en:     return "Disable Shortcut"
            case .ja:     return "ショートカット無効化"
            case .ko:     return "단축키 비활성화"
            case .es:     return "Desactivar atajo"
            case .fr:     return "Désactiver raccourci"
            case .de:     return "Shortcut deaktivieren"
            case .pt:     return "Desativar atalho"
            }
        }

        static var addFolderEllipsis: String {
            switch L10n.current {
            case .zhHans: return "添加文件夹…"
            case .zhHant: return "新增檔案夾…"
            case .en:     return "Add Folder…"
            case .ja:     return "フォルダを追加…"
            case .ko:     return "폴더 추가…"
            case .es:     return "Añadir carpeta…"
            case .fr:     return "Ajouter un dossier…"
            case .de:     return "Ordner hinzufügen…"
            case .pt:     return "Adicionar pasta…"
            }
        }

        static var addCLIEllipsis: String {
            switch L10n.current {
            case .zhHans: return "添加 CLI…"
            case .zhHant: return "新增 CLI…"
            case .en:     return "Add CLI…"
            case .ja:     return "CLI を追加…"
            case .ko:     return "CLI 추가…"
            case .es:     return "Añadir CLI…"
            case .fr:     return "Ajouter CLI…"
            case .de:     return "CLI hinzufügen…"
            case .pt:     return "Adicionar CLI…"
            }
        }

        static var addActionEllipsis: String {
            switch L10n.current {
            case .zhHans: return "添加动作…"
            case .zhHant: return "新增動作…"
            case .en:     return "Add Action…"
            case .ja:     return "アクションを追加…"
            case .ko:     return "액션 추가…"
            case .es:     return "Añadir acción…"
            case .fr:     return "Ajouter une action…"
            case .de:     return "Aktion hinzufügen…"
            case .pt:     return "Adicionar ação…"
            }
        }

        static var hintPasteClipboard: String {
            switch L10n.current {
            case .zhHans: return "⏎ 粘贴剪贴板里的 文字 或 图片"
            case .zhHant: return "⏎ 貼上剪貼簿裡的文字或圖片"
            case .en:     return "⏎ Paste text or image from clipboard"
            case .ja:     return "⏎ クリップボードのテキストまたは画像を貼り付け"
            case .ko:     return "⏎ 클립보드의 텍스트 또는 이미지 붙여넣기"
            case .es:     return "⏎ Pegar texto o imagen del portapapeles"
            case .fr:     return "⏎ Coller le texte ou l'image du presse-papiers"
            case .de:     return "⏎ Text oder Bild aus Zwischenablage einfügen"
            case .pt:     return "⏎ Colar texto ou imagem da área de transferência"
            }
        }

        static var hintClearInput: String {
            switch L10n.current {
            case .zhHans: return "⏎ 清空此行输入"
            case .zhHant: return "⏎ 清空此行輸入"
            case .en:     return "⏎ Clear line"
            case .ja:     return "⏎ 行をクリア"
            case .ko:     return "⏎ 줄 지우기"
            case .es:     return "⏎ Borrar línea"
            case .fr:     return "⏎ Effacer la saisie"
            case .de:     return "⏎ Eingabe löschen"
            case .pt:     return "⏎ Limpar entrada"
            }
        }

        static var hintTemplateUnresolved: String {
            switch L10n.current {
            case .zhHans: return "⚠ 模板有未填充的变量，请先在配置中设置默认值"
            case .zhHant: return "⚠ 範本有未填充的變數，請先在設定中設置預設值"
            case .en:     return "⚠ Template has unfilled variables, please set defaults in settings"
            case .ja:     return "⚠ テンプレートに未設定の変数があります。設定でデフォルト値を設定してください"
            case .ko:     return "⚠ 템플릿에 미입력 변수가 있습니다. 설정에서 기본값을 지정하세요"
            case .es:     return "⚠ La plantilla tiene variables sin completar, configura los valores por defecto"
            case .fr:     return "⚠ Le modèle contient des variables non remplies, définissez les valeurs par défaut"
            case .de:     return "⚠ Vorlage hat unausgefüllte Variablen, bitte Standardwerte festlegen"
            case .pt:     return "⚠ O modelo tem variáveis não preenchidas, defina os valores padrão"
            }
        }

        static var hintDisableTemporary: String {
            switch L10n.current {
            case .zhHans: return "⏎ 暂停快捷键 1 小时"
            case .zhHant: return "⏎ 暫停快捷鍵 1 小時"
            case .en:     return "⏎ Pause shortcut for 1 hour"
            case .ja:     return "⏎ ショートカットを1時間一時停止"
            case .ko:     return "⏎ 단축키 1시간 일시정지"
            case .es:     return "⏎ Pausar atajo 1 hora"
            case .fr:     return "⏎ Suspendre le raccourci 1 heure"
            case .de:     return "⏎ Shortcut 1 Stunde pausieren"
            case .pt:     return "⏎ Pausar atalho por 1 hora"
            }
        }

        static var hintDisablePermanent: String {
            switch L10n.current {
            case .zhHans: return "⏎ 关闭快捷键"
            case .zhHant: return "⏎ 關閉快捷鍵"
            case .en:     return "⏎ Disable shortcut"
            case .ja:     return "⏎ ショートカットを無効化"
            case .ko:     return "⏎ 단축키 비활성화"
            case .es:     return "⏎ Desactivar atajo"
            case .fr:     return "⏎ Désactiver le raccourci"
            case .de:     return "⏎ Shortcut deaktivieren"
            case .pt:     return "⏎ Desativar atalho"
            }
        }

        static var navigationHint: String {
            switch L10n.current {
            case .zhHans: return "← ` 回退　↑↓ 选择　→ 下一步"
            case .zhHant: return "← ` 回退　↑↓ 選擇　→ 下一步"
            case .en:     return "← ` Back  ↑↓ Select  → Next"
            case .ja:     return "← ` 戻る　↑↓ 選択　→ 次へ"
            case .ko:     return "← ` 뒤로　↑↓ 선택　→ 다음"
            case .es:     return "← ` Atrás  ↑↓ Elegir  → Sig."
            case .fr:     return "← ` Retour  ↑↓ Choisir  → Suiv."
            case .de:     return "← ` Zurück  ↑↓ Wählen  → Weiter"
            case .pt:     return "← ` Voltar  ↑↓ Escolher  → Próx."
            }
        }
    }

    // MARK: - 权限提示

    enum Permission {
        static var accessibilityRequired: String {
            switch L10n.current {
            case .zhHans: return "需要辅助功能权限"
            case .zhHant: return "需要輔助功能權限"
            case .en:     return "Accessibility Permission Required"
            case .ja:     return "アクセシビリティ権限が必要です"
            case .ko:     return "손쉬운 사용 권한 필요"
            case .es:     return "Se requiere permiso de accesibilidad"
            case .fr:     return "Autorisation d'accessibilité requise"
            case .de:     return "Bedienungshilfen-Berechtigung erforderlich"
            case .pt:     return "Permissão de acessibilidade necessária"
            }
        }

        static var accessibilityMessage: String {
            switch L10n.current {
            case .zhHans: return "TermKit 需要辅助功能权限来检测修饰键长按。请在系统设置中授权后重新启用此功能。"
            case .zhHant: return "TermKit 需要輔助功能權限來偵測修飾鍵長按。請在系統設定中授權後重新啟用此功能。"
            case .en:     return "TermKit needs accessibility permission to detect modifier key holds. Please grant permission in System Settings."
            case .ja:     return "TermKit は修飾キーの長押しを検出するためにアクセシビリティ権限が必要です。システム設定で許可してください。"
            case .ko:     return "TermKit은 보조키 길게 누르기를 감지하기 위해 손쉬운 사용 권한이 필요합니다. 시스템 설정에서 권한을 부여해 주세요."
            case .es:     return "TermKit necesita permiso de accesibilidad para detectar la pulsación larga de teclas modificadoras. Concede el permiso en Ajustes del Sistema."
            case .fr:     return "TermKit a besoin de l'autorisation d'accessibilité pour détecter le maintien des touches de modification. Accordez l'autorisation dans les Réglages Système."
            case .de:     return "TermKit benötigt die Bedienungshilfen-Berechtigung, um das Gedrückthalten von Sondertasten zu erkennen. Bitte erteilen Sie die Berechtigung in den Systemeinstellungen."
            case .pt:     return "O TermKit precisa da permissão de acessibilidade para detectar o pressionamento longo de teclas modificadoras. Conceda a permissão nas Configurações do Sistema."
            }
        }

        static var openSystemSettings: String {
            switch L10n.current {
            case .zhHans: return "打开系统设置"
            case .zhHant: return "打開系統設定"
            case .en:     return "Open System Settings"
            case .ja:     return "システム設定を開く"
            case .ko:     return "시스템 설정 열기"
            case .es:     return "Abrir Ajustes del Sistema"
            case .fr:     return "Ouvrir les Réglages Système"
            case .de:     return "Systemeinstellungen öffnen"
            case .pt:     return "Abrir Configurações do Sistema"
            }
        }
    }

    // MARK: - 图标选择器

    enum IconPicker {
        static var clickToSelectIcon: String {
            switch L10n.current {
            case .zhHans: return "点击选择图标"
            case .zhHant: return "點擊選擇圖標"
            case .en:     return "Click to select icon"
            case .ja:     return "クリックしてアイコンを選択"
            case .ko:     return "클릭하여 아이콘 선택"
            case .es:     return "Haz clic para elegir icono"
            case .fr:     return "Cliquez pour choisir une icône"
            case .de:     return "Klicken um Symbol zu wählen"
            case .pt:     return "Clique para selecionar ícone"
            }
        }

        static var selectIcon: String {
            switch L10n.current {
            case .zhHans: return "选择图标"
            case .zhHant: return "選擇圖標"
            case .en:     return "Select Icon"
            case .ja:     return "アイコンを選択"
            case .ko:     return "아이콘 선택"
            case .es:     return "Elegir icono"
            case .fr:     return "Choisir une icône"
            case .de:     return "Symbol wählen"
            case .pt:     return "Selecionar ícone"
            }
        }

        static var sfSymbols: String {
            switch L10n.current {
            case .zhHans: return "SF 符号"
            case .zhHant: return "SF 符號"
            case .en:     return "SF Symbols"
            case .ja:     return "SF シンボル"
            case .ko:     return "SF 심볼"
            case .es:     return "Símbolos SF"
            case .fr:     return "Symboles SF"
            case .de:     return "SF-Symbole"
            case .pt:     return "Símbolos SF"
            }
        }

        static var brandIcons: String {
            switch L10n.current {
            case .zhHans: return "品牌图标"
            case .zhHant: return "品牌圖標"
            case .en:     return "Brand Icons"
            case .ja:     return "ブランドアイコン"
            case .ko:     return "브랜드 아이콘"
            case .es:     return "Iconos de marca"
            case .fr:     return "Icônes de marque"
            case .de:     return "Markensymbole"
            case .pt:     return "Ícones de marca"
            }
        }

        static var restoreDefault: String {
            switch L10n.current {
            case .zhHans: return "恢复默认图标"
            case .zhHant: return "恢復預設圖標"
            case .en:     return "Restore Default Icon"
            case .ja:     return "デフォルトアイコンに戻す"
            case .ko:     return "기본 아이콘 복원"
            case .es:     return "Restaurar icono predeterminado"
            case .fr:     return "Restaurer l'icône par défaut"
            case .de:     return "Standard-Symbol wiederherstellen"
            case .pt:     return "Restaurar ícone padrão"
            }
        }
    }

    // MARK: - 通用按钮 / 对话框

    enum Common {
        static var delete: String {
            switch L10n.current {
            case .zhHans: return "删除"
            case .zhHant: return "刪除"
            case .en:     return "Delete"
            case .ja:     return "削除"
            case .ko:     return "삭제"
            case .es:     return "Eliminar"
            case .fr:     return "Supprimer"
            case .de:     return "Löschen"
            case .pt:     return "Excluir"
            }
        }

        static var cancel: String {
            switch L10n.current {
            case .zhHans: return "取消"
            case .zhHant: return "取消"
            case .en:     return "Cancel"
            case .ja:     return "キャンセル"
            case .ko:     return "취소"
            case .es:     return "Cancelar"
            case .fr:     return "Annuler"
            case .de:     return "Abbrechen"
            case .pt:     return "Cancelar"
            }
        }

        static var save: String {
            switch L10n.current {
            case .zhHans: return "保存"
            case .zhHant: return "儲存"
            case .en:     return "Save"
            case .ja:     return "保存"
            case .ko:     return "저장"
            case .es:     return "Guardar"
            case .fr:     return "Enregistrer"
            case .de:     return "Speichern"
            case .pt:     return "Salvar"
            }
        }

        static var removeSelected: String {
            switch L10n.current {
            case .zhHans: return "移除选中"
            case .zhHant: return "移除已選"
            case .en:     return "Remove Selected"
            case .ja:     return "選択項目を削除"
            case .ko:     return "선택 항목 제거"
            case .es:     return "Eliminar selección"
            case .fr:     return "Supprimer la sélection"
            case .de:     return "Auswahl entfernen"
            case .pt:     return "Remover selecionado"
            }
        }

        static var choose: String {
            switch L10n.current {
            case .zhHans: return "选择…"
            case .zhHant: return "選擇…"
            case .en:     return "Choose…"
            case .ja:     return "選択…"
            case .ko:     return "선택…"
            case .es:     return "Elegir…"
            case .fr:     return "Choisir…"
            case .de:     return "Auswählen…"
            case .pt:     return "Escolher…"
            }
        }

        static var change: String {
            switch L10n.current {
            case .zhHans: return "修改…"
            case .zhHant: return "修改…"
            case .en:     return "Change…"
            case .ja:     return "変更…"
            case .ko:     return "변경…"
            case .es:     return "Cambiar…"
            case .fr:     return "Modifier…"
            case .de:     return "Ändern…"
            case .pt:     return "Alterar…"
            }
        }

        static func confirmDeleteNamed(_ name: String) -> String {
            switch L10n.current {
            case .zhHans: return "确定要删除「\(name)」吗？"
            case .zhHant: return "確定要刪除「\(name)」嗎？"
            case .en:     return "Delete \"\(name)\"?"
            case .ja:     return "「\(name)」を削除しますか？"
            case .ko:     return "\"\(name)\"을(를) 삭제하시겠습니까?"
            case .es:     return "¿Eliminar \"\(name)\"?"
            case .fr:     return "Supprimer « \(name) » ?"
            case .de:     return "\u{201E}\(name)\u{201C} löschen?"
            case .pt:     return "Excluir \"\(name)\"?"
            }
        }

        static var confirmDelete: String {
            switch L10n.current {
            case .zhHans: return "确定要删除吗？"
            case .zhHant: return "確定要刪除嗎？"
            case .en:     return "Are you sure you want to delete?"
            case .ja:     return "削除してもよろしいですか？"
            case .ko:     return "삭제하시겠습니까?"
            case .es:     return "¿Estás seguro de que quieres eliminar?"
            case .fr:     return "Voulez-vous vraiment supprimer ?"
            case .de:     return "Möchten Sie wirklich löschen?"
            case .pt:     return "Tem certeza de que deseja excluir?"
            }
        }
    }

    // MARK: - 菜单弹窗（CmdHoldMenuWindowController）

    // MARK: - Slash Commands 菜单项

    enum SlashCommand {
        static var clear: String {
            switch L10n.current {
            case .zhHans: return "清空对话历史"
            case .zhHant: return "清空對話歷史"
            case .en:     return "Clear History"
            case .ja:     return "履歴をクリア"
            case .ko:     return "대화 기록 삭제"
            case .es:     return "Borrar historial"
            case .fr:     return "Effacer l'historique"
            case .de:     return "Verlauf löschen"
            case .pt:     return "Limpar histórico"
            }
        }
        static var compact: String {
            switch L10n.current {
            case .zhHans: return "压缩对话"
            case .zhHant: return "壓縮對話"
            case .en:     return "Compact Chat"
            case .ja:     return "チャットを圧縮"
            case .ko:     return "대화 압축"
            case .es:     return "Compactar chat"
            case .fr:     return "Compacter la conversation"
            case .de:     return "Chat komprimieren"
            case .pt:     return "Compactar conversa"
            }
        }
        static var model: String {
            switch L10n.current {
            case .zhHans: return "切换模型"
            case .zhHant: return "切換模型"
            case .en:     return "Switch Model"
            case .ja:     return "モデルを切替"
            case .ko:     return "모델 전환"
            case .es:     return "Cambiar modelo"
            case .fr:     return "Changer de modèle"
            case .de:     return "Modell wechseln"
            case .pt:     return "Trocar modelo"
            }
        }
        static var config: String {
            switch L10n.current {
            case .zhHans: return "查看配置"
            case .zhHant: return "查看設定"
            case .en:     return "View Config"
            case .ja:     return "設定を表示"
            case .ko:     return "설정 보기"
            case .es:     return "Ver configuración"
            case .fr:     return "Voir la configuration"
            case .de:     return "Konfiguration anzeigen"
            case .pt:     return "Ver configuração"
            }
        }
        static var cost: String {
            switch L10n.current {
            case .zhHans: return "查看用量和费用"
            case .zhHant: return "查看用量和費用"
            case .en:     return "View Usage & Cost"
            case .ja:     return "使用量とコストを表示"
            case .ko:     return "사용량 및 비용 보기"
            case .es:     return "Ver uso y costes"
            case .fr:     return "Voir utilisation et coûts"
            case .de:     return "Nutzung & Kosten anzeigen"
            case .pt:     return "Ver uso e custos"
            }
        }
        static var memory: String {
            switch L10n.current {
            case .zhHans: return "编辑 CLAUDE.md"
            case .zhHant: return "編輯 CLAUDE.md"
            case .en:     return "Edit CLAUDE.md"
            case .ja:     return "CLAUDE.md を編集"
            case .ko:     return "CLAUDE.md 편집"
            case .es:     return "Editar CLAUDE.md"
            case .fr:     return "Modifier CLAUDE.md"
            case .de:     return "CLAUDE.md bearbeiten"
            case .pt:     return "Editar CLAUDE.md"
            }
        }
        static var review: String {
            switch L10n.current {
            case .zhHans: return "代码审查"
            case .zhHant: return "程式碼審查"
            case .en:     return "Code Review"
            case .ja:     return "コードレビュー"
            case .ko:     return "코드 리뷰"
            case .es:     return "Revisión de código"
            case .fr:     return "Revue de code"
            case .de:     return "Code-Review"
            case .pt:     return "Revisão de código"
            }
        }
        static var permissions: String {
            switch L10n.current {
            case .zhHans: return "管理工具权限"
            case .zhHant: return "管理工具權限"
            case .en:     return "Manage Permissions"
            case .ja:     return "ツール権限を管理"
            case .ko:     return "도구 권한 관리"
            case .es:     return "Gestionar permisos"
            case .fr:     return "Gérer les autorisations"
            case .de:     return "Berechtigungen verwalten"
            case .pt:     return "Gerenciar permissões"
            }
        }
        static var vim: String {
            switch L10n.current {
            case .zhHans: return "切换 vim 模式"
            case .zhHant: return "切換 vim 模式"
            case .en:     return "Toggle Vim Mode"
            case .ja:     return "vim モードを切替"
            case .ko:     return "vim 모드 전환"
            case .es:     return "Alternar modo vim"
            case .fr:     return "Basculer le mode vim"
            case .de:     return "Vim-Modus umschalten"
            case .pt:     return "Alternar modo vim"
            }
        }
        static var help: String {
            switch L10n.current {
            case .zhHans: return "帮助"
            case .zhHant: return "幫助"
            case .en:     return "Help"
            case .ja:     return "ヘルプ"
            case .ko:     return "도움말"
            case .es:     return "Ayuda"
            case .fr:     return "Aide"
            case .de:     return "Hilfe"
            case .pt:     return "Ajuda"
            }
        }
    }

    // MARK: - 默认 CLI 动作标题

    enum DefaultCLI {
        static var newChat: String {
            switch L10n.current {
            case .zhHans: return "新建对话"
            case .zhHant: return "新建對話"
            case .en:     return "New Chat"
            case .ja:     return "新規チャット"
            case .ko:     return "새 대화"
            case .es:     return "Nueva conversación"
            case .fr:     return "Nouvelle conversation"
            case .de:     return "Neuer Chat"
            case .pt:     return "Nova conversa"
            }
        }
        static var continueLast: String {
            switch L10n.current {
            case .zhHans: return "继续上次对话"
            case .zhHant: return "繼續上次對話"
            case .en:     return "Continue Last"
            case .ja:     return "前回の続き"
            case .ko:     return "이전 대화 계속"
            case .es:     return "Continuar última"
            case .fr:     return "Reprendre la dernière"
            case .de:     return "Letzte fortsetzen"
            case .pt:     return "Continuar última"
            }
        }
        static var resumeHistory: String {
            switch L10n.current {
            case .zhHans: return "恢复历史对话"
            case .zhHant: return "恢復歷史對話"
            case .en:     return "Resume History"
            case .ja:     return "履歴から再開"
            case .ko:     return "기록 복원"
            case .es:     return "Reanudar historial"
            case .fr:     return "Reprendre l'historique"
            case .de:     return "Verlauf fortsetzen"
            case .pt:     return "Retomar histórico"
            }
        }
        static var showVersion: String {
            switch L10n.current {
            case .zhHans: return "显示版本"
            case .zhHant: return "顯示版本"
            case .en:     return "Show Version"
            case .ja:     return "バージョン表示"
            case .ko:     return "버전 표시"
            case .es:     return "Mostrar versión"
            case .fr:     return "Afficher la version"
            case .de:     return "Version anzeigen"
            case .pt:     return "Mostrar versão"
            }
        }
        static var showHelp: String {
            switch L10n.current {
            case .zhHans: return "显示帮助"
            case .zhHant: return "顯示幫助"
            case .en:     return "Show Help"
            case .ja:     return "ヘルプを表示"
            case .ko:     return "도움말 표시"
            case .es:     return "Mostrar ayuda"
            case .fr:     return "Afficher l'aide"
            case .de:     return "Hilfe anzeigen"
            case .pt:     return "Mostrar ajuda"
            }
        }
        static var listMCPServers: String {
            switch L10n.current {
            case .zhHans: return "列出 MCP 服务器"
            case .zhHant: return "列出 MCP 伺服器"
            case .en:     return "List MCP Servers"
            case .ja:     return "MCP サーバー一覧"
            case .ko:     return "MCP 서버 목록"
            case .es:     return "Listar servidores MCP"
            case .fr:     return "Lister les serveurs MCP"
            case .de:     return "MCP-Server auflisten"
            case .pt:     return "Listar servidores MCP"
            }
        }
        static var checkHealth: String {
            switch L10n.current {
            case .zhHans: return "检查安装健康状态"
            case .zhHant: return "檢查安裝健康狀態"
            case .en:     return "Check Health"
            case .ja:     return "インストール状態を確認"
            case .ko:     return "설치 상태 확인"
            case .es:     return "Comprobar estado"
            case .fr:     return "Vérifier l'état"
            case .de:     return "Installation prüfen"
            case .pt:     return "Verificar integridade"
            }
        }
        static var checkUpdate: String {
            switch L10n.current {
            case .zhHans: return "检查并更新"
            case .zhHant: return "檢查並更新"
            case .en:     return "Check for Updates"
            case .ja:     return "アップデートを確認"
            case .ko:     return "업데이트 확인"
            case .es:     return "Buscar actualizaciones"
            case .fr:     return "Vérifier les mises à jour"
            case .de:     return "Nach Updates suchen"
            case .pt:     return "Verificar atualizações"
            }
        }
        static var viewConfig: String {
            switch L10n.current {
            case .zhHans: return "查看/修改配置"
            case .zhHant: return "查看/修改設定"
            case .en:     return "View/Edit Config"
            case .ja:     return "設定を表示/編集"
            case .ko:     return "설정 보기/편집"
            case .es:     return "Ver/editar configuración"
            case .fr:     return "Voir/modifier la configuration"
            case .de:     return "Konfiguration anzeigen/bearbeiten"
            case .pt:     return "Ver/editar configuração"
            }
        }
        static var launch: String {
            switch L10n.current {
            case .zhHans: return "启动"
            case .zhHant: return "啟動"
            case .en:     return "Launch"
            case .ja:     return "起動"
            case .ko:     return "실행"
            case .es:     return "Iniciar"
            case .fr:     return "Lancer"
            case .de:     return "Starten"
            case .pt:     return "Iniciar"
            }
        }
        static var restoreChatHistory: String {
            switch L10n.current {
            case .zhHans: return "恢复聊天记录"
            case .zhHant: return "恢復聊天記錄"
            case .en:     return "Restore Chat History"
            case .ja:     return "チャット履歴を復元"
            case .ko:     return "채팅 기록 복원"
            case .es:     return "Restaurar historial"
            case .fr:     return "Restaurer l'historique"
            case .de:     return "Chatverlauf wiederherstellen"
            case .pt:     return "Restaurar histórico"
            }
        }
    }

    // MARK: - 菜单弹窗对话框

    enum MenuDialog {
        static var chooseFolderTitle: String {
            switch L10n.current {
            case .zhHans: return "选择文件夹"
            case .zhHant: return "選擇檔案夾"
            case .en:     return "Choose Folder"
            case .ja:     return "フォルダを選択"
            case .ko:     return "폴더 선택"
            case .es:     return "Elegir carpeta"
            case .fr:     return "Choisir un dossier"
            case .de:     return "Ordner wählen"
            case .pt:     return "Escolher pasta"
            }
        }

        static var addCLITitle: String {
            switch L10n.current {
            case .zhHans: return "添加 CLI"
            case .zhHant: return "新增 CLI"
            case .en:     return "Add CLI"
            case .ja:     return "CLI を追加"
            case .ko:     return "CLI 추가"
            case .es:     return "Añadir CLI"
            case .fr:     return "Ajouter CLI"
            case .de:     return "CLI hinzufügen"
            case .pt:     return "Adicionar CLI"
            }
        }

        static var addCLIMessage: String {
            switch L10n.current {
            case .zhHans: return "输入 CLI 名称（动作可在设置界面中添加）"
            case .zhHant: return "輸入 CLI 名稱（動作可在設定介面中新增）"
            case .en:     return "Enter CLI name (actions can be added in Settings)"
            case .ja:     return "CLI 名を入力してください（アクションは設定画面で追加できます）"
            case .ko:     return "CLI 이름을 입력하세요 (액션은 설정에서 추가 가능)"
            case .es:     return "Introduce el nombre del CLI (las acciones se pueden añadir en Ajustes)"
            case .fr:     return "Saisissez le nom du CLI (les actions peuvent être ajoutées dans les Réglages)"
            case .de:     return "CLI-Name eingeben (Aktionen können in den Einstellungen hinzugefügt werden)"
            case .pt:     return "Digite o nome do CLI (ações podem ser adicionadas nas Configurações)"
            }
        }

        static var addActionTitle: String {
            switch L10n.current {
            case .zhHans: return "添加动作"
            case .zhHant: return "新增動作"
            case .en:     return "Add Action"
            case .ja:     return "アクションを追加"
            case .ko:     return "액션 추가"
            case .es:     return "Añadir acción"
            case .fr:     return "Ajouter une action"
            case .de:     return "Aktion hinzufügen"
            case .pt:     return "Adicionar ação"
            }
        }

        static var addActionMessage: String {
            switch L10n.current {
            case .zhHans: return "输入动作名称与命令模板"
            case .zhHant: return "輸入動作名稱與命令範本"
            case .en:     return "Enter action name and command"
            case .ja:     return "アクション名とコマンドを入力してください"
            case .ko:     return "액션 이름과 명령을 입력하세요"
            case .es:     return "Introduce el nombre de la acción y el comando"
            case .fr:     return "Saisissez le nom de l'action et la commande"
            case .de:     return "Aktionsname und Befehl eingeben"
            case .pt:     return "Digite o nome da ação e o comando"
            }
        }

        static var placeholderName: String {
            switch L10n.current {
            case .zhHans: return "名称（必填）"
            case .zhHant: return "名稱（必填）"
            case .en:     return "Name (required)"
            case .ja:     return "名前（必須）"
            case .ko:     return "이름 (필수)"
            case .es:     return "Nombre (obligatorio)"
            case .fr:     return "Nom (requis)"
            case .de:     return "Name (erforderlich)"
            case .pt:     return "Nome (obrigatório)"
            }
        }

        static var placeholderTitle: String {
            switch L10n.current {
            case .zhHans: return "标题（必填）"
            case .zhHant: return "標題（必填）"
            case .en:     return "Title (required)"
            case .ja:     return "タイトル（必須）"
            case .ko:     return "제목 (필수)"
            case .es:     return "Título (obligatorio)"
            case .fr:     return "Titre (requis)"
            case .de:     return "Titel (erforderlich)"
            case .pt:     return "Título (obrigatório)"
            }
        }

        static var placeholderCommand: String {
            switch L10n.current {
            case .zhHans: return "命令（必填）"
            case .zhHant: return "命令（必填）"
            case .en:     return "Command (required)"
            case .ja:     return "コマンド（必須）"
            case .ko:     return "명령 (필수)"
            case .es:     return "Comando (obligatorio)"
            case .fr:     return "Commande (requis)"
            case .de:     return "Befehl (erforderlich)"
            case .pt:     return "Comando (obrigatório)"
            }
        }
    }
}
