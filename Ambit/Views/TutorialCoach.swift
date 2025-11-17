import SwiftUI

@MainActor
final class TutorialCoach: ObservableObject {
    @AppStorage("hasCompletedTutorialImport") var completedImport = false
    @AppStorage("hasCompletedTutorialFavorite") var completedFavorite = false
    @AppStorage("hasCompletedTutorialShare") var completedShare = false

    var allDone: Bool { completedImport && completedFavorite && completedShare }

    func markImport() { completedImport = true }
    func markFavorite() { completedFavorite = true }
    func markShare() { completedShare = true }
}

struct TutorialNudge: ViewModifier {
    let isActive: Bool
    let text: String

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            if isActive {
                Text(text)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .padding(8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
                    .offset(x: -8, y: -8)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isActive)
    }
}

extension View {
    func tutorialNudge(active: Bool, text: String) -> some View {
        modifier(TutorialNudge(isActive: active, text: text))
    }
}
