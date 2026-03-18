import Foundation

enum StreamLanguage: String, CaseIterable, Codable, Identifiable {
    case turkish
    case english
    case arabic
    case urdu
    case french
    case german
    case spanish
    case indonesian
    
    var id: String { rawValue }
    
    var code: String {
        switch self {
        case .turkish: return "tr"
        case .english: return "en"
        case .arabic: return "ar"
        case .urdu: return "ur"
        case .french: return "fr"
        case .german: return "de"
        case .spanish: return "es"
        case .indonesian: return "id"
        }
    }
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        case .arabic: return "العربية"
        case .urdu: return "اردو"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .spanish: return "Español"
        case .indonesian: return "Bahasa Indonesia"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇬🇧"
        case .arabic: return "🇸🇦"
        case .urdu: return "🇵🇰"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .spanish: return "🇪🇸"
        case .indonesian: return "🇮🇩"
        }
    }
}
