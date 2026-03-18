import SwiftUI

struct SeriesDetailView: View {
    let series: Series
    @EnvironmentObject var catalogService: CatalogService
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedSeason = 1
    @State private var showPlayer = false
    @State private var selectedEpisode: Episode?
    
    private var episodes: [Episode] {
        catalogService.episodes(for: series.id, season: selectedSeason)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero banner
                heroBanner
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Title and meta
                    titleSection
                    
                    // Play button
                    playButton
                    
                    // Synopsis
                    synopsisSection
                    
                    // Cast
                    castSection
                    
                    // Season picker
                    seasonPicker
                    
                    // Episodes
                    episodesList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.akislarDarkBg)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedEpisode) { episode in
            PlayerView(episode: episode)
        }
    }
    
    // MARK: - Hero Banner
    
    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
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
                                colors: [Color.akislarGold.opacity(0.2), Color.akislarDarkBg],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                default:
                    Rectangle()
                        .fill(Color.akislarCardBg)
                        .overlay(ProgressView().tint(.white))
                }
            }
            .frame(height: 350)
            .clipped()
            
            LinearGradient(
                colors: [.clear, Color.akislarDarkBg.opacity(0.9), Color.akislarDarkBg],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 350)
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(series.title)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)
            
            if series.title != series.originalTitle {
                Text(series.originalTitle)
                    .font(.subheadline)
                    .foregroundColor(.akislarSubtle)
                    .italic()
            }
            
            HStack(spacing: 16) {
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    Text(String(format: "%.1f", series.rating))
                        .foregroundColor(.white)
                        .font(.subheadline.weight(.semibold))
                }
                
                Text("•")
                    .foregroundColor(.akislarSubtle)
                
                Text(series.year)
                    .font(.subheadline)
                    .foregroundColor(.akislarSubtle)
                
                Text("•")
                    .foregroundColor(.akislarSubtle)
                
                Text("\(series.totalSeasons) \(settingsManager.localizedString("season"))")
                    .font(.subheadline)
                    .foregroundColor(.akislarSubtle)
            }
            
            // Genre tags
            HStack(spacing: 8) {
                ForEach(series.genres, id: \.self) { genre in
                    Text(genre)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.akislarGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.akislarGold.opacity(0.12))
                        .cornerRadius(6)
                }
            }
        }
    }
    
    // MARK: - Play Button
    
    private var playButton: some View {
        Button {
            if let firstEp = episodes.first {
                selectedEpisode = firstEp
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                Text(settingsManager.localizedString("play"))
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.akislarGold, Color.akislarAccent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.akislarGold.opacity(0.3), radius: 10, y: 4)
        }
    }
    
    // MARK: - Synopsis
    
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(settingsManager.localizedString("synopsis"))
                .font(.headline)
                .foregroundColor(.white)
            
            Text(series.synopsis)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(4)
        }
    }
    
    // MARK: - Cast
    
    private var castSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(settingsManager.localizedString("cast"))
                .font(.headline)
                .foregroundColor(.white)
            
            Text(series.cast.joined(separator: " • "))
                .font(.subheadline)
                .foregroundColor(.akislarSubtle)
        }
    }
    
    // MARK: - Season Picker
    
    private var seasonPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(settingsManager.localizedString("episodes"))
                .font(.headline)
                .foregroundColor(.white)
            
            if series.totalSeasons > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(1...series.totalSeasons, id: \.self) { season in
                            Button {
                                withAnimation { selectedSeason = season }
                            } label: {
                                Text("\(settingsManager.localizedString("season")) \(season)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(selectedSeason == season ? .black : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedSeason == season
                                        ? Color.akislarGold
                                        : Color.akislarCardBg
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Episodes List
    
    private var episodesList: some View {
        VStack(spacing: 12) {
            ForEach(episodes) { episode in
                Button {
                    selectedEpisode = episode
                } label: {
                    HStack(spacing: 14) {
                        // Thumbnail
                        AsyncImage(url: episode.thumbnailImage) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                Rectangle()
                                    .fill(Color.akislarCardBg)
                                    .overlay(
                                        Image(systemName: "play.circle")
                                            .font(.title2)
                                            .foregroundColor(.akislarGold.opacity(0.5))
                                    )
                            }
                        }
                        .frame(width: 130, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("E\(episode.episodeNumber). \(episode.title)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(episode.synopsis)
                                .font(.caption)
                                .foregroundColor(.akislarSubtle)
                                .lineLimit(2)
                            
                            Text(episode.duration)
                                .font(.caption2)
                                .foregroundColor(.akislarGold)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.akislarGold)
                    }
                    .padding(12)
                    .background(Color.akislarCardBg)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
        }
    }
}
