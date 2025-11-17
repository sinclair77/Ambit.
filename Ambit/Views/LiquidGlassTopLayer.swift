import SwiftUI

struct LiquidGlassTopLayer: View {
    var tint: Color = .accentColor
    var height: CGFloat = 110
    var cornerRadius: CGFloat = 22
    var intensity: Double = 0.12
    var strokeOpacity: Double = 0.12
    var addNoise: Bool = true

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            VStack(spacing: 0) {
                ZStack {
                    // Primary glass band
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(colors: [tint.opacity(intensity * 1.6), tint.opacity(intensity * 0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(tint.opacity(strokeOpacity), lineWidth: 1)
                        )

                    // Liquid blobs for shape & depth
                    HStack(spacing: -40) {
                        Circle().fill(tint.opacity(0.10)).frame(width: height * 0.9, height: height * 0.9).offset(x: -width * 0.22, y: -8)
                        Circle().fill(tint.opacity(0.08)).frame(width: height * 1.0, height: height * 1.0).offset(x: 0, y: -18)
                        Circle().fill(tint.opacity(0.06)).frame(width: height * 0.85, height: height * 0.85).offset(x: width * 0.18, y: -12)
                    }
                    .blendMode(.overlay)
                    .blur(radius: 8)
                    .allowsHitTesting(false)

                    // Gloss highlight
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(colors: [Color.white.opacity(0.18), Color.white.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                        )
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).frame(height: height))
                        .frame(height: height * 0.38)
                        .offset(y: -height * 0.28)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)

                    // Subtle noise
                    if addNoise {
                        GlassNoiseOverlay(
                            scale: 1,
                            opacity: 0.03
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .frame(height: height)
                        .allowsHitTesting(false)
                    }
                }
                Spacer(minLength: 0)
            }
            .allowsHitTesting(false)
            .edgesIgnoringSafeArea(.top)
        }
        .frame(height: height)
    }
}

private struct GlassNoiseOverlay: View {
    var scale: CGFloat = 1
    var opacity: Double = 0.05
    @State private var seed: CGFloat = .random(in: 0...1)

    var body: some View {
        Rectangle()
            .fill(ImagePaint(image: noiseImage(seed: seed), scale: scale))
            .opacity(opacity)
            .onAppear { seed = .random(in: 0...1) }
    }

    private func noiseImage(seed: CGFloat) -> Image {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        let ui = renderer.image { ctx in
            let context = ctx.cgContext
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            let count = 350
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
    func liquidGlassTopLayer(tint: Color = .accentColor, height: CGFloat = 110) -> some View {
        self.overlay(LiquidGlassTopLayer(tint: tint, height: height), alignment: .top)
    }
}
