# ArcGISMapApp

A minimal SwiftUI sample that displays an ArcGIS basemap and tracks the user's current location. The project targets iOS 18 and uses Swift 6.2, Xcode 26, and ArcGIS Maps SDK for Swift 200.8.

## Requirements

- Xcode 26
- iOS 18 SDK
- Swift 6.2 toolchain
- ArcGIS Maps SDK for Swift 200.8 (added through Swift Package Manager)
- A valid ArcGIS API key with privileges to access basemap and location services

## Setup

1. Open **ArcGISMapApp.xcodeproj** (create it from the included sources using the iOS App template if cloning the repo).
2. Add the ArcGIS Maps SDK for Swift 200.8 package:
   - In Xcode, select **File > Add Package Dependencies...**.
   - Use the package URL `https://github.com/Esri/arcgis-maps-sdk-swift.git`.
   - Set the dependency rule to **Exact Version: 200.8.0** and add the **ArcGIS** product to the target.
3. Replace the placeholder in `ArcGISMapAppApp.swift` with your ArcGIS API key.
4. Ensure the app has the `NSLocationWhenInUseUsageDescription` key in its Info.plist. The provided Info.plist already contains a sample message.
5. Build and run the app on an iOS 18 simulator or device that has location services enabled.

## Features

- Displays a topographic basemap using ArcGIS Maps SDK for Swift.
- Requests the user's permission to access their location when the map view appears.
- Automatically recenters the map to the user's current location when available.
- Shows an alert if location access fails or is unavailable.

## Notes

- The preview in `ContentView.swift` requires macOS Sonoma or later when using Xcode 26.
- On first launch, the system prompt requests location permission. Denying permission prevents the map from recentering on the user; the map will remain at the default extent.
