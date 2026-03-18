import SwiftUI
import Combine

@MainActor
class SeriesDetailViewModel: ObservableObject {
    @Published var series: Series
    @Published var episodes: [Episode] = []
    @Published var selectedSeason: Int = 1
    @Published var isLoading = false
    
    private var catalogService: CatalogService
    
    init(series: Series, catalogService: CatalogService) {
        self.series = series
        self.catalogService = catalogService
        loadEpisodes()
    }
    
    var seasons: [Int] {
        Array(1...series.totalSeasons)
    }
    
    var currentSeasonEpisodes: [Episode] {
        episodes.filter { $0.season == selectedSeason }
    }
    
    func loadEpisodes() {
        isLoading = true
        episodes = catalogService.episodes(for: series.id)
        isLoading = false
    }
    
    func selectSeason(_ season: Int) {
        withAnimation {
            selectedSeason = season
        }
    }
}
