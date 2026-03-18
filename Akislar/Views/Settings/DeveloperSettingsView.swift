import SwiftUI

struct DeveloperSettingsView: View {
    @EnvironmentObject var catalogService: CatalogService
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var apiClient = YouTubeAPIClient()
    
    @State private var newSeriesId: String = ""
    @State private var newSeriesTitle: String = ""
    @State private var newPlaylistId: String = ""
    @State private var newPosterURL: String = ""
    @State private var isSyncing: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text(settingsManager.localizedString("youtube_api_key"))) {
                TextField("Enter API Key", text: $settingsManager.youtubeApiKey)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            Section(header: Text(settingsManager.localizedString("add_series"))) {
                TextField(settingsManager.localizedString("series_id"), text: $newSeriesId)
                TextField("Title", text: $newSeriesTitle)
                TextField(settingsManager.localizedString("playlist_id"), text: $newPlaylistId)
                TextField(settingsManager.localizedString("poster_url"), text: $newPosterURL)
                
                Button {
                    syncNewSeries()
                } label: {
                    if isSyncing {
                        HStack {
                            ProgressView()
                            Text(settingsManager.localizedString("syncing"))
                        }
                    } else {
                        Text(settingsManager.localizedString("sync_playlist"))
                    }
                }
                .disabled(isSyncing || newSeriesId.isEmpty || newPlaylistId.isEmpty || settingsManager.youtubeApiKey.isEmpty)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section(header: Text(settingsManager.localizedString("custom_series"))) {
                if catalogService.userSeries.isEmpty {
                    Text("No custom series added yet.")
                        .foregroundColor(.akislarSubtle)
                } else {
                    ForEach(catalogService.userSeries) { series in
                        VStack(alignment: .leading) {
                            Text(series.title)
                                .font(.headline)
                            Text(series.id)
                                .font(.caption)
                                .foregroundColor(.akislarSubtle)
                            
                            HStack {
                                Button("Resync") {
                                    resyncSeries(series)
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(.akislarGold)
                                
                                Spacer()
                                
                                Button(settingsManager.localizedString("delete")) {
                                    deleteSeries(series)
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(settingsManager.localizedString("developer_mode"))
        .onAppear {
            apiClient.saveApiKey(settingsManager.youtubeApiKey)
        }
    }
    
    private func syncNewSeries() {
        isSyncing = true
        errorMessage = nil
        
        Task {
            do {
                apiClient.saveApiKey(settingsManager.youtubeApiKey)
                let episodes = try await apiClient.fetchPlaylistEpisodes(
                    playlistId: newPlaylistId,
                    seriesId: newSeriesId
                )
                
                let series = Series(
                    id: newSeriesId,
                    title: newSeriesTitle,
                    originalTitle: newSeriesTitle,
                    posterURL: newPosterURL,
                    bannerURL: newPosterURL,
                    synopsis: "Imported via YouTube Playlist: \(newPlaylistId)",
                    cast: ["YouTube"],
                    genres: ["Imported"],
                    year: "Various",
                    rating: 10.0,
                    totalSeasons: 1,
                    totalEpisodes: episodes.count,
                    isFeatured: true
                )
                
                await MainActor.run {
                    catalogService.addSeries(series)
                    catalogService.addEpisodes(for: newSeriesId, episodes: episodes)
                    isSyncing = false
                    // Reset fields
                    newSeriesId = ""
                    newSeriesTitle = ""
                    newPlaylistId = ""
                    newPosterURL = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSyncing = false
                }
            }
        }
    }
    
    private func resyncSeries(_ series: Series) {
        // Implementation for resyncing using existing metadata if we stored the playlist ID in synopsis or similar
        // For now, let's keep it simple.
    }
    
    private func deleteSeries(_ series: Series) {
        withAnimation {
            catalogService.removeSeries(id: series.id)
        }
    }
}
