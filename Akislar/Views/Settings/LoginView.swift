import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.akislarDarkBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo
                        VStack(spacing: 12) {
                            Image(systemName: "play.tv.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.akislarGold, Color.akislarAccent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("AKISLAR")
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.akislarGold, Color.akislarAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.top, 40)
                        
                        // Google Sign In
                        Button {
                            authService.signInWithGoogle()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                Text(settingsManager.localizedString("login_google"))
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.akislarCardBg)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                            Text(settingsManager.localizedString("or"))
                                .font(.caption)
                                .foregroundColor(.akislarSubtle)
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 30)
                        
                        // Email form
                        VStack(spacing: 16) {
                            if isSignUp {
                                customTextField(
                                    icon: "person",
                                    placeholder: settingsManager.localizedString("name"),
                                    text: $name
                                )
                            }
                            
                            customTextField(
                                icon: "envelope",
                                placeholder: settingsManager.localizedString("email"),
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            customSecureField(
                                icon: "lock",
                                placeholder: settingsManager.localizedString("password"),
                                text: $password
                            )
                            
                            // Error message
                            if let error = authService.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .padding(.horizontal, 4)
                            }
                            
                            // Submit button
                            Button {
                                if isSignUp {
                                    authService.signUpWithEmail(email, password: password, name: name)
                                } else {
                                    authService.signInWithEmail(email, password: password)
                                }
                            } label: {
                                Group {
                                    if case .loading = authService.state {
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Text(isSignUp
                                             ? settingsManager.localizedString("sign_up")
                                             : settingsManager.localizedString("sign_in"))
                                            .font(.headline)
                                    }
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.akislarGold, Color.akislarAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: Color.akislarGold.opacity(0.3), radius: 10, y: 4)
                            }
                            
                            // Toggle sign in / sign up
                            Button {
                                withAnimation { isSignUp.toggle() }
                            } label: {
                                Text(isSignUp
                                     ? "\(settingsManager.localizedString("sign_in")) →"
                                     : "\(settingsManager.localizedString("sign_up")) →")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.akislarGold)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .onChange(of: authService.isSignedIn) { isSignedIn in
                if isSignedIn { dismiss() }
            }
        }
    }
    
    // MARK: - Custom Text Field
    
    private func customTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.akislarSubtle)
                .frame(width: 20)
            
            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(16)
        .background(Color.akislarCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func customSecureField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.akislarSubtle)
                .frame(width: 20)
            
            SecureField(placeholder, text: text)
                .foregroundColor(.white)
        }
        .padding(16)
        .background(Color.akislarCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
