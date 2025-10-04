import SwiftUI
import ArcGIS

@main
struct ArcGISMapAppApp: App {
    init() {
        // TODO: Replace with your ArcGIS API key.
        ArcGISEnvironment.apiKey = APIKey("<#Your ArcGIS API Key#>")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
