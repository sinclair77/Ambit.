import SwiftUI
import UIKit

fileprivate struct VisualEffectBlur: UIViewRepresentable {
    let blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(.headline, design: .monospaced, weight: .bold))
                NoHyphenationLabel(text: subtitle, font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular), color: UIColor.secondaryLabel)
            }
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(uiColor: .secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.primary.opacity(0.05), lineWidth: 1))
    }
}

private struct ThemePreviewButton: View {
    let mode: AmbitAppearanceMode
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.accentColor.opacity(0.6) : Color.primary.opacity(0.08), lineWidth: 1.5)
                    )
                    .frame(height: 72)

                Image(systemName: mode.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.accentColor)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("selectedAccentHue") private var selectedAccentHue: Double = 0.55
    private var hapticsBinding: Binding<Bool> { Binding(get: { viewModel.hapticsEnabled }, set: { viewModel.updateHaptics($0) }) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) { themeCard; feedbackCard; aboutCard }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
            }
            .navigationTitle("Settings")
        }
    }

    private var themeCard: some View {
        SettingsCard(
            title: "Appearance",
            subtitle: "Choose between light and dark. Accent color comes from your onboarding selection."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(viewModel.appearanceModes, id: \.self) { mode in
                        ThemePreviewButton(mode: mode, isSelected: mode == viewModel.appearanceMode) {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                                viewModel.updateAppearance(mode)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    AccentSettingsHueStrip(hue: $selectedAccentHue)
                        .frame(height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    HStack(spacing: 10) {
                        Slider(value: $selectedAccentHue, in: 0...1)
                        Circle()
                            .fill(Color(hue: selectedAccentHue, saturation: 0.8, brightness: 0.95))
                            .frame(width: 22, height: 22)
                            .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                    }
                }
            }
        }
    }

    private var feedbackCard: some View {
        SettingsCard(title: "Feedback", subtitle: "Haptics add gentle cues throughout the experience.") {
            Toggle("Enable Haptics", isOn: hapticsBinding)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
    }

    private var aboutCard: some View {
        SettingsCard(title: "About Ambit", subtitle: "Professional color studio for iPhone.") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient(colors: [.accentColor.opacity(0.22), .accentColor.opacity(0.1)],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
                            .frame(width: 56, height: 56)
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ambit v1.0")
                            .font(.system(.headline, design: .monospaced, weight: .bold))
                        NoHyphenationLabel(
                            text: "Built for color teams shipping world-class visuals.",
                            font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                            color: UIColor.secondaryLabel
                        )
                    }
                }
                Divider().background(Color.primary.opacity(0.1))
                VStack(alignment: .leading, spacing: 8) {
                    Link(destination: URL(string: "https://example.com/support")!) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Support & Help")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.system(.body, design: .monospaced, weight: .medium))
                        .foregroundColor(.accentColor)
                    }
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.system(.body, design: .monospaced, weight: .medium))
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}

private struct AccentSettingsHueStrip: View {
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

                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: geo.size.height + 4)
                    .offset(x: markerX - 1)
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
