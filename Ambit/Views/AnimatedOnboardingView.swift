import SwiftUI

struct AnimatedOnboardingView: View {
    @State private var step: Int = 0
    @State private var showPaletteDemo = false
    @State private var showGradientDemo = false
    @State private var showThemeDemo = false
    @State private var showFinish = false
    @State private var showTutorial = false
    var onContinue: (() -> Void)? = nil
    var onStartTutorial: (() -> Void)? = nil
    @State private var previewAnim = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            if showTutorial {
                InteractiveTutorialView(onFinish: { withAnimation { showTutorial = false } })
            } else {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)
                    Group {
                        if step == 0 {
                            OnboardingSlide(
                                title: "Welcome to Ambit",
                                description: "A professional color studio for iPhone. Let's walk through the essentials!",
                                image: "paintpalette.fill"
                            )
                            .transition(.opacity.combined(with: .scale))
                        } else if step == 1 {
                            OnboardingSlide(
                                title: "Import & Remix Colors",
                                description: "Tap to import images, favorite palettes, and remix color stories with a swipe.",
                                image: "photo"
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        } else if step == 2 {
                            OnboardingSlide(
                                title: "Create Gradients",
                                description: "Blend ramps, adjust angles, and save your favorite gradient systems.",
                                image: "aqi.medium"
                            )
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        } else if step == 3 {
                            OnboardingSlide(
                                title: "Curate Your Theme",
                                description: "Choose a studio theme to set the mood and accent for your workspace.",
                                image: "circle.lefthalf.filled"
                            )
                            .transition(.scale.combined(with: .opacity))
                        } else if step == 4 {
                            OnboardingSlide(
                                title: "Ready to Create!",
                                description: "You're all set. Tap below to start your color journey.",
                                image: "sparkles"
                            )
                            .transition(.opacity)
                        }
                    }
                    Spacer()
                    // Animated preview
                    OnboardingPreview(step: step)
                        .frame(height: 160)
                        .padding(.horizontal, 24)

                    HStack(spacing: 18) {
                        ForEach(0..<5) { idx in
                            Circle()
                                .fill(idx == step ? Color.accentColor : Color.secondary.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .animation(.spring(), value: step)
                        }
                    }
                    Spacer(minLength: 20)
                    HStack(spacing: 12) {
                        Button(action: { if step < 4 { step += 1 } else { onStartTutorial?() } }) {
                            Text(step < 4 ? "Next" : "Start Tutorial")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.accentColor.opacity(0.18)))
                        }
                        .buttonStyle(.plain)
                        Button(action: { onContinue?() }) {
                            Text("Skip")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .frame(height: 44)
                                .padding(.horizontal, 18)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.12), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)
                    Spacer(minLength: 40)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
            }
        }
    }

    // A small animated preview used by onboarding to illustrate key features
    @ViewBuilder
    private func OnboardingPreview(step: Int) -> some View {
        switch step {
        case 0:
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72).shadow(radius: 8)
                VStack(alignment: .leading) {
                    Text("Import photos instantly").font(.system(.subheadline, weight: .semibold))
                    Text("Tap to extract colors").font(.system(.caption)).foregroundColor(.secondary)
                }
                Spacer()
            }
            .onAppear { withAnimation(.spring()) { previewAnim.toggle() } }
        case 1:
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 120, height: 72).shadow(radius: 8)
                VStack(alignment: .leading) {
                    Text("Remix palettes").font(.system(.subheadline, weight: .semibold))
                    Text("Swipe and shuffle colors").font(.system(.caption)).foregroundColor(.secondary)
                }
                Spacer()
            }
            .offset(x: previewAnim ? 0 : 20)
            .onAppear { withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) { previewAnim.toggle() } }
        case 2:
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12).fill(AngularGradient(gradient: Gradient(colors: [.indigo, .teal, .mint]), center: .center))
                    .frame(width: 180, height: 72).shadow(radius: 8)
                VStack(alignment: .leading) {
                    Text("Create gradients").font(.system(.subheadline, weight: .semibold))
                    Text("Adjust angle and blend").font(.system(.caption)).foregroundColor(.secondary)
                }
                Spacer()
            }
            .rotationEffect(.degrees(previewAnim ? 6 : -6))
            .onAppear { withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { previewAnim.toggle() } }
        case 3:
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.06)))
                    .frame(width: 120, height: 72).shadow(radius: 8)
                VStack(alignment: .leading) {
                    Text("Studio themes").font(.system(.subheadline, weight: .semibold))
                    Text("Pick a mood for your workspace").font(.system(.caption)).foregroundColor(.secondary)
                }
                Spacer()
            }
            .scaleEffect(previewAnim ? 1.02 : 1.0)
            .onAppear { withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { previewAnim.toggle() } }
        default:
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 72).shadow(radius: 8)
                VStack(alignment: .leading) {
                    Text("You're all set").font(.system(.subheadline, weight: .semibold))
                    Text("Start creating with Ambit").font(.system(.caption)).foregroundColor(.secondary)
                }
                Spacer()
            }
            .opacity(previewAnim ? 1 : 0.6)
            .onAppear { withAnimation(.easeInOut(duration: 0.5)) { previewAnim = true } }
        }
    }

    private func nextStep() {
        if step < 4 {
            step += 1
        } else {
            showTutorial = true
        }
    }
}

struct OnboardingSlide: View {
    let title: String
    let description: String
    let image: String

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
        }
        .padding(.horizontal, 24)
    }
}
