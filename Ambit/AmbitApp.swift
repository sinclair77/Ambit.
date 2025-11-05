import SwiftUI
import SwiftData

@main
struct AmbitApp: App {
    init() {
        // Register custom value transformers early so SwiftData can resolve them
        ColorArrayTransformer.register()
        UnitPointTransformer.register()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SavedPalette.self, SavedCard.self, SavedGradient.self])
    }
}
