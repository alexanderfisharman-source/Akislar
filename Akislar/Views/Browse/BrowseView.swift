import SwiftUI

struct BrowseView: View {
    @EnvironmentObject var catalogService: CatalogService
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var viewModel = BrowseViewModel(catalogService: CatalogService())
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Genre filter
                genreFilter
                
                // Results
                if viewModel.filteredSeries.isEmpty {
                    emptyState
                } else {
                    seriesGrid
                }
            }
            .background(Color.akislarDarkBg)
            .navigationTitle(settingsManager.localizedString("browse"))
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.filteredSeries = catalogService.allSeries
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.akislarSubtle)
            
            TextField(settingsManager.localizedString("search"), text: $viewModel.searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.akislarSubtle)
                }
            }
        }
        .padding(14)
        .background(Color.akislarCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Genre Filter
    
    private var genreFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.genres, id: \.self) { genre in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedGenre = genre == "All" ? nil : genre
                        }
                    } label: {
                        Text(genre)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isGenreSelected(genre) ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                isGenreSelected(genre)
                                ? AnyShapeStyle(Color.akislarGold)
                                : AnyShapeStyle(Color.akislarCardBg)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        isGenreSelected(genre) ? Color.clear : Color.white.opacity(0.1),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
    
    private func isGenreSelected(_ genre: String) -> Bool {
        if genre == "All" { return viewModel.selectedGenre == nil }
        return viewModel.selectedGenre == genre
    }
    
    // MARK: - Series Grid
    
    private var seriesGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 20
            ) {
                ForEach(viewModel.filteredSeries) { series in
                    NavigationLink(destination: SeriesDetailView(series: series)) {
                        SeriesCardView(series: series, style: .grid)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "film.stack")
                .font(.system(size: 50))
                .foregroundColor(.akislarSubtle)
            Text(settingsManager.localizedString("no_results"))
                .font(.headline)
                .foregroundColor(.akislarSubtle)
            Spacer()
        }
    }
}
