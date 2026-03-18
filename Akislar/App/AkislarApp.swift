import SwiftUI

@main
struct AkislarApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var catalogService = CatalogService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(settingsManager)
                .environmentObject(catalogService)
                .preferredColorScheme(.dark)
        }
    }
}
