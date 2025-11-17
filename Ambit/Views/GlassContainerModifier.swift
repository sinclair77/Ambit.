import SwiftUI

private struct GlassContainerModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color
    let intensity: Double
    let strokeOpacity: Double
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        // Subtle tint wash for brand cohesion
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(colors: [
                                    tint.opacity(intensity),
                                    tint.opacity(intensity * 0.6)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .blendMode(.plusLighter)
                    )
                    .overlay(
                        // Soft inner highlight
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .overlay(
                        // Outer hairline for definition
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.primary.opacity(strokeOpacity), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, y: shadowYOffset)
    }
}

public extension View {
    func glassContainer(
        cornerRadius: CGFloat = 20,
        tint: Color = .accentColor,
        intensity: Double = 0.15,
        strokeOpacity: Double = 0.18,
        shadowOpacity: Double = 0.08,
        shadowRadius: CGFloat = 12,
        shadowYOffset: CGFloat = 6
    ) -> some View {
        modifier(GlassContainerModifier(
            cornerRadius: cornerRadius,
            tint: tint,
            intensity: intensity,
            strokeOpacity: strokeOpacity,
            shadowOpacity: shadowOpacity,
            shadowRadius: shadowRadius,
            shadowYOffset: shadowYOffset
        ))
    }
}
