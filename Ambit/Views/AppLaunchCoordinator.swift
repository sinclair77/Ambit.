import SwiftUI

struct AppLaunchCoordinator<Content: View>: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    let content: () -> Content

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                content()
            } else {
                OnboardingFlowView()
            }
        }
    }
}
