import SwiftUI

struct LanguagePickerView: View {
    enum Mode {
        case appLanguage
        case streamLanguage
    }
    
    let mode: Mode
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.akislarDarkBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 8) {
                    switch mode {
                    case .appLanguage:
                        ForEach(AppLanguage.allCases) { language in
                            languageRow(
                                flag: language.flag,
                                name: language.displayName,
                                isSelected: settingsManager.appLanguage == language
                            ) {
                                settingsManager.appLanguage = language
                                hapticFeedback()
                            }
                        }
                    case .streamLanguage:
                        ForEach(StreamLanguage.allCases) { language in
                            languageRow(
                                flag: language.flag,
                                name: language.displayName,
                                isSelected: settingsManager.streamLanguage == language
                            ) {
                                settingsManager.streamLanguage = language
                                hapticFeedback()
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(
            mode == .appLanguage
            ? settingsManager.localizedString("app_language")
            : settingsManager.localizedString("stream_language")
        )
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func languageRow(
        flag: String,
        name: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(flag)
                    .font(.title)
                
                Text(name)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.akislarGold)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                isSelected
                ? Color.akislarGold.opacity(0.12)
                : Color.akislarCardBg
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.akislarGold.opacity(0.3) : Color.white.opacity(0.05),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func hapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
