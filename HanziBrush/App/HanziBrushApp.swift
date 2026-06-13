import SwiftUI

@main
struct HanziBrushApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .tint(InkTheme.red)
        }
    }
}
