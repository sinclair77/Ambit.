import SwiftUI

struct PaywallView: View {
    let onPurchased: () -> Void
    let onDismiss: () -> Void
    @State private var expanded = true
    @State private var tryHighRes = false
    @StateObject private var store = StoreKitManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Pro Kit")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

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
                        Task {
                            let ok = await store.purchasePro()
                            if ok { onPurchased() }
                        }
                    } label: {
                        Text(store.displayPrice ?? "Continue")
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
