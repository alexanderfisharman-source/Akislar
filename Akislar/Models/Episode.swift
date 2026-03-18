import Foundation

struct Episode: Identifiable, Codable, Hashable {
    let id: String
    let seriesId: String
    let title: String
    let season: Int
    let episodeNumber: Int
    let synopsis: String
    let duration: String
    let thumbnailURL: String
    let streamURLs: [String: String] // key: language code, value: stream URL
    let youtubeVideoId: String? // Real YouTube Video ID
    
    var thumbnailImage: URL? { URL(string: thumbnailURL) }
    
    func streamURL(for language: StreamLanguage) -> URL? {
        if let urlString = streamURLs[language.code] {
            return URL(string: urlString)
        }
        // Fallback to Turkish if preferred language not available
        if let urlString = streamURLs[StreamLanguage.turkish.code] {
            return URL(string: urlString)
        }
        // Fallback to first available
        if let urlString = streamURLs.values.first {
            return URL(string: urlString)
        }
        return nil
    }
}
