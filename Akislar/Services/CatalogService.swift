import Foundation

@MainActor
class CatalogService: ObservableObject {
    @Published var allSeries: [Series] = []
    @Published var allEpisodes: [String: [Episode]] = [:] // keyed by series ID
    @Published var isLoading = false
    
    init() {
        loadCatalog()
    }
    
    var featuredSeries: [Series] {
        allSeries.filter { $0.isFeatured }
    }
    
    var trendingSeries: [Series] {
        allSeries.sorted { $0.rating > $1.rating }
    }
    
    func searchSeries(_ query: String) -> [Series] {
        guard !query.isEmpty else { return allSeries }
        let lowered = query.lowercased()
        return allSeries.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.originalTitle.lowercased().contains(lowered) ||
            $0.genres.contains { $0.lowercased().contains(lowered) } ||
            $0.cast.contains { $0.lowercased().contains(lowered) }
        }
    }
    
    func episodes(for seriesId: String, season: Int? = nil) -> [Episode] {
        let eps = allEpisodes[seriesId] ?? []
        if let season {
            return eps.filter { $0.season == season }
        }
        return eps
    }
    
    // MARK: - Load bundled catalog
    
    private func loadCatalog() {
        isLoading = true
        
        // Bundled series data
        allSeries = Self.bundledSeries
        allEpisodes = Self.bundledEpisodes
        
        isLoading = false
    }
    
    // MARK: - Bundled Content
    
    static let bundledSeries: [Series] = [
        Series(
            id: "kurulus-osman",
            title: "Kurulus: Osman",
            originalTitle: "Kuruluş: Osman",
            posterURL: "https://image.tmdb.org/t/p/w500/kUPkMjbJIVGGJMddWOgnIw2mGal.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/kUPkMjbJIVGGJMddWOgnIw2mGal.jpg",
            synopsis: "The life of Osman I, the founder of the Ottoman Empire. Osman, the son of Ertugrul Ghazi, struggles to establish the Ottoman state against the Byzantine Empire and the Mongol invaders.",
            cast: ["Burak Özçivit", "Özge Törer", "Yıldız Çağrı Atiksoy", "Ragıp Savaş"],
            genres: ["Drama", "Action", "History"],
            year: "2019–Present",
            rating: 8.1,
            totalSeasons: 6,
            totalEpisodes: 170,
            isFeatured: true
        ),
        Series(
            id: "dirilis-ertugrul",
            title: "Dirilis: Ertugrul",
            originalTitle: "Diriliş: Ertuğrul",
            posterURL: "https://image.tmdb.org/t/p/w500/p6dDkOxjbIFUqkjOavixNfyDIzX.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/p6dDkOxjbIFUqkjOavixNfyDIzX.jpg",
            synopsis: "Ertugrul, the father of Osman I and leader of the Kayi tribe of the Oghuz Turks, must fight to protect his tribe from threats both external and internal.",
            cast: ["Engin Altan Düzyatan", "Hülya Darcan", "Esra Bilgiç", "Cengiz Coşkun"],
            genres: ["Drama", "Action", "History", "Adventure"],
            year: "2014–2019",
            rating: 8.4,
            totalSeasons: 5,
            totalEpisodes: 150,
            isFeatured: true
        ),
        Series(
            id: "alparslan",
            title: "Alparslan: The Great Seljuks",
            originalTitle: "Alparslan: Büyük Selçuklu",
            posterURL: "https://image.tmdb.org/t/p/w500/a3DXPt3gD3ua4aK6bQMWm2qpBtX.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/a3DXPt3gD3ua4aK6bQMWm2qpBtX.jpg",
            synopsis: "The story of Sultan Alparslan, the second sultan of the Great Seljuk Empire, who achieved the historic victory at the Battle of Manzikert.",
            cast: ["Barış Arduç", "Fahriye Evcen", "Mehmet Özgür"],
            genres: ["Drama", "Action", "History"],
            year: "2021–2023",
            rating: 7.6,
            totalSeasons: 2,
            totalEpisodes: 60,
            isFeatured: false
        ),
        Series(
            id: "payitaht-abdulhamid",
            title: "Payitaht: Abdulhamid",
            originalTitle: "Payitaht: Abdülhamid",
            posterURL: "https://image.tmdb.org/t/p/w500/xtBhd0RJFz1SOFekRKBHfR2rkSV.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/xtBhd0RJFz1SOFekRKBHfR2rkSV.jpg",
            synopsis: "The political and personal life of Sultan Abdulhamid II during the decline of the Ottoman Empire, facing conspiracies from both within and outside.",
            cast: ["Bülent İnal", "Özlem Conker", "Hakan Boyav"],
            genres: ["Drama", "History", "Thriller"],
            year: "2017–2021",
            rating: 7.9,
            totalSeasons: 5,
            totalEpisodes: 154,
            isFeatured: true
        ),
        Series(
            id: "mehmed-fetihler-sultani",
            title: "Mehmed: Sultan of Conquests",
            originalTitle: "Mehmed: Fetihler Sultanı",
            posterURL: "https://image.tmdb.org/t/p/w500/bUJaEmRbNQfaaq9DVy4lkxtZMNy.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/bUJaEmRbNQfaaq9DVy4lkxtZMNy.jpg",
            synopsis: "The epic story of Mehmed the Conqueror, who conquered Constantinople at the age of 21 and changed the course of world history.",
            cast: ["Devrim Özkan", "Burak Ozcivit"],
            genres: ["Drama", "Action", "History"],
            year: "2024–Present",
            rating: 7.8,
            totalSeasons: 1,
            totalEpisodes: 20,
            isFeatured: true
        ),
        Series(
            id: "barbaroslar",
            title: "Barbaroslar: Sword of the Mediterranean",
            originalTitle: "Barbaroslar: Akdeniz'in Kılıcı",
            posterURL: "https://image.tmdb.org/t/p/w500/xqv1t3Y3nVwVhkKCqwdKtVOiRcf.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/xqv1t3Y3nVwVhkKCqwdKtVOiRcf.jpg",
            synopsis: "The legendary story of the Barbarossa brothers — Hayreddin and Oruc — who became the most feared pirates of the Mediterranean.",
            cast: ["Engin Altan Düzyatan", "Ulaş Tuna Astepe"],
            genres: ["Drama", "Action", "Adventure"],
            year: "2021–2022",
            rating: 7.2,
            totalSeasons: 1,
            totalEpisodes: 28,
            isFeatured: false
        ),
        Series(
            id: "the-magnificent-century",
            title: "Magnificent Century",
            originalTitle: "Muhteşem Yüzyıl",
            posterURL: "https://image.tmdb.org/t/p/w500/8xeLXnQ0i5Y8ohaMDqYPnpYCpyh.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/8xeLXnQ0i5Y8ohaMDqYPnpYCpyh.jpg",
            synopsis: "The life of Suleiman the Magnificent, the longest-reigning Sultan of the Ottoman Empire, and his powerful love for Hürrem Sultan.",
            cast: ["Halit Ergenç", "Meryem Uzerli", "Nebahat Çehre"],
            genres: ["Drama", "History", "Romance"],
            year: "2011–2014",
            rating: 8.3,
            totalSeasons: 4,
            totalEpisodes: 139,
            isFeatured: false
        ),
        Series(
            id: "uyanis-buyuk-selcuklu",
            title: "The Great Seljuks: Guardians of Justice",
            originalTitle: "Uyanış: Büyük Selçuklu",
            posterURL: "https://image.tmdb.org/t/p/w500/6AfdLNLhPqPHtxYwNnsMxofFrBm.jpg",
            bannerURL: "https://image.tmdb.org/t/p/original/6AfdLNLhPqPHtxYwNnsMxofFrBm.jpg",
            synopsis: "The political struggles and military campaigns of Melikşah I and Nizam al-Mulk as they defend the Great Seljuk Empire from assassins and traitors.",
            cast: ["Buğra Gülsoy", "Kaan Taşaner", "Hatice Şendil"],
            genres: ["Drama", "Action", "History"],
            year: "2020–2021",
            rating: 7.4,
            totalSeasons: 1,
            totalEpisodes: 34,
            isFeatured: false
        ),
    ]
    
    static let bundledEpisodes: [String: [Episode]] = [
        "kurulus-osman": (1...10).map { num in
            Episode(
                id: "ko-s1-e\(num)",
                seriesId: "kurulus-osman",
                title: "Episode \(num)",
                season: 1,
                episodeNumber: num,
                synopsis: "Osman Bey continues his quest to establish justice and build a new state in Söğüt. Episode \(num) of the epic journey.",
                duration: "\(120 + Int.random(in: -10...10)) min",
                thumbnailURL: "https://image.tmdb.org/t/p/w300/kUPkMjbJIVGGJMddWOgnIw2mGal.jpg",
                streamURLs: [
                    "tr": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "en": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "ar": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
                ]
            )
        },
        "dirilis-ertugrul": (1...10).map { num in
            Episode(
                id: "de-s1-e\(num)",
                seriesId: "dirilis-ertugrul",
                title: "Episode \(num)",
                season: 1,
                episodeNumber: num,
                synopsis: "Ertugrul Ghazi faces new challenges as he leads the Kayi tribe. Adventure and honor await in Episode \(num).",
                duration: "\(110 + Int.random(in: -10...10)) min",
                thumbnailURL: "https://image.tmdb.org/t/p/w300/p6dDkOxjbIFUqkjOavixNfyDIzX.jpg",
                streamURLs: [
                    "tr": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "en": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "ar": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
                ]
            )
        },
        "payitaht-abdulhamid": (1...5).map { num in
            Episode(
                id: "pa-s1-e\(num)",
                seriesId: "payitaht-abdulhamid",
                title: "Episode \(num)",
                season: 1,
                episodeNumber: num,
                synopsis: "Sultan Abdulhamid II navigates the treacherous waters of late Ottoman politics. Episode \(num).",
                duration: "\(115 + Int.random(in: -10...10)) min",
                thumbnailURL: "https://image.tmdb.org/t/p/w300/xtBhd0RJFz1SOFekRKBHfR2rkSV.jpg",
                streamURLs: [
                    "tr": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "en": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "ar": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
                ]
            )
        },
        "mehmed-fetihler-sultani": (1...5).map { num in
            Episode(
                id: "mfs-s1-e\(num)",
                seriesId: "mehmed-fetihler-sultani",
                title: "Episode \(num)",
                season: 1,
                episodeNumber: num,
                synopsis: "Mehmed's rise to power and the siege of Constantinople. Episode \(num).",
                duration: "\(125 + Int.random(in: -10...10)) min",
                thumbnailURL: "https://image.tmdb.org/t/p/w300/bUJaEmRbNQfaaq9DVy4lkxtZMNy.jpg",
                streamURLs: [
                    "tr": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "en": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                    "ar": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
                ]
            )
        },
    ]
}
