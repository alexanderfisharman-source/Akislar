import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var featuredSeries: [Series] = []
    @Published var trendingSeries: [Series] = []
    @Published var selectedFeaturedIndex = 0
    
    private var catalogService: CatalogService
    private var timer: Timer?
    
    init(catalogService: CatalogService) {
        self.catalogService = catalogService
        loadData()
        startAutoScroll()
    }
    
    func loadData() {
        featuredSeries = catalogService.featuredSeries
        trendingSeries = catalogService.trendingSeries
    }
    
    func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard !self.featuredSeries.isEmpty else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.selectedFeaturedIndex = (self.selectedFeaturedIndex + 1) % self.featuredSeries.count
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
