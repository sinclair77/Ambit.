import SwiftUI
import UIKit

struct GlassBackground: View {
    var tint: Color = .accentColor
    var intensity: Double = 0.14
    var cornerRadius: CGFloat = 0
    var strokeOpacity: Double = 0.12
    var addNoise: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    tint.opacity(intensity * 1.2),
                    tint.opacity(intensity * 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(.ultraThinMaterial)

            if addNoise {
                NoiseOverlay()
                    .blendMode(.overlay)
                    .opacity(0.05)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(tint.opacity(strokeOpacity), lineWidth: 1)
        )
    }
}

private struct NoiseOverlay: View {
    @State private var seed: CGFloat = .random(in: 0...1)

    var body: some View {
        Rectangle()
            .fill(
                ImagePaint(image: noiseImage(seed: seed), scale: 1)
            )
            .onAppear { seed = .random(in: 0...1) }
    }

    private func noiseImage(seed: CGFloat) -> Image {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        let ui = renderer.image { ctx in
            let context = ctx.cgContext
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            let count = 500
            for _ in 0..<count {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let alpha = CGFloat.random(in: 0.02...0.06)
                context.setFillColor(UIColor.white.withAlphaComponent(alpha).cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        return Image(uiImage: ui)
    }
}

extension View {
    func glassContainer(cornerRadius: CGFloat = 24, tint: Color = .accentColor, intensity: Double = 0.14, strokeOpacity: Double = 0.12) -> some View {
        self
            .background(
                GlassBackground(tint: tint, intensity: intensity, cornerRadius: cornerRadius, strokeOpacity: strokeOpacity)
            )
    }
}
