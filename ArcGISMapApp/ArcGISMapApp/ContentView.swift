import ArcGIS
import SwiftUI

struct ContentView: View {
    @State private var map = Map(basemapStyle: .arcGISTopographic)
    @StateObject private var locationDisplay = LocationDisplay(dataSource: DefaultLocationDataSource())
    @State private var locationError: Error?

    var body: some View {
        MapView(map: map, locationDisplay: locationDisplay)
            .onAppear {
                Task {
                    await startLocationDisplay()
                }
            }
            .alert("Location Error", isPresented: Binding(
                get: { locationError != nil },
                set: { if !$0 { locationError = nil } }
            )) {
                Button("OK", role: .cancel) { locationError = nil }
            } message: {
                if let locationError {
                    Text(locationError.localizedDescription)
                }
            }
    }

    @MainActor
    private func startLocationDisplay() async {
        guard !locationDisplay.isStarted else { return }
        do {
            try await locationDisplay.dataSource.start()
            locationDisplay.autoPanMode = .recenter
            try await locationDisplay.start()
        } catch {
            locationError = error
        }
    }
}

#Preview {
    ContentView()
}
