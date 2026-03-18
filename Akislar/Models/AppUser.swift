import Foundation

struct AppUser: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var avatarURL: String?
    var preferredStreamLanguage: String
    var preferredAppLanguage: String
    var selectedAppIcon: String
    
    var avatarImage: URL? {
        guard let avatarURL else { return nil }
        return URL(string: avatarURL)
    }
    
    static var guest: AppUser {
        AppUser(
            id: "guest",
            name: "Guest",
            email: "",
            avatarURL: nil,
            preferredStreamLanguage: StreamLanguage.english.code,
            preferredAppLanguage: AppLanguage.english.code,
            selectedAppIcon: "AppIcon"
        )
    }
}
