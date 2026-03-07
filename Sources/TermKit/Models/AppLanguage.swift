import Foundation

/// 应用支持的界面语言
enum AppLanguage: String, Codable, CaseIterable {
    case zhHans  // 简体中文
    case zhHant  // 繁體中文
    case en      // English
    case ja      // 日本語
    case ko      // 한국어
    case es      // Español
    case fr      // Français
    case de      // Deutsch
    case pt      // Português

    /// 用各自语言显示的名称（供 Picker 使用）
    var displayName: String {
        switch self {
        case .zhHans: return "简体中文"
        case .zhHant: return "繁體中文"
        case .en:     return "English"
        case .ja:     return "日本語"
        case .ko:     return "한국어"
        case .es:     return "Español"
        case .fr:     return "Français"
        case .de:     return "Deutsch"
        case .pt:     return "Português"
        }
    }
}
