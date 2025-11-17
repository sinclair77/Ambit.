import SwiftUI

struct PaywallView: View {
    let onPurchased: () -> Void
    let onDismiss: () -> Void
    @State private var expanded = true
    @State private var tryHighRes = false
    @State private var selectedPlan: Plan = .monthly

    enum Plan: String, CaseIterable, Identifiable {
        case monthly
        case lifetime
        var id: String { rawValue }

        var title: String {
            switch self {
            case .monthly: return "$3.99 / month"
            case .lifetime: return "$25.00 one‑time"
            }
        }

        var subtitle: String {
            switch self {
            case .monthly: return "Cancel anytime from Settings."
            case .lifetime: return "Own the full studio forever."
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Pro Kit")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose your plan")
                        .font(.system(.headline, design: .rounded))

                    Picker("", selection: $selectedPlan) {
                        Text("Monthly").tag(Plan.monthly)
                        Text("Lifetime").tag(Plan.lifetime)
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedPlan.title)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        Text(selectedPlan.subtitle)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                DisclosureGroup(isExpanded: $expanded) {
                    VStack(alignment: .leading, spacing: 12) {
                        benefit("Unlimited exports")
                        benefit("Advanced blending")
                        benefit("Priority sync & backup")
                        benefit("Early access features")
                    }
                    .padding(.top, 8)
                } label: {
                    Text("What you get")
                        .font(.system(.headline, design: .rounded))
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Try it on")
                            .font(.system(.headline, design: .rounded))
                        Spacer()
                        Toggle("High‑res", isOn: $tryHighRes)
                            .labelsHidden()
                    }
                    demoPreview(highRes: tryHighRes)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))

                VStack(spacing: 10) {
                    Button {
                        // Mock purchase: instantly unlock for now.
                        onPurchased()
                    } label: {
                        Text(selectedPlan == .monthly ? "Continue with Monthly" : "Continue with Lifetime")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Maybe later", action: onDismiss)
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private func benefit(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill").foregroundColor(.accentColor)
            Text(text)
        }
        .font(.system(.body, design: .rounded))
    }

    private func demoPreview(highRes: Bool) -> some View {
        let detail: CGFloat = highRes ? 24 : 12
        return ZStack {
            LinearGradient(colors: [.purple.opacity(0.25), .mint.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Grid(horizontalSpacing: detail, verticalSpacing: detail) {
                ForEach(0..<Int(detail), id: \ .self) { _ in
                    GridRow {
                        ForEach(0..<Int(detail), id: \ .self) { _ in
                            Circle().fill(.white.opacity(0.12)).frame(width: 6, height: 6)
                        }
                    }
                }
            }
        }
    }
}
