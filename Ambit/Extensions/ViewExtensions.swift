//
//  ViewExtensions.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import SwiftUI
import UIKit

// MARK: - Environment Keys

private struct AmbitAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .accentColor
}

private struct AmbitTextPrimaryKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

private struct AmbitTextSecondaryKey: EnvironmentKey {
    static let defaultValue: Color = .secondary
}

extension EnvironmentValues {
    var ambitAccentColor: Color {
        get { self[AmbitAccentColorKey.self] }
        set { self[AmbitAccentColorKey.self] = newValue }
    }
    
    var ambitTextPrimary: Color {
        get { self[AmbitTextPrimaryKey.self] }
        set { self[AmbitTextPrimaryKey.self] = newValue }
    }
    
    var ambitTextSecondary: Color {
        get { self[AmbitTextSecondaryKey.self] }
        set { self[AmbitTextSecondaryKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    // MARK: - Conditional Modifiers

    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        Group {
            if condition {
                transform(self)
            } else {
                self
            }
        }
    }

    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if transform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        Group {
            if condition {
                transform(self)
            } else {
                elseTransform(self)
            }
        }
    }

    // MARK: - Loading States

    func loadingOverlay(isLoading: Bool, text: String = "Loading...") -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(text)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(32)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(16)
                }
            }
        }
    }

    // MARK: - Error States

    func errorOverlay(error: Error?, retryAction: (() -> Void)? = nil) -> some View {
        self.overlay {
            if let error = error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    if let retryAction = retryAction {
                        Button("Retry", action: retryAction)
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding(32)
                .background(Color(.systemBackground).opacity(0.95))
                .cornerRadius(16)
                .shadow(radius: 10)
            }
        }
    }

    // MARK: - Accessibility

    func customAccessibilityLabel(_ label: String, hint: String? = nil) -> some View {
        Group {
            if let hint = hint {
                self.accessibilityLabel(label)
                    .accessibilityHint(hint)
            } else {
                self.accessibilityLabel(label)
            }
        }
    }

    // MARK: - Animation Helpers

    func animateOnAppear(animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        self.modifier(AnimateOnAppearModifier(animation: animation))
    }

    func animateOnChange<V: Equatable>(of value: V, animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        self.modifier(AnimateOnChangeModifier(value: value, animation: animation))
    }

    // MARK: - Haptic Feedback

    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle, trigger: Bool = true) -> some View {
        self.modifier(HapticFeedbackModifier(style: style, trigger: trigger))
    }

    // MARK: - Custom Shadows

    func customShadow(color: Color = .black, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.shadow(color: color.opacity(0.2), radius: radius, x: x, y: y)
    }

    // MARK: - Gradient Backgrounds

    func gradientBackground(colors: [Color], startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }

    // MARK: - Rounded Corners with Specific Corners

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }

    // MARK: - Conditional Opacity

    func opacity(_ opacity: Double, when condition: Bool) -> some View {
        self.opacity(condition ? opacity : 1.0)
    }

    // MARK: - Debug Helpers

    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        self.border(color, width: width)
    }

    func debugBackground(_ color: Color = .yellow.opacity(0.3)) -> some View {
        self.background(color)
    }
}

// MARK: - Supporting Views and Modifiers

struct RoundedCornerShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct AnimateOnAppearModifier: ViewModifier {
    let animation: Animation

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.8)
            .onAppear {
                withAnimation(animation) {
                    isVisible = true
                }
            }
    }
}

struct AnimateOnChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    let animation: Animation

    @State private var oldValue: V?

    func body(content: Content) -> some View {
        content
            .opacity(oldValue == value ? 1 : 0.7)
            .scaleEffect(oldValue == value ? 1 : 0.95)
            .onChange(of: value) { _, newValue in
                withAnimation(animation) {
                    oldValue = newValue
                }
            }
            .onAppear {
                oldValue = value
            }
    }
}

struct HapticFeedbackModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    let trigger: Bool

    @State private var generator: UIImpactFeedbackGenerator?

    func body(content: Content) -> some View {
        content
            .onAppear {
                generator = UIImpactFeedbackGenerator(style: style)
                generator?.prepare()
            }
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    generator?.impactOccurred()
                }
            }
    }
}

// MARK: - Color Extensions for SwiftUI

extension Color {
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }

    func lighter(by percentage: Double = 0.2) -> Color {
        Color(UIColor(self).adjustedBrightness(by: 1.0 + percentage))
    }

    func darker(by percentage: Double = 0.2) -> Color {
        Color(UIColor(self).adjustedBrightness(by: 1.0 - percentage))
    }

    func saturated(by percentage: Double = 0.2) -> Color {
        Color(UIColor(self).adjustedSaturation(by: 1.0 + percentage))
    }

    func desaturated(by percentage: Double = 0.2) -> Color {
        Color(UIColor(self).adjustedSaturation(by: 1.0 - percentage))
    }
}

// MARK: - Text Extensions

extension Text {
    func foregroundGradient(colors: [Color], startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: startPoint,
                endPoint: endPoint
            )
            .mask(self)
        )
    }
}

// MARK: - Image Extensions

extension Image {
    func iconStyle(size: CGFloat = 24, color: Color = .primary) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}

// MARK: - Button Style Extensions

extension Button {
    func customButtonStyle(backgroundColor: Color = .blue, foregroundColor: Color = .white, cornerRadius: CGFloat = 8) -> some View {
        self.buttonStyle(CustomButtonStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor, cornerRadius: cornerRadius))
    }
}

struct CustomButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .foregroundColor(foregroundColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Environment Extensions

extension EnvironmentValues {
    var customAccentColor: Color {
        get { self[CustomAccentColorKey.self] }
        set { self[CustomAccentColorKey.self] = newValue }
    }
    
    var ambitTheme: AmbitAppearanceMode {
        get { self[AmbitThemeKey.self] }
        set { self[AmbitThemeKey.self] = newValue }
    }
}

private struct CustomAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue
}

private struct AmbitThemeKey: EnvironmentKey {
    static let defaultValue: AmbitAppearanceMode = .studio
}

// MARK: - View Modifier for Custom Environment

extension View {
    func customAccentColor(_ color: Color) -> some View {
        self.environment(\.customAccentColor, color)
    }
}
