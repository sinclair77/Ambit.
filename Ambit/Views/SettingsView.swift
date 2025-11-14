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
            let bg = LinearGradient(colors: mode.previewGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(bg).frame(height: 84)
                    .overlay(VisualEffectBlur(blurStyle: .systemUltraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isSelected ? mode.accentColor.opacity(0.45) : Color.primary.opacity(0.06), lineWidth: 1.5))

                HStack(spacing: 14) {
                    ZStack { Circle().fill(mode.accentColor.opacity(0.22)).frame(width: 44, height: 44); Image(systemName: mode.icon).font(.system(size: 20, weight: .bold)).foregroundColor(.white) }
                    VStack(alignment: .leading, spacing: 4) {
                        NoHyphenationLabel(text: mode.label, font: UIFont.systemFont(ofSize: 16, weight: .semibold), color: UIColor.label)
                        NoHyphenationLabel(text: mode.description, font: UIFont.systemFont(ofSize: 12, weight: .regular), color: UIColor.secondaryLabel).lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.seal.fill" : "circle").font(.system(size: 20, weight: .semibold)).foregroundColor(isSelected ? mode.accentColor : .primary.opacity(0.22))
                }
                .padding(.horizontal, 14)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
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

    private var themeCard: some View { SettingsCard(title: "Studio Themes", subtitle: "Select a curated ambiance that pairs background, accent, and typography.") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 16)], spacing: 14) { ForEach(viewModel.appearanceModes, id: \.self) { mode in ThemePreviewButton(mode: mode, isSelected: mode == viewModel.appearanceMode) { withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) { viewModel.updateAppearance(mode) } } } }
    } }

    private var feedbackCard: some View { SettingsCard(title: "Feedback", subtitle: "Haptics add gentle cues throughout the experience.") { Toggle("Enable Haptics", isOn: hapticsBinding).toggleStyle(SwitchToggleStyle(tint: viewModel.appearanceMode.accentColor)) } }

    private var aboutCard: some View { SettingsCard(title: "About Ambit", subtitle: "Professional color studio for iPhone.") {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack { RoundedRectangle(cornerRadius: 14, style: .continuous).fill(LinearGradient(colors: [viewModel.appearanceMode.accentColor.opacity(0.22), viewModel.appearanceMode.accentColor.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 56, height: 56); Image(systemName: "paintpalette.fill").font(.system(size: 24, weight: .semibold)).foregroundColor(viewModel.appearanceMode.accentColor) }
                VStack(alignment: .leading, spacing: 4) { Text("Ambit v1.0").font(.system(.headline, design: .monospaced, weight: .bold)); NoHyphenationLabel(text: "Built for color teams shipping world-class visuals.", font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular), color: UIColor.secondaryLabel) }
            }
            Divider().background(Color.primary.opacity(0.1))
            VStack(alignment: .leading, spacing: 8) { Link(destination: URL(string: "https://example.com/support")!) { HStack { Image(systemName: "questionmark.circle"); Text("Support & Help"); Spacer(); Image(systemName: "arrow.up.right") }.font(.system(.body, design: .monospaced, weight: .medium)).foregroundColor(viewModel.appearanceMode.accentColor) }
                Link(destination: URL(string: "https://example.com/privacy")!) { HStack { Image(systemName: "hand.raised"); Text("Privacy Policy"); Spacer(); Image(systemName: "arrow.up.right") }.font(.system(.body, design: .monospaced, weight: .medium)).foregroundColor(viewModel.appearanceMode.accentColor) } }
        }
    } }
}
