import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "play.tv.fill")
                    Text(settingsManager.localizedString("home"))
                }
                .tag(0)
            
            BrowseView()
                .tabItem {
                    Image(systemName: "rectangle.grid.2x2.fill")
                    Text(settingsManager.localizedString("browse"))
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(settingsManager.localizedString("settings"))
                }
                .tag(2)
        }
        .tint(Color("AccentGold"))
    }
}

// Color extension for our theme
extension Color {
    static let akislarGold = Color(red: 0.85, green: 0.65, blue: 0.25)
    static let akislarDarkBg = Color(red: 0.06, green: 0.06, blue: 0.10)
    static let akislarCardBg = Color(red: 0.10, green: 0.10, blue: 0.16)
    static let akislarAccent = Color(red: 0.90, green: 0.50, blue: 0.15)
    static let akislarSubtle = Color(red: 0.45, green: 0.45, blue: 0.55)
}
