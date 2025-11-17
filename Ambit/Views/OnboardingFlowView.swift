import SwiftUI
import PhotosUI

struct OnboardingFlowView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedAccentHue") private var selectedAccentHue: Double = 0.55
    @State private var step: Step = .identity
    @Namespace private var heroNS
    @State private var showPaywall = false
    @State private var photoAuthStatus: PHAuthorizationStatus = .notDetermined
    @State private var scrubValue: Double = 0.4

    enum Step { case identity, permissions, demo, personalize }

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(hue: selectedAccentHue, saturation: 0.7, brightness: 0.9).opacity(0.20),
                .black.opacity(0.02)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)

            VStack(spacing: 24) {
                header
                content
                footer
            }
            .padding(20)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onPurchased: {
                hasCompletedOnboarding = true
            }, onDismiss: {
                hasCompletedOnboarding = true
            })
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "paintpalette")
                .font(.system(size: 24, weight: .bold))
                .matchedGeometryEffect(id: "brand", in: heroNS)
            Spacer()
            Capsule()
                .fill(Color(hue: selectedAccentHue, saturation: 0.8, brightness: 0.9).opacity(0.18))
                .frame(width: 44, height: 28)
                .overlay(
                    Capsule().stroke(Color(hue: selectedAccentHue, saturation: 0.9, brightness: 0.9).opacity(0.35), lineWidth: 1)
                )
                .matchedGeometryEffect(id: "accent", in: heroNS)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .identity:
            identity
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .permissions:
            permissions
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .demo:
            demo
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        case .personalize:
            personalize
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
        }
    }

    private var footer: some View {
        HStack {
            if step != .identity {
                Button("Back") { withSpring { previous() } }
                    .buttonStyle(.bordered)
            }
            Spacer()
            Button(step == .personalize ? "Continue" : "Next") {
                withSpring { next() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }

    private var identity: some View {
        VStack(spacing: 16) {
            Text("Create living color stories")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .matchedGeometryEffect(id: "headline", in: heroNS)
            Text("Import, favorite, and remix palettes that stay synced and export-ready.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .glassBackground(hue: selectedAccentHue)
        .onAppear {
            withSpring {}
        }
    }

    private var permissions: some View {
        VStack(spacing: 16) {
            Text("Use your photos to build palettes")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("We only scan locally to suggest colors. Request access when you’re ready.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Allow Photos Access") {
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        photoAuthStatus = status
                        withSpring { step = .demo }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .glassBackground(hue: selectedAccentHue)
    }

    private var demo: some View {
        VStack(spacing: 16) {
            Text("Try a quick color blend")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Scrub to morph the palette. It’s live, not a slideshow.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ColorStripScrubber(value: $scrubValue)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            LivePalettePreview(hue: selectedAccentHue, factor: scrubValue)
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(24)
        .glassBackground(hue: selectedAccentHue)
    }

    private var personalize: some View {
        VStack(spacing: 16) {
            Text("Pick your accent")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            Slider(value: $selectedAccentHue, in: 0...1)
            Text("This color breathes through the app—subtle, never distracting.")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Button("Skip") { withSpring { showPaywall = true } }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Unlock Pro") { withSpring { showPaywall = true } }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .glassBackground(hue: selectedAccentHue)
    }

    private func next() {
        switch step {
        case .identity: step = .permissions
        case .permissions: step = .demo
        case .demo: step = .personalize
        case .personalize: showPaywall = true
        }
    }

    private func previous() {
        switch step {
        case .identity: break
        case .permissions: step = .identity
        case .demo: step = .permissions
        case .personalize: step = .demo
        }
    }

    private func withSpring(_ block: () -> Void = {}) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0.1)) {
            block()
        }
    }
}

private struct LivePalettePreview: View {
    let hue: Double
    let factor: Double
    var body: some View {
        let colors = [
            Color(hue: hue, saturation: 0.8, brightness: 0.9),
            Color(hue: hue + factor * 0.08, saturation: 0.75, brightness: 0.92),
            Color(hue: hue - factor * 0.06, saturation: 0.7, brightness: 0.88)
        ]
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct ColorStripScrubber: View {
    @Binding var value: Double
    @GestureState private var drag: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let handleX = CGFloat(value) * (w - 28) + 14
            ZStack(alignment: .leading) {
                LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                    .offset(x: handleX - 14)
                    .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($drag) { value, state, _ in
                                state = value.translation.width
                            }
                            .onChanged { g in
                                let x = max(0, min(w, g.location.x))
                                self.value = min(1, max(0, x / w))
                            }
                    )
            }
        }
    }
}

private struct GlassBackground: ViewModifier {
    let hue: Double
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [
                        Color(hue: hue, saturation: 0.6, brightness: 1.0).opacity(0.14),
                        Color(hue: hue, saturation: 0.5, brightness: 1.0).opacity(0.06)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color(hue: hue, saturation: 0.8, brightness: 0.9).opacity(0.25), lineWidth: 1)
            )
    }
}

private extension View {
    func glassBackground(hue: Double) -> some View {
        modifier(GlassBackground(hue: hue))
    }
}
