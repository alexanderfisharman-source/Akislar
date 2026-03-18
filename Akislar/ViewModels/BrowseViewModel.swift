import SwiftUI
import Combine

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedGenre: String? = nil
    @Published var filteredSeries: [Series] = []
    
    private var catalogService: CatalogService
    private var cancellables = Set<AnyCancellable>()
    
    let genres = ["All", "Drama", "Action", "History", "Adventure", "Romance", "Thriller"]
    
    init(catalogService: CatalogService) {
        self.catalogService = catalogService
        filteredSeries = catalogService.allSeries
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        $selectedGenre
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    func applyFilters() {
        var results = catalogService.searchSeries(searchText)
        
        if let genre = selectedGenre, genre != "All" {
            results = results.filter { $0.genres.contains(genre) }
        }
        
        filteredSeries = results
    }
}
