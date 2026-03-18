import SwiftUI

struct SeriesCardView: View {
    let series: Series
    var style: CardStyle = .horizontal
    
    enum CardStyle {
        case horizontal
        case grid
    }
    
    var body: some View {
        switch style {
        case .horizontal:
            horizontalCard
        case .grid:
            gridCard
        }
    }
    
    // MARK: - Horizontal Card (for scroll rows)
    
    private var horizontalCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: series.posterImage) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderPoster
                default:
                    placeholderPoster
                        .overlay(ProgressView().tint(.white))
                }
            }
            .frame(width: 150, height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
            
            // Rating badge
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                    Text(String(format: "%.1f", series.rating))
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.akislarGold)
                .cornerRadius(6)
                .padding(8)
            }
            
            Text(series.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(series.year)
                .font(.caption)
                .foregroundColor(.akislarSubtle)
        }
        .frame(width: 150)
    }
    
    // MARK: - Grid Card
    
    private var gridCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: series.posterImage) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderPoster
                default:
                    placeholderPoster
                        .overlay(ProgressView().tint(.white))
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
            
            // Rating badge
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                    Text(String(format: "%.1f", series.rating))
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Color.akislarGold)
                .cornerRadius(6)
                .padding(10)
            }
            
            Text(series.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text(series.year)
                    .font(.caption2)
                    .foregroundColor(.akislarSubtle)
                
                ForEach(series.genres.prefix(2), id: \.self) { genre in
                    Text(genre)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.akislarGold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.akislarGold.opacity(0.15))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    // MARK: - Placeholder
    
    private var placeholderPoster: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.akislarCardBg, Color.akislarDarkBg],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundColor(.akislarGold.opacity(0.4))
                    Text(series.title)
                        .font(.caption2)
                        .foregroundColor(.akislarSubtle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            )
    }
}
