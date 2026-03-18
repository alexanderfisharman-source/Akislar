import SwiftUI

struct HomeView: View {
    @EnvironmentObject var catalogService: CatalogService
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var viewModel: HomeViewModel = HomeViewModel(catalogService: CatalogService())
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Banner
                    heroSection
                    
                    // Content sections
                    VStack(spacing: 28) {
                        // Trending
                        sectionHeader(settingsManager.localizedString("trending"))
                        trendingRow
                        
                        // All Series
                        sectionHeader(settingsManager.localizedString("all_series"))
                        allSeriesGrid
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.akislarDarkBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("AKISLAR")
                        .font(.system(size: 22, weight: .black, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.akislarGold, Color.akislarAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        TabView(selection: $viewModel.selectedFeaturedIndex) {
            ForEach(Array(catalogService.featuredSeries.enumerated()), id: \.element.id) { index, series in
                NavigationLink(destination: SeriesDetailView(series: series)) {
                    ZStack(alignment: .bottomLeading) {
                        // Background image
                        AsyncImage(url: series.bannerImage) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.akislarGold.opacity(0.3), Color.akislarDarkBg],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            default:
                                Rectangle()
                                    .fill(Color.akislarCardBg)
                                    .overlay(ProgressView().tint(.white))
                            }
                        }
                        .frame(height: 450)
                        .clipped()
                        
                        // Gradient overlay
                        LinearGradient(
                            colors: [.clear, Color.akislarDarkBg.opacity(0.8), Color.akislarDarkBg],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Info overlay
                        VStack(alignment: .leading, spacing: 12) {
                            Text(series.title)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                            
                            Text(series.synopsis)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(2)
                            
                            HStack(spacing: 12) {
                                // Play button
                                Label(settingsManager.localizedString("play"), systemImage: "play.fill")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.akislarGold)
                                    .cornerRadius(8)
                                
                                // Rating
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", series.rating))
                                        .foregroundColor(.white)
                                }
                                .font(.subheadline.weight(.semibold))
                                
                                // Year
                                Text(series.year)
                                    .font(.caption)
                                    .foregroundColor(.akislarSubtle)
                            }
                        }
                        .padding(24)
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 450)
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Trending Row
    
    private var trendingRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(catalogService.trendingSeries) { series in
                    NavigationLink(destination: SeriesDetailView(series: series)) {
                        SeriesCardView(series: series)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - All Series Grid
    
    private var allSeriesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 20
        ) {
            ForEach(catalogService.allSeries) { series in
                NavigationLink(destination: SeriesDetailView(series: series)) {
                    SeriesCardView(series: series, style: .grid)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
