import SwiftUI

struct SplashContainerView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            AppLaunchCoordinator {
                ContentView()
            }
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                AmbitSplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                // Drive the gradient animation; the splash will dismiss before many cycles
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct AmbitSplashView: View {
    @State private var splashColors: [Color] = []

    var body: some View {
        ZStack {
            // Monotone red/green gradient that changes every launch
            LinearGradient(
                gradient: Gradient(colors: splashColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // BIG, bold liquid-glass Ambit logotype
            Text("Ambit.")
                .font(.system(size: 72, weight: .black, design: .monospaced))
                .italic()
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.6), radius: 22, y: 14)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Text("Ambit.")
                            .font(.system(size: 72, weight: .black, design: .monospaced))
                            .italic()
                    )
                    .opacity(0.7)
                )
        }
        .onAppear {
            generateRandomPalette()
        }
    }

    private func generateRandomPalette() {
        let useRed = Bool.random()
        // Reds near 0.0, greens near ~0.33
        let baseHue: Double = useRed
            ? Double.random(in: 0.0...0.04)
            : Double.random(in: 0.30...0.38)

        splashColors = [
            Color(hue: baseHue, saturation: 0.85, brightness: 0.98),
            Color(hue: baseHue, saturation: 0.80, brightness: 0.72)
        ]
    }
}
