import SwiftUI
import CoreLocation

/// Main content view for the application.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct ContentView: View {
    
    @State private var tabSelection: Int = 1
    
    var body: some View {
        
        TabView(selection: $tabSelection) {
            MainView(tabSelection: $tabSelection)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(1)
            RouteListView()
                .tabItem {
                    Image(systemName: "location.north.circle.fill")
                    Text("Route")
                }
                .tag(5)
            DeviceView()
                .tabItem {
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    Text("Sensor")
                }
                .tag(3)
            HistoryView()
                .tabItem {
                    Image(systemName: "scroll")
                    Text("History")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
                .background(Color(UIColor.systemBackground))
        }
    }
    
    init() {
        // Initializes UI tab bar appearance
        let appearance: UITabBarAppearance = UITabBarAppearance()
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
