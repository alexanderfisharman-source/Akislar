import Foundation

struct Series: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let originalTitle: String
    let posterURL: String
    let bannerURL: String
    let synopsis: String
    let cast: [String]
    let genres: [String]
    let year: String
    let rating: Double
    let totalSeasons: Int
    let totalEpisodes: Int
    let isFeatured: Bool
    
    var posterImage: URL? { URL(string: posterURL) }
    var bannerImage: URL? { URL(string: bannerURL) }
}
