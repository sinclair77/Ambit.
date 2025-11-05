//
//  GradientGenerator.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI

enum GradientGenerator {
    // MARK: - Gradient Creation

    static func createGradient(from colors: [UIColor], type: GradientType = .linear, angle: Double = 0) -> GradientComponents {
        guard !colors.isEmpty else {
            return GradientComponents(colors: [], locations: [], type: type, angle: angle)
        }

        // Ensure we have at least 2 colors for meaningful gradients
        let gradientColors = colors.count == 1 ? [colors[0], colors[0]] : colors

        // Calculate optimal color stops
        let locations = calculateOptimalLocations(for: gradientColors.count)

        return GradientComponents(
            colors: gradientColors,
            locations: locations,
            type: type,
            angle: angle
        )
    }

    private static func calculateOptimalLocations(for colorCount: Int) -> [Double] {
        guard colorCount > 1 else { return [0.0] }

        let locations: [Double]
        switch colorCount {
        case 2:
            locations = [0.0, 1.0]
        case 3:
            locations = [0.0, 0.5, 1.0]
        case 4:
            locations = [0.0, 0.33, 0.67, 1.0]
        case 5:
            locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        default:
            // For more colors, distribute evenly
            locations = (0..<colorCount).map { Double($0) / Double(colorCount - 1) }
        }

        return locations
    }

    // MARK: - Advanced Gradient Types

    static func createHarmonyGradient(baseColor: UIColor, harmonyType: HarmonyType, style: GradientStyle = .smooth) -> GradientComponents {
        let harmonyColors = ColorHarmonyGenerator.generateHarmony(for: baseColor, type: harmonyType)

        switch style {
        case .smooth:
            return createGradient(from: harmonyColors, type: .linear)
        case .stepped:
            return createSteppedGradient(from: harmonyColors)
        case .radial:
            return createGradient(from: harmonyColors, type: .radial)
        case .conic:
            return createGradient(from: harmonyColors, type: .conic)
        }
    }

    private static func createSteppedGradient(from colors: [UIColor]) -> GradientComponents {
        var steppedColors: [UIColor] = []
        var locations: [Double] = []

        for (index, color) in colors.enumerated() {
            // Create sharp transitions by duplicating colors at boundaries
            steppedColors.append(color)
            steppedColors.append(color)

            if index < colors.count - 1 {
                let location = Double(index + 1) / Double(colors.count)
                locations.append(location - 0.01)
                locations.append(location + 0.01)
            }
        }

        // Add start and end locations
        locations.insert(0.0, at: 0)
        locations.append(1.0)

        return GradientComponents(
            colors: steppedColors,
            locations: locations,
            type: .linear,
            angle: 0
        )
    }

    // MARK: - Gradient Analysis

    static func analyzeGradient(_ gradient: GradientComponents) -> GradientAnalysis {
        var analysis = GradientAnalysis()

        // Analyze color distribution
        analysis.colorCount = gradient.colors.count
        analysis.hasTransparency = gradient.colors.contains { (color: UIColor) in
            let alpha = color.rgbaComponents?.alpha ?? 255
            return alpha < 255
        }

        // Calculate contrast ratios
        if gradient.colors.count >= 2 {
            let ratios = calculateContrastRatios(in: gradient.colors)
            analysis.contrastRatios = ratios
            analysis.maxContrastRatio = ratios.max() ?? 1.0
            analysis.minContrastRatio = ratios.min() ?? 1.0
        }

        // Analyze harmony
        if gradient.colors.count >= 2 {
            let harmonyAnalysis = ColorHarmonyGenerator.analyzeHarmonyQuality(gradient.colors)
            analysis.harmonyScore = harmonyAnalysis.score
            analysis.harmonyStrengths = harmonyAnalysis.strengths
            analysis.harmonySuggestions = harmonyAnalysis.suggestions
        }

        // Analyze accessibility
        let accessibilityContext = AccessibilityContext(fontSize: 14, isBold: false)
        analysis.accessibilityIssues = ColorAccessibilityAnalyzer.generateAccessibilityRecommendations(
            for: gradient.colors,
            context: accessibilityContext
        )

        return analysis
    }

    private static func calculateContrastRatios(in colors: [UIColor]) -> [Double] {
        var ratios: [Double] = []

        for i in 0..<colors.count {
            for j in (i+1)..<colors.count {
                let ratio = ColorAccessibilityAnalyzer.calculateContrastRatio(colors[i], colors[j])
                ratios.append(ratio)
            }
        }

        return ratios.sorted(by: >)
    }

    // MARK: - Gradient Optimization

    static func optimizeGradient(_ gradient: GradientComponents, for purpose: GradientPurpose) -> GradientComponents {
        var optimizedColors = gradient.colors
        var optimizedLocations = gradient.locations

        switch purpose {
        case .uiBackground:
            // For UI backgrounds, ensure good contrast and readability
            optimizedColors = ensureMinimumContrast(colors: gradient.colors, minRatio: 1.5)
            optimizedLocations = redistributeLocations(for: optimizedColors.count, style: .balanced)

        case .textOverlay:
            // For text overlays, ensure high contrast
            optimizedColors = ensureMinimumContrast(colors: gradient.colors, minRatio: 4.5)
            optimizedLocations = redistributeLocations(for: optimizedColors.count, style: .balanced)

        case .accent:
            // For accents, maintain vibrancy while ensuring visibility
            optimizedColors = enhanceVibrancy(colors: gradient.colors)
            optimizedLocations = redistributeLocations(for: optimizedColors.count, style: .centered)

        case .artistic:
            // For artistic purposes, preserve original intent
            return gradient
        }

        return GradientComponents(
            colors: optimizedColors,
            locations: optimizedLocations,
            type: gradient.type,
            angle: gradient.angle
        )
    }

    private static func ensureMinimumContrast(colors: [UIColor], minRatio: Double) -> [UIColor] {
        guard colors.count >= 2 else { return colors }

        var adjustedColors = colors

        // Check contrast between adjacent colors
        for i in 0..<adjustedColors.count - 1 {
            let ratio = ColorAccessibilityAnalyzer.calculateContrastRatio(adjustedColors[i], adjustedColors[i + 1])

            if ratio < minRatio {
                // Adjust the darker color to increase contrast
                let color1 = adjustedColors[i]
                let color2 = adjustedColors[i + 1]

                let lum1 = color1.relativeLuminance
                let lum2 = color2.relativeLuminance

                if lum1 > lum2 {
                    // Make color2 darker
                    adjustedColors[i + 1] = adjustBrightness(color2, factor: 0.7)
                } else {
                    // Make color2 lighter
                    adjustedColors[i + 1] = adjustBrightness(color2, factor: 1.3)
                }
            }
        }

        return adjustedColors
    }

    private static func adjustBrightness(_ color: UIColor, factor: Double) -> UIColor {
        guard let hsl = color.hslComponents else { return color }

        let newBrightness = min(1.0, max(0.0, hsl.brightness * factor))
        return UIColor(hue: hsl.hue / 360.0,
                      saturation: hsl.saturation,
                      brightness: newBrightness,
                      alpha: 1.0)
    }

    private static func enhanceVibrancy(colors: [UIColor]) -> [UIColor] {
        return colors.map { color in
            guard let hsl = color.hslComponents else { return color }

            // Increase saturation while maintaining brightness
            let newSaturation = min(1.0, hsl.saturation * 1.2)
            return UIColor(hue: hsl.hue / 360.0,
                          saturation: newSaturation,
                          brightness: hsl.brightness,
                          alpha: 1.0)
        }
    }

    private static func redistributeLocations(for colorCount: Int, style: LocationStyle) -> [Double] {
        guard colorCount > 1 else { return [0.0] }

        switch style {
        case .balanced:
            return (0..<colorCount).map { Double($0) / Double(colorCount - 1) }
        case .centered:
            let center = 0.5
            let spread = 0.8
            let start = center - spread / 2
            let end = center + spread / 2
            return (0..<colorCount).map { start + (end - start) * Double($0) / Double(colorCount - 1) }
        case .edges:
            return (0..<colorCount).map { Double($0) / Double(colorCount - 1) * 0.8 + 0.1 }
        }
    }

    // MARK: - Gradient Variations

    static func generateVariations(of gradient: GradientComponents, count: Int = 3) -> [GradientComponents] {
        var variations: [GradientComponents] = []

        for _ in 0..<count {
            var variedColors: [UIColor] = []
            var variedLocations = gradient.locations

            // Slightly vary each color
            for color in gradient.colors {
                guard let hsl = color.hslComponents else {
                    variedColors.append(color)
                    continue
                }

                // Random variations within reasonable bounds
                let hueVariation = Double.random(in: -10...10)
                let saturationVariation = Double.random(in: -0.1...0.1)
                let brightnessVariation = Double.random(in: -0.1...0.1)

                let newHue = (hsl.hue + hueVariation).truncatingRemainder(dividingBy: 360.0)
                let newSaturation = min(1.0, max(0.0, hsl.saturation + saturationVariation))
                let newBrightness = min(1.0, max(0.0, hsl.brightness + brightnessVariation))

                let variedColor = UIColor(hue: newHue / 360.0,
                                        saturation: newSaturation,
                                        brightness: newBrightness,
                                        alpha: 1.0)
                variedColors.append(variedColor)
            }

            // Slightly vary locations
            variedLocations = variedLocations.map { location in
                let variation = Double.random(in: -0.05...0.05)
                return min(1.0, max(0.0, location + variation))
            }

            variations.append(GradientComponents(
                colors: variedColors,
                locations: variedLocations,
                type: gradient.type,
                angle: gradient.angle
            ))
        }

        return variations
    }
}

// MARK: - Supporting Types

struct GradientComponents {
    let colors: [UIColor]
    let locations: [Double]
    let type: GradientType
    let angle: Double

    var swiftUIGradient: Gradient {
        let colorStops = zip(colors, locations).map { color, location in
            Gradient.Stop(color: Color(color), location: location)
        }
        return Gradient(stops: colorStops)
    }
}

enum GradientType {
    case linear
    case radial
    case conic
}

enum GradientStyle {
    case smooth
    case stepped
    case radial
    case conic
}

enum GradientPurpose {
    case uiBackground
    case textOverlay
    case accent
    case artistic
}

enum LocationStyle {
    case balanced
    case centered
    case edges
}

struct GradientAnalysis {
    var colorCount: Int = 0
    var hasTransparency: Bool = false
    var contrastRatios: [Double] = []
    var maxContrastRatio: Double = 1.0
    var minContrastRatio: Double = 1.0
    var harmonyScore: Double = 0.0
    var harmonyStrengths: [String] = []
    var harmonySuggestions: [String] = []
    var accessibilityIssues: [AccessibilityRecommendation] = []

    var overallQuality: String {
        let harmonyWeight = 0.4
        let contrastWeight = 0.3
        let accessibilityWeight = 0.3

        let harmonyScore = min(100.0, self.harmonyScore) / 100.0
        let contrastScore = min(100.0, maxContrastRatio * 10.0) / 100.0 // Normalize contrast
        let accessibilityScore = accessibilityIssues.isEmpty ? 1.0 : max(0.0, 1.0 - Double(accessibilityIssues.count) * 0.2)

        let totalScore = harmonyScore * harmonyWeight + contrastScore * contrastWeight + accessibilityScore * accessibilityWeight

        switch totalScore {
        case 0.8...1.0: return "Excellent"
        case 0.6..<0.8: return "Good"
        case 0.4..<0.6: return "Fair"
        case 0.2..<0.4: return "Poor"
        default: return "Needs Improvement"
        }
    }
}
