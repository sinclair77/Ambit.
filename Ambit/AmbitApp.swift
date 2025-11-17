import SwiftUI
import SwiftData
import UIKit

@main
struct AmbitApp: App {
    init() {
        // Register custom value transformers early so SwiftData can resolve them
        ColorArrayTransformer.register()
        UnitPointTransformer.register()
        // Force UIKit-backed text views to push long words instead of hyphenating them
        UILabel.appearance().lineBreakStrategy = .pushOut
    }
    
    var body: some Scene {
        WindowGroup {
            SplashContainerView()
        }
        .modelContainer(for: [SavedPalette.self, SavedCard.self, SavedGradient.self])
    }
}
