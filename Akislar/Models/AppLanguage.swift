import Foundation

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case english
    case turkish
    case arabic
    case urdu
    case french
    case german
    case spanish
    
    var id: String { rawValue }
    
    var code: String {
        switch self {
        case .english: return "en"
        case .turkish: return "tr"
        case .arabic: return "ar"
        case .urdu: return "ur"
        case .french: return "fr"
        case .german: return "de"
        case .spanish: return "es"
        }
    }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .arabic: return "العربية"
        case .urdu: return "اردو"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .spanish: return "Español"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        case .arabic: return "🇸🇦"
        case .urdu: return "🇵🇰"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .spanish: return "🇪🇸"
        }
    }
}
