import SwiftUI
import AVKit
import Combine

@MainActor
class PlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isBuffering = true
    @Published var showControls = true
    @Published var selectedStreamLanguage: StreamLanguage
    @Published var showLanguagePicker = false
    
    let episode: Episode
    private var timeObserver: Any?
    private var hideControlsTimer: Timer?
    
    init(episode: Episode, preferredLanguage: StreamLanguage) {
        self.episode = episode
        self.selectedStreamLanguage = preferredLanguage
        setupPlayer()
    }
    
    func setupPlayer() {
        guard let url = episode.streamURL(for: selectedStreamLanguage) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe time
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.currentTime = time.seconds
                if let duration = self.player?.currentItem?.duration.seconds, duration.isFinite {
                    self.duration = duration
                }
                self.isBuffering = false
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        resetControlsTimer()
    }
    
    func seek(to progress: Double) {
        let time = CMTime(seconds: progress * duration, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func skipForward(_ seconds: Double = 10) {
        let target = min(currentTime + seconds, duration)
        let time = CMTime(seconds: target, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func skipBackward(_ seconds: Double = 10) {
        let target = max(currentTime - seconds, 0)
        let time = CMTime(seconds: target, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func changeLanguage(to language: StreamLanguage) {
        let currentProgress = duration > 0 ? currentTime / duration : 0
        selectedStreamLanguage = language
        
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        
        setupPlayer()
        
        // Restore position
        if duration > 0 {
            let time = CMTime(seconds: currentProgress * duration, preferredTimescale: 600)
            player?.seek(to: time) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.player?.play()
                    self?.isPlaying = true
                }
            }
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        if showControls {
            resetControlsTimer()
        }
    }
    
    private func resetControlsTimer() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showControls = false
                }
            }
        }
    }
    
    func cleanup() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        hideControlsTimer?.invalidate()
        player = nil
    }
    
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    var formattedDuration: String {
        formatTime(duration)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
