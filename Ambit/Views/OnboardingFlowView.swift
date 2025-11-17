import SwiftUI
import PhotosUI

struct OnboardingFlowView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasUnlockedPro") private var hasUnlockedPro = false
    @AppStorage("selectedAccentHue") private var selectedAccentHue: Double = 0.55
    @State private var step: Step = .identity
    @Namespace private var heroNS
    @State private var showPaywall = false
    @State private var photoAuthStatus: PHAuthorizationStatus = .notDetermined
    @State private var scrubValue: Double = 0.4
    @State private var hasConfirmedAccent = false
    @State private var showAccentStudio = false

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
            PaywallView(
                onPurchased: {
                    hasUnlockedPro = true
                    hasCompletedOnboarding = true
                },
                onDismiss: {
                    hasCompletedOnboarding = true
                }
            )
        }
        .sheet(isPresented: $showAccentStudio) {
            AccentStudioView(hue: $selectedAccentHue) {
                withSpring { hasConfirmedAccent = true }
                HapticManager.instance.impact(style: .soft)
            }
        }
        .onChange(of: selectedAccentHue) { _, _ in
            if hasConfirmedAccent {
                hasConfirmedAccent = false
            }
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
            .disabled(step == .personalize && !hasConfirmedAccent)
            .opacity(step == .personalize && !hasConfirmedAccent ? 0.6 : 1)
        }
        .padding(.top, 8)
    }

    private var identity: some View {
        VStack(spacing: 18) {
            Text("Create living color stories")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .matchedGeometryEffect(id: "headline", in: heroNS)

            Text("Turn photos into smart palettes, blend gradients, design cards, and keep every color story in your Ambit library.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "sparkles", title: "Analyzer", detail: "Import an image, sample colors with a dropper, and save palettes.")
                FeatureRow(icon: "paintpalette", title: "Palettes and Gradients", detail: "Edit swatches, reorder stops, and export for your design tools.")
                FeatureRow(icon: "square.stack.3d.up", title: "Cards and Library", detail: "Build showcase cards and keep all saved work organized.")
            }
        }
        .padding(24)
        .onboardingGlassBackground(hue: selectedAccentHue)
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
    .onboardingGlassBackground(hue: selectedAccentHue)
    }

    private var demo: some View {
        VStack(spacing: 16) {
            Text("See Ambit in motion")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Scrub to morph the palette. The same engine powers Analyzer, Gradients, and cards in the app.")
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
    .onboardingGlassBackground(hue: selectedAccentHue)
    }

    private var personalize: some View {
        VStack(spacing: 16) {
            Text("Pick your accent")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 12) {
                // Visual hue strip showing exactly where the user is
                AccentHueStrip(hue: $selectedAccentHue)
                    .frame(height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack(spacing: 12) {
                    Slider(value: $selectedAccentHue, in: 0...1)
                    Button {
                        showAccentStudio = true
                    } label: {
                        Image(systemName: "eyedropper.halffull")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hue: selectedAccentHue, saturation: 0.8, brightness: 0.95))
                        .frame(width: 22, height: 22)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                    Text("#" + Color(hue: selectedAccentHue, saturation: 0.8, brightness: 0.95).toHex(includeAlpha: false).dropFirst())
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        withSpring { hasConfirmedAccent = true }
                        HapticManager.instance.impact(style: .soft)
                    } label: {
                        Label(hasConfirmedAccent ? "Confirmed" : "Confirm accent", systemImage: hasConfirmedAccent ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                    .tint(Color(hue: selectedAccentHue, saturation: 0.8, brightness: 0.9))
                }
            }
            Text("This color breathes through Analyzer, Palettes, Gradients, Cards, and Library—subtle, never distracting.")
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
    .onboardingGlassBackground(hue: selectedAccentHue)
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

private struct OnboardingGlassModifier: ViewModifier {
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
    func onboardingGlassBackground(hue: Double) -> some View {
        modifier(OnboardingGlassModifier(hue: hue))
    }
}

private struct AccentHueStrip: View {
    @Binding var hue: Double

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let markerX = CGFloat(hue) * width

            ZStack(alignment: .leading) {
                LinearGradient(
                    gradient: Gradient(colors: stride(from: 0.0, through: 1.0, by: 0.05).map {
                        Color(hue: $0, saturation: 0.9, brightness: 1.0)
                    }),
                    startPoint: .leading,
                    endPoint: .trailing
                )

                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: geo.size.height + 4)
                    .offset(x: markerX - 1)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = max(0, min(width, value.location.x))
                        hue = Double(x / width)
                    }
            )
        }
    }
}

private struct AccentStudioView: View {
    @Binding var hue: Double
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: hue, saturation: 0.75, brightness: 1.0),
                                    Color(hue: hue, saturation: 0.85, brightness: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 18, y: 10)

                    VStack(spacing: 8) {
                        Text("Ambit.")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .italic()
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.5), radius: 10, y: 6)

                        Text("Preview accent tone")
                            .font(.system(.footnote, design: .rounded, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding()
                }
                .frame(height: 190)

                AccentHueStrip(hue: $hue)
                    .frame(height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Slider(value: $hue, in: 0...1)

                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hue: hue, saturation: 0.8, brightness: 0.95))
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected accent")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(Color(hue: hue, saturation: 0.8, brightness: 0.95).toHex(includeAlpha: false))
                            .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                    }

                    Spacer()
                }

                Spacer()

                Button {
                    onConfirm()
                    dismiss()
                } label: {
                    Label("Use this accent", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .navigationTitle("Accent Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 26, height: 26)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                Text(detail)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
