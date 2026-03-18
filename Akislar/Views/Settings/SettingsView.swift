import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Account card
                    accountSection
                    
                    // App Language
                    settingsSection(
                        title: settingsManager.localizedString("app_language"),
                        icon: "globe",
                        iconColor: .blue
                    ) {
                        NavigationLink {
                            LanguagePickerView(mode: .appLanguage)
                        } label: {
                            HStack {
                                Text("\(settingsManager.appLanguage.flag) \(settingsManager.appLanguage.displayName)")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.akislarSubtle)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // Stream Language
                    settingsSection(
                        title: settingsManager.localizedString("stream_language"),
                        icon: "play.tv",
                        iconColor: .akislarGold
                    ) {
                        NavigationLink {
                            LanguagePickerView(mode: .streamLanguage)
                        } label: {
                            HStack {
                                Text("\(settingsManager.streamLanguage.flag) \(settingsManager.streamLanguage.displayName)")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.akislarSubtle)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // App Icon
                    settingsSection(
                        title: settingsManager.localizedString("app_icon"),
                        icon: "app.badge",
                        iconColor: .purple
                    ) {
                        NavigationLink {
                            AppIconPickerView()
                        } label: {
                            HStack {
                                Text(settingsManager.availableIcons.first { $0.id == settingsManager.selectedAppIcon }?.name ?? "Default")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.akislarSubtle)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // About
                    settingsSection(
                        title: settingsManager.localizedString("about"),
                        icon: "info.circle",
                        iconColor: .akislarSubtle
                    ) {
                        HStack {
                            Text(settingsManager.localizedString("version"))
                                .foregroundColor(.akislarSubtle)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.akislarSubtle)
                        }
                    }
                    
                    // Sign out
                    if authService.isSignedIn {
                        Button {
                            authService.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text(settingsManager.localizedString("sign_out"))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.akislarDarkBg)
            .navigationTitle(settingsManager.localizedString("settings"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        VStack(spacing: 0) {
            if authService.isSignedIn, let user = authService.currentUser {
                // Signed in card
                HStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.akislarGold, Color.akislarAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Text(String(user.name.prefix(1)).uppercased())
                            .font(.title2.weight(.bold))
                            .foregroundColor(.black)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.akislarSubtle)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.akislarGold)
                        .font(.title3)
                }
                .padding(20)
                .background(Color.akislarCardBg)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.akislarGold.opacity(0.2), lineWidth: 1)
                )
            } else {
                // Sign in prompt
                VStack(spacing: 16) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.akislarGold, Color.akislarAccent],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text(settingsManager.localizedString("guest"))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button {
                        showLogin = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text(settingsManager.localizedString("sign_in"))
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.akislarGold, Color.akislarAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
                .padding(20)
                .background(Color.akislarCardBg)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Settings Section
    
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.akislarSubtle)
            }
            .padding(.horizontal, 20)
            
            VStack {
                content()
            }
            .padding(16)
            .background(Color.akislarCardBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}
