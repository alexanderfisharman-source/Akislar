import SwiftUI
import AVKit

struct PlayerView: View {
    let episode: Episode
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(episode: Episode) {
        self.episode = episode
        _viewModel = StateObject(wrappedValue: PlayerViewModel(
            episode: episode,
            preferredLanguage: .english
        ))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Video layer
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                        viewModel.isPlaying = true
                    }
            }
            
            // Controls overlay
            if viewModel.showControls {
                controlsOverlay
            }
            
            // Language picker sheet
            if viewModel.showLanguagePicker {
                languagePickerOverlay
            }
        }
        .onTapGesture {
            if !viewModel.showLanguagePicker {
                viewModel.toggleControls()
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
        .statusBarHidden(true)
    }
    
    // MARK: - Controls Overlay
    
    private var controlsOverlay: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(episode.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("E\(episode.episodeNumber) • S\(episode.season)")
                            .font(.caption)
                            .foregroundColor(.akislarSubtle)
                    }
                    
                    Spacer()
                    
                    // Language selector
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.showLanguagePicker = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(viewModel.selectedStreamLanguage.flag)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Center playback controls
                HStack(spacing: 50) {
                    Button {
                        viewModel.skipBackward()
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        viewModel.togglePlayPause()
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        viewModel.skipForward()
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Bottom progress bar
                VStack(spacing: 8) {
                    // Progress slider
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Track
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 4)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.akislarGold)
                                .frame(width: max(0, geo.size.width * viewModel.progress), height: 4)
                            
                            // Thumb
                            Circle()
                                .fill(Color.akislarGold)
                                .frame(width: 14, height: 14)
                                .offset(x: max(0, geo.size.width * viewModel.progress - 7))
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let progress = min(max(value.location.x / geo.size.width, 0), 1)
                                    viewModel.seek(to: progress)
                                }
                        )
                    }
                    .frame(height: 14)
                    
                    // Time labels
                    HStack {
                        Text(viewModel.formattedCurrentTime)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text(viewModel.formattedDuration)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Language Picker Overlay
    
    private var languagePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.showLanguagePicker = false
                    }
                }
            
            VStack(spacing: 16) {
                Text(settingsManager.localizedString("select_language"))
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    ForEach(StreamLanguage.allCases) { language in
                        Button {
                            viewModel.changeLanguage(to: language)
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.showLanguagePicker = false
                            }
                        } label: {
                            HStack {
                                Text(language.flag)
                                    .font(.title2)
                                Text(language.displayName)
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedStreamLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.akislarGold)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                viewModel.selectedStreamLanguage == language
                                ? Color.akislarGold.opacity(0.15)
                                : Color.clear
                            )
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.akislarCardBg)
                    .shadow(color: .black.opacity(0.5), radius: 20)
            )
            .padding(40)
        }
        .transition(.opacity)
    }
}
