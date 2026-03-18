import Foundation

struct YouTubePlaylistItem: Codable {
    let snippet: Snippet
    let contentDetails: ContentDetails
    
    struct Snippet: Codable {
        let title: String
        let description: String
        let position: Int
        let thumbnails: Thumbnails
        
        struct Thumbnails: Codable {
            let maxres: Thumbnail?
            let standard: Thumbnail?
            let high: Thumbnail?
            let medium: Thumbnail?
            let `default`: Thumbnail?
            
            var bestURL: String? {
                maxres?.url ?? standard?.url ?? high?.url ?? medium?.url ?? `default`?.url
            }
        }
        
        struct Thumbnail: Codable {
            let url: String
            let width: Int?
            let height: Int?
        }
    }
    
    struct ContentDetails: Codable {
        let videoId: String
    }
}

struct YouTubePlaylistResponse: Codable {
    let items: [YouTubePlaylistItem]
    let nextPageToken: String?
}

@MainActor
class YouTubeAPIClient: ObservableObject {
    @Published var apiKey: String = ""
    
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "youtube_api_key") ?? ""
    }
    
    func saveApiKey(_ key: String) {
        self.apiKey = key
        UserDefaults.standard.set(key, forKey: "youtube_api_key")
    }
    
    func fetchPlaylistEpisodes(playlistId: String, seriesId: String, season: Int = 1) async throws -> [Episode] {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "YouTubeAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing."])
        }
        
        var allEpisodes: [Episode] = []
        var pageToken: String? = nil
        var currentEpisodeNumber = 1
        
        repeat {
            var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails&maxResults=50&playlistId=\(playlistId)&key=\(apiKey)"
            if let token = pageToken {
                urlString += "&pageToken=\(token)"
            }
            
            guard let url = URL(string: urlString) else { break }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "YouTubeAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch playlist data."])
            }
            
            let result = try JSONDecoder().decode(YouTubePlaylistResponse.self, from: data)
            
            for item in result.items {
                // Skip private/deleted videos that show up instantly as empty thumbnails or generic titles
                if item.snippet.title == "Private video" || item.snippet.title == "Deleted video" {
                    continue
                }
                
                let episode = Episode(
                    id: "\(seriesId)-s\(season)-e\(currentEpisodeNumber)",
                    seriesId: seriesId,
                    title: item.snippet.title,
                    season: season,
                    episodeNumber: currentEpisodeNumber,
                    synopsis: item.snippet.description,
                    duration: "45 min", // Usually requires an extra video API call, keeping static for now
                    thumbnailURL: item.snippet.thumbnails.bestURL ?? "",
                    streamURLs: [:],
                    youtubeVideoId: item.contentDetails.videoId
                )
                allEpisodes.append(episode)
                currentEpisodeNumber += 1
            }
            
            pageToken = result.nextPageToken
        } while pageToken != nil
        
        return allEpisodes
    }
}
