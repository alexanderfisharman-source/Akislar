import SwiftUI
import WebKit
import Combine

@MainActor
class PlayerViewModel: ObservableObject {
    var webView: WKWebView? // The YouTube bridge will assign this
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isBuffering = true
    @Published var showControls = true
    @Published var selectedStreamLanguage: StreamLanguage
    @Published var showLanguagePicker = false
    
    let episode: Episode
    init(episode: Episode, preferredLanguage: StreamLanguage) {
        self.episode = episode
        self.selectedStreamLanguage = preferredLanguage
        // The bridge handles setup when the view mounts
    }
    
    func setupPlayer() {
        // Handled by YouTubePlayerBridge
    }
    
    func togglePlayPause() {
        if isPlaying {
            webView?.evaluateJavaScript("pauseVideo()", completionHandler: nil)
        } else {
            webView?.evaluateJavaScript("playVideo()", completionHandler: nil)
        }
        isPlaying.toggle()
        resetControlsTimer()
    }
    
    func seek(to progress: Double) {
        let time = progress * duration
        webView?.evaluateJavaScript("seekTo(\(time))", completionHandler: nil)
    }
    
    func skipForward(_ seconds: Double = 10) {
        let target = min(currentTime + seconds, duration)
        webView?.evaluateJavaScript("seekTo(\(target))", completionHandler: nil)
    }
    
    func skipBackward(_ seconds: Double = 10) {
        let target = max(currentTime - seconds, 0)
        webView?.evaluateJavaScript("seekTo(\(target))", completionHandler: nil)
    }
    
    func changeLanguage(to language: StreamLanguage) {
        selectedStreamLanguage = language
        // YouTube videos typically have hardcoded dubs per video ID or use CC.
        // For the sake of standardizing the app UI, we let them "switch" language
        // but the actual video ID won't change unless we dynamically mapped them.
        toggleControls() 
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
        webView?.evaluateJavaScript("pauseVideo()", completionHandler: nil)
        hideControlsTimer?.invalidate()
        webView = nil
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
