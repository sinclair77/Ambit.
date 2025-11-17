import SwiftUI

struct InteractiveTutorialView: View {
    @State private var step: Int = 0
    @State private var showFinish = false
    var onFinish: (() -> Void)? = nil
    // Demo state
    @State private var demoImage: UIImage = ImageDemo.generateGradientImage(colors: [UIColor.systemPink, UIColor.systemBlue, UIColor.systemIndigo])
    @State private var demoPalette: [UIColor] = [UIColor.systemPink, UIColor.systemPurple, UIColor.systemOrange, UIColor.systemTeal]
    @State private var gradientAngle: Double = 0
    @State private var selectedThemeAccent: Color = .accentColor
    @State private var paletteSlideIn = false
    @State private var autoShuffle = false
    @State private var autoAnimatingAngle = false
    @State private var themePulse = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 32) {
                HStack {
                    if step > 0 {
                        Button(action: { withAnimation { step = max(step - 1, 0) } }) {
                            Image(systemName: "chevron.left")
                                .padding(8)
                                .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    Button(action: { onFinish?() }) {
                        Text("Skip")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 40)
                Group {
                    if step == 0 {
                        TutorialStep(
                            title: "Import a Photo",
                            description: "Tap the import button below to bring in a photo and extract its colors.",
                            image: "photo",
                            actionLabel: "Import Photo",
                            action: {
                                // simulate import by extracting colors from demo image
                                Task {
                                    let colors = await ColorExtractor.extractRandomColors(from: demoImage, count: 6, avoidDark: false)
                                    await MainActor.run {
                                        withAnimation { demoPalette = colors }
                                        nextStep()
                                    }
                                }
                            }
                        )
                    } else if step == 1 {
                        TutorialStep(
                            title: "Remix Your Palette",
                            description: "Swipe left or right to remix the palette. Try favoriting your favorite blend!",
                            image: "paintpalette.fill",
                            actionLabel: "Remix Palette",
                            action: {
                                // remix palette with a small shuffle animation
                                withAnimation(.spring()) {
                                    demoPalette.shuffle()
                                }
                                nextStep()
                            }
                        )
                    } else if step == 2 {
                        TutorialStep(
                            title: "Create a Gradient",
                            description: "Tap below to generate a gradient and adjust its angle interactively.",
                            image: "aqi.medium",
                            actionLabel: "Create Gradient",
                            action: {
                                nextStep()
                            }
                        )
                    } else if step == 3 {
                        TutorialStep(
                            title: "Set Your Theme",
                            description: "Pick a studio theme to change the mood and accent colors.",
                            image: "circle.lefthalf.filled",
                            actionLabel: "Choose Theme",
                            action: {
                                // show theme change in preview
                                withAnimation(.spring()) {
                                    selectedThemeAccent = [Color.blue, Color.green, Color.pink, Color.purple].randomElement() ?? .accentColor
                                }
                                nextStep()
                            }
                        )
                    } else if step == 4 {
                        TutorialStep(
                            title: "You're Ready!",
                            description: "You've completed the interactive tutorial. Start creating!",
                            image: "sparkles",
                            actionLabel: "Finish",
                            action: {
                                showFinish = true
                                onFinish?()
                            }
                        )
                    }
                }
                Spacer()
                // Demo area
                DemoContent(step: step, demoImage: $demoImage, demoPalette: $demoPalette, gradientAngle: $gradientAngle, selectedTheme: selectedThemeAccent, autoShuffle: autoShuffle, themePulse: themePulse)
                HStack(spacing: 18) {
                    ForEach(0..<5) { idx in
                        Circle()
                            .fill(idx == step ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .animation(.spring(), value: step)
                    }
                }
                Spacer(minLength: 20)
            }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
                .onChange(of: step) { _oldStep, newStep in
                    // Reset animations
                    paletteSlideIn = false
                    autoShuffle = false
                    autoAnimatingAngle = false
                    themePulse = false
                    switch newStep {
                    case 0:
                        paletteSlideIn = true
                    case 1:
                        autoShuffle = true
                    case 2:
                        autoAnimatingAngle = true
                        Task.detached { await animateGradientAngle() }
                    case 3:
                        themePulse = true
                    default:
                        break
                    }
                }
        }
    }

    private func animateGradientAngle() async {
        // Simple looped animation of the angle while the step is active
        while autoAnimatingAngle && step == 2 {
            for target in stride(from: 0.0, to: 360.0, by: 10.0) {
                await MainActor.run {
                    withAnimation(.linear(duration: 0.05)) { gradientAngle = target }
                }
                try? await Task.sleep(nanoseconds: 30_000_000) // 30ms
            }
        }
    }

    private func nextStep() {
        if step < 4 {
            step += 1
        } else {
            showFinish = true
            // TODO: Dismiss tutorial and show main app
        }
    }
}

struct TutorialStep: View {
    let title: String
    let description: String
    let image: String
    let actionLabel: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: image)
                .font(.system(size: 54, weight: .bold))
                .foregroundColor(.accentColor)
                .shadow(radius: 8)
            Text(title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            NoHyphenationLabel(
                text: description,
                font: UIFont.systemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .multilineTextAlignment(.center)
            Button(action: action) {
                Text(actionLabel)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.accentColor.opacity(0.18)))
                    .shadow(color: Color.accentColor.opacity(0.08), radius: 8)
                    .scaleEffect(1.0)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)
        }
        .padding(.horizontal, 24)
    }
}

fileprivate struct ImageDemo {
    static func generateGradientImage(colors: [UIColor], size: CGSize = CGSize(width: 1200, height: 800)) -> UIImage {
        let cgColors = colors.map { $0.cgColor }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let context = ctx.cgContext
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors as CFArray, locations: nil)!
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
        }
    }
}

fileprivate struct DemoContent: View {
    let step: Int
    @Binding var demoImage: UIImage
    @Binding var demoPalette: [UIColor]
    @Binding var gradientAngle: Double
    let selectedTheme: Color
    let autoShuffle: Bool
    let themePulse: Bool

    var body: some View {
        switch step {
        case 0:
            return AnyView(ImportDemoView(image: demoImage, palette: demoPalette))
        case 1:
            return AnyView(RemixDemoView(palette: $demoPalette, autoShuffle: autoShuffle))
        case 2:
            return AnyView(GradientDemoView(angle: $gradientAngle, palette: demoPalette))
        case 3:
            return AnyView(ThemeDemoView(accent: selectedTheme, pulse: themePulse))
        default:
            return AnyView(FinishDemoView())
        }
    }
}

fileprivate struct ImportDemoView: View {
    let image: UIImage
    let palette: [UIColor]
    @State private var slideIn: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 220, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 6)

            HStack(spacing: 8) {
                ForEach(palette.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: palette[i]))
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                        .offset(x: slideIn ? 0 : 50)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 18).delay(Double(i) * 0.03), value: slideIn)
                }
            }
            .frame(height: 56)
            .onAppear { slideIn = true }
        }
        .frame(height: 200)
        .padding(.horizontal, 40)
    }
}

fileprivate struct RemixDemoView: View {
    @Binding var palette: [UIColor]
    var autoShuffle: Bool = false

    @State private var spin: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(palette.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: palette[i]))
                        .frame(width: 52, height: 52)
                        .shadow(radius: 4)
                        .scaleEffect(spin ? 1.03 : 0.98)
                        .onTapGesture { withAnimation(.spring()) { palette.shuffle() } }
                }
            }
            Text("Tap a swatch to remix")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)
        }
            .onAppear {
            if autoShuffle {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { spin.toggle() }
            }
        }
            .onChange(of: autoShuffle) { _oldValue, value in
            if value {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { spin.toggle() }
            } else {
                spin = false
            }
        }
        .frame(height: 200)
        .padding(.horizontal, 40)
    }
}

fileprivate struct GradientDemoView: View {
    @Binding var angle: Double
    let palette: [UIColor]

    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: palette.map { Color(uiColor: $0) }, startPoint: .leading, endPoint: .trailing))
                .frame(height: 120)
                .rotationEffect(.degrees(angle))
                .shadow(radius: 6)

            Slider(value: $angle, in: 0...360, step: 1) {
                Text("Angle")
            }
            .padding(.horizontal, 40)
        }
        .frame(height: 200)
    }
}

fileprivate struct ThemeDemoView: View {
    let accent: Color
    var pulse: Bool = false
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accent)
                        .frame(width: 56, height: 56)
                        .shadow(radius: 4)
                        .scaleEffect(pulse ? 1.02 : 1.0)
                }
            }
            Text("Tap to change studio theme")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .padding(.horizontal, 40)
    }
}

fileprivate struct FinishDemoView: View {
    var body: some View {
        VStack {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.accentColor)
            NoHyphenationLabel(
                text: "You're ready — let's create",
                font: UIFont.systemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
        }
        .frame(height: 200)
    }
}

fileprivate struct PaletteStripDemoView: View {
    let colors: [UIColor]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(colors.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: colors[i]))
                    .frame(width: 44, height: 44)
                    .shadow(radius: 2)
            }
        }
    }
}
