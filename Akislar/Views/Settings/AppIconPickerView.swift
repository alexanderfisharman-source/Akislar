import SwiftUI

struct AppIconPickerView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        ZStack {
            Color.akislarDarkBg.ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ],
                    spacing: 20
                ) {
                    ForEach(settingsManager.availableIcons) { icon in
                        Button {
                            settingsManager.changeAppIcon(to: icon.id)
                            hapticFeedback()
                        } label: {
                            VStack(spacing: 12) {
                                // Icon preview
                                ZStack {
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(iconGradient(for: icon.id))
                                        .frame(width: 90, height: 90)
                                        .shadow(
                                            color: iconShadowColor(for: icon.id).opacity(0.4),
                                            radius: 10,
                                            y: 4
                                        )
                                    
                                    // Icon content
                                    VStack(spacing: 4) {
                                        Image(systemName: "play.tv.fill")
                                            .font(.system(size: 28))
                                        Text("A")
                                            .font(.system(size: 14, weight: .black, design: .serif))
                                    }
                                    .foregroundColor(iconForeground(for: icon.id))
                                    
                                    // Selected indicator
                                    if settingsManager.selectedAppIcon == icon.id {
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.akislarGold, lineWidth: 3)
                                            .frame(width: 90, height: 90)
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.akislarGold)
                                            .background(Circle().fill(Color.black))
                                            .offset(x: 35, y: -35)
                                    }
                                }
                                
                                VStack(spacing: 2) {
                                    Text(icon.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(icon.description)
                                        .font(.caption2)
                                        .foregroundColor(.akislarSubtle)
                                }
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                settingsManager.selectedAppIcon == icon.id
                                ? Color.akislarGold.opacity(0.08)
                                : Color.akislarCardBg
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        settingsManager.selectedAppIcon == icon.id
                                        ? Color.akislarGold.opacity(0.3)
                                        : Color.white.opacity(0.05),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(settingsManager.localizedString("app_icon"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Icon Themes
    
    private func iconGradient(for id: String) -> LinearGradient {
        switch id {
        case "AppIcon":
            return LinearGradient(
                colors: [Color(red: 0.15, green: 0.15, blue: 0.25), Color(red: 0.08, green: 0.08, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "AppIcon-Dark":
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.08), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "AppIcon-Gold":
            return LinearGradient(
                colors: [Color.akislarGold, Color.akislarAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "AppIcon-Ottoman":
            return LinearGradient(
                colors: [Color(red: 0.55, green: 0.12, blue: 0.12), Color(red: 0.30, green: 0.05, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private func iconForeground(for id: String) -> Color {
        switch id {
        case "AppIcon-Gold": return .black
        default: return .akislarGold
        }
    }
    
    private func iconShadowColor(for id: String) -> Color {
        switch id {
        case "AppIcon-Gold": return .akislarGold
        case "AppIcon-Ottoman": return .red
        default: return .black
        }
    }
    
    private func hapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
