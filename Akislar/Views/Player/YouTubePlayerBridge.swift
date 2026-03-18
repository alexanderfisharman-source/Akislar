import SwiftUI
import WebKit

struct YouTubePlayerBridge: UIViewRepresentable {
    @ObservedObject var viewModel: PlayerViewModel
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Add script message handler
        configuration.userContentController.add(context.coordinator, name: "youtubeBridge")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        // Prevent user interaction on the web view directly so our custom SwiftUI overlay works
        webView.isUserInteractionEnabled = false 
        
        // Assign the webview to the view model so it can call JS functions
        viewModel.webView = webView
        
        loadYouTubePlayer(in: webView, videoId: videoId)
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Handle video ID changes if necessary
        if context.coordinator.currentVideoId != videoId {
            context.coordinator.currentVideoId = videoId
            loadYouTubePlayer(in: uiView, videoId: videoId)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func loadYouTubePlayer(in webView: WKWebView, videoId: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body { margin: 0; padding: 0; background-color: black; overflow: hidden; }
                iframe { width: 100vw; height: 100vh; pointer-events: none; }
            </style>
        </head>
        <body>
            <div id="player"></div>
            <script>
                var tag = document.createElement('script');
                tag.src = "https://www.youtube.com/iframe_api";
                var firstScriptTag = document.getElementsByTagName('script')[0];
                firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

                var player;
                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        height: '100%',
                        width: '100%',
                        videoId: '\(videoId)',
                        playerVars: {
                            'playsinline': 1,
                            'controls': 0,
                            'rel': 0,
                            'modestbranding': 1,
                            'showinfo': 0,
                            'fs': 0,
                            'disablekb': 1,
                            'iv_load_policy': 3
                        },
                        events: {
                            'onReady': onPlayerReady,
                            'onStateChange': onPlayerStateChange
                        }
                    });
                }

                function onPlayerReady(event) {
                    window.webkit.messageHandlers.youtubeBridge.postMessage({event: 'ready'});
                    event.target.playVideo();
                    setInterval(function() {
                        if (player && player.getCurrentTime) {
                            window.webkit.messageHandlers.youtubeBridge.postMessage({
                                event: 'timeupdate',
                                time: player.getCurrentTime(),
                                duration: player.getDuration(),
                                loadedFraction: player.getVideoLoadedFraction()
                            });
                        }
                    }, 500);
                }

                function onPlayerStateChange(event) {
                    window.webkit.messageHandlers.youtubeBridge.postMessage({
                        event: 'statechange',
                        state: event.data
                    });
                }
                
                // Callable from Swift
                function playVideo() { player.playVideo(); }
                function pauseVideo() { player.pauseVideo(); }
                function seekTo(seconds) { player.seekTo(seconds, true); }
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: YouTubePlayerBridge
        var currentVideoId: String

        init(_ parent: YouTubePlayerBridge) {
            self.parent = parent
            self.currentVideoId = parent.videoId
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let dict = message.body as? [String: Any], let event = dict["event"] as? String else { return }
            
            Task { @MainActor in
                switch event {
                case "ready":
                    parent.viewModel.isBuffering = false
                case "timeupdate":
                    if let time = dict["time"] as? Double {
                        parent.viewModel.currentTime = time
                    }
                    if let duration = dict["duration"] as? Double, duration > 0 {
                        parent.viewModel.duration = duration
                    }
                case "statechange":
                    if let state = dict["state"] as? Int {
                        // 1 = playing, 2 = paused, 3 = buffering
                        if state == 1 {
                            parent.viewModel.isPlaying = true
                            parent.viewModel.isBuffering = false
                        } else if state == 2 {
                            parent.viewModel.isPlaying = false
                        } else if state == 3 {
                            parent.viewModel.isBuffering = true
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}
