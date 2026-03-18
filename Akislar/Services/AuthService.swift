import SwiftUI
import Combine
import GoogleSignIn

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
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            self.errorMessage = "Unable to present Google Sign-In"
            self.state = .signedOut
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            guard let self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.state = .signedOut
                return
            }
            
            guard let user = signInResult?.user, let profile = user.profile else {
                self.errorMessage = "Failed to get user profile"
                self.state = .signedOut
                return
            }
            
            let appUser = AppUser(
                id: user.userID ?? UUID().uuidString,
                name: profile.name,
                email: profile.email,
                avatarURL: profile.imageURL(withDimension: 100)?.absoluteString,
                preferredStreamLanguage: StreamLanguage.english.code,
                preferredAppLanguage: AppLanguage.english.code,
                selectedAppIcon: "AppIcon"
            )
            
            self.saveUser(appUser)
            self.state = .signedIn(appUser)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
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
        
        // If Google was used previously, try restoring it
        GIDSignIn.sharedInstance.restorePreviousSignIn { googleUser, error in
            // Handle silent token refresh if needed
        }
        
        state = .signedIn(user)
    }
}
