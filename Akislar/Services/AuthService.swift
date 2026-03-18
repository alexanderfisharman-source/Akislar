import SwiftUI
import Combine

@MainActor
class AuthService: ObservableObject {
    enum AuthState {
        case signedOut
        case loading
        case signedIn(AppUser)
    }
    
    @Published var state: AuthState = .signedOut
    @Published var errorMessage: String?
    
    var currentUser: AppUser? {
        if case .signedIn(let user) = state { return user }
        return nil
    }
    
    var isSignedIn: Bool {
        if case .signedIn = state { return true }
        return false
    }
    
    init() {
        loadSavedUser()
    }
    
    // MARK: - Email/Password Auth
    
    func signInWithEmail(_ email: String, password: String) {
        state = .loading
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            
            // For demo: accept any valid-looking email
            guard email.contains("@"), !password.isEmpty, password.count >= 6 else {
                self.errorMessage = "Invalid email or password (min 6 characters)"
                self.state = .signedOut
                return
            }
            
            let user = AppUser(
                id: UUID().uuidString,
                name: email.components(separatedBy: "@").first ?? "User",
                email: email,
                avatarURL: nil,
                preferredStreamLanguage: StreamLanguage.english.code,
                preferredAppLanguage: AppLanguage.english.code,
                selectedAppIcon: "AppIcon"
            )
            
            self.saveUser(user)
            self.state = .signedIn(user)
        }
    }
    
    func signUpWithEmail(_ email: String, password: String, name: String) {
        state = .loading
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            
            guard email.contains("@"), password.count >= 6, !name.isEmpty else {
                self.errorMessage = "Please fill all fields correctly"
                self.state = .signedOut
                return
            }
            
            let user = AppUser(
                id: UUID().uuidString,
                name: name,
                email: email,
                avatarURL: nil,
                preferredStreamLanguage: StreamLanguage.english.code,
                preferredAppLanguage: AppLanguage.english.code,
                selectedAppIcon: "AppIcon"
            )
            
            self.saveUser(user)
            self.state = .signedIn(user)
        }
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() {
        state = .loading
        errorMessage = nil
        
        // Google Sign-In integration placeholder
        // In production, use: GIDSignIn.sharedInstance.signIn(withPresenting:)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            
            let user = AppUser(
                id: UUID().uuidString,
                name: "Google User",
                email: "user@gmail.com",
                avatarURL: nil,
                preferredStreamLanguage: StreamLanguage.english.code,
                preferredAppLanguage: AppLanguage.english.code,
                selectedAppIcon: "AppIcon"
            )
            
            self.saveUser(user)
            self.state = .signedIn(user)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "saved_user")
        state = .signedOut
    }
    
    // MARK: - Persistence
    
    private func saveUser(_ user: AppUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "saved_user")
        }
    }
    
    private func loadSavedUser() {
        guard let data = UserDefaults.standard.data(forKey: "saved_user"),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return
        }
        state = .signedIn(user)
    }
}
