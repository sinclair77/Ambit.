import SwiftUI

struct PaywallView: View {
    let onPurchased: () -> Void
    let onDismiss: () -> Void
    @State private var expanded = true
    @State private var tryHighRes = false
    @State private var selectedPlan: Plan = .weekly
    @StateObject private var store = StoreKitManager.shared

    enum Plan: String, CaseIterable, Identifiable {
        case weekly
        case monthly
        var id: String { rawValue }

        // These display strings are intentionally explicit per your request. In production prefer localized price strings from StoreKit.
        var title: String {
            switch self {
            case .weekly: return "$1.99 / week"
            case .monthly: return "$10.00 / month"
            }
        }

        var subtitle: String {
            switch self {
            case .weekly: return "Billed weekly. Cancel anytime from Settings."
            case .monthly: return "Billed monthly. Cancel anytime from Settings."
            }
        }

        // Map to your App Store Connect product identifiers (replace with real ids)
        var productId: String {
            switch self {
                case .weekly: return StoreConfig.weeklySubscription
                case .monthly: return StoreConfig.monthlySubscription
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
                        Text("Weekly").tag(Plan.weekly)
                        Text("Monthly").tag(Plan.monthly)
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(selectedPlan.title)
                            if let storePrice = store.displayPrice(for: selectedPlan.productId) {
                                Text("(" + storePrice + ")")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
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
                        // Attempt real purchase via StoreKitManager
                        Task {
                            let success = await store.purchase(productId: selectedPlan.productId)
                            if success {
                                onPurchased()
                            } else {
                                // fallback: dismiss
                                onDismiss()
                            }
                        }
                    } label: {
                        Text(selectedPlan == .monthly ? "Continue with Monthly" : "Continue with Weekly")
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
