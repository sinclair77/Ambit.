//
//  ColorPaletteGenerator.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI

enum ColorPaletteGenerator {
    // MARK: - Palette Generation

    static func generatePalette(from image: UIImage, style: PaletteStyle = .adaptive, count: Int = 5) -> ColorPalette {
        // Primary extraction with confidence scoring
        var (extractedColors, confidence) = ColorExtractor.extractProminentColorsWithConfidence(from: image, count: max(count, 8), avoidDark: true)

        // If low confidence, attempt alternative extraction strategies before falling back
        if confidence < 0.35 {
            // Try allowing darker colors (useful for logos or night scenes)
            let alt = ColorExtractor.extractProminentColorsWithConfidence(from: image, count: max(count, 8), avoidDark: false)
            if alt.confidence > confidence {
                extractedColors = alt.colors
                confidence = alt.confidence
            }
        }

        switch style {
        case .adaptive:
            return createAdaptivePalette(from: extractedColors, targetCount: count)
        case .harmonic:
            return createHarmonicPalette(from: extractedColors, targetCount: count)
        case .monochromatic:
            return createMonochromaticPalette(from: extractedColors, targetCount: count)
        case .complementary:
            return createComplementaryPalette(from: extractedColors, targetCount: count)
        case .triadic:
            return createTriadicPalette(from: extractedColors, targetCount: count)
        case .analogous:
            return createAnalogousPalette(from: extractedColors, targetCount: count)
        }
    }

    // MARK: - Palette Styles

    private static func createAdaptivePalette(from colors: [UIColor], targetCount: Int) -> ColorPalette {
        // Sort colors by perceptual prominence and select the best ones
        let sortedColors = sortColorsByProminence(colors)
        let selectedColors = Array(sortedColors.prefix(targetCount))

        return ColorPalette(
            colors: selectedColors,
            name: "Adaptive Palette",
            style: .adaptive,
            source: .image
        )
    }

    private static func createHarmonicPalette(from colors: [UIColor], targetCount: Int) -> ColorPalette {
        guard let baseColor = colors.first else {
            return ColorPalette(colors: [], name: "Empty Palette", style: .harmonic, source: .generated)
        }

        // Analyze the extracted colors to determine the best harmony type
        let harmonyType = determineBestHarmony(for: colors)
        let harmonyColors = ColorHarmonyGenerator.generateHarmony(for: baseColor, type: harmonyType)

        // Combine extracted colors with harmony colors for a balanced palette
        let combinedColors = (colors + harmonyColors).unique()
        let sortedColors = sortColorsByProminence(combinedColors)
        let selectedColors = Array(sortedColors.prefix(targetCount))

        return ColorPalette(
            colors: selectedColors,
            name: "\(harmonyType.rawValue) Palette",
            style: .harmonic,
            source: .image
        )
    }

    private static func createMonochromaticPalette(from colors: [UIColor], targetCount: Int) -> ColorPalette {
        guard let baseColor = colors.first else {
            return ColorPalette(colors: [], name: "Empty Palette", style: .monochromatic, source: .generated)
        }

        let monoColors = ColorHarmonyGenerator.generateHarmony(for: baseColor, type: .monochromatic)

        return ColorPalette(
            colors: Array(monoColors.prefix(targetCount)),
            name: "Monochromatic Palette",
            style: .monochromatic,
            source: .generated
        )
    }

    private static func createComplementaryPalette(from colors: [UIColor], targetCount: Int) -> ColorPalette {
        guard let baseColor = colors.first else {
            return ColorPalette(colors: [], name: "Empty Palette", style: .complementary, source: .generated)
        }

        let compColors = ColorHarmonyGenerator.generateHarmony(for: baseColor, type: .complementary)

        // Add variations for more colors if needed
        var finalColors = compColors
        if targetCount > compColors.count {
            let variations = ColorHarmonyGenerator.generateAdvancedHarmony(for: baseColor, type: .complementary, variations: targetCount - compColors.count)
            finalColors += variations.flatMap { $0 }
        }

        return ColorPalette(
            colors: Array(finalColors.prefix(targetCount)),
            name: "Complementary Palette",
            style: .complementary,
            source: .generated
        )
    }

    private static func createTriadicPalette(from colors: [UIColor], targetCount: Int) -> ColorPalette {
        guard let baseColor = colors.first else {
            return ColorPalette(colors: [], name: "Empty Palette", style: .triadic, source: .generated)
        }

        let triadicColors = ColorHarmonyGenerator.generateHarmony(for: baseColor, type: .triadic)

        return ColorPalette(
            colors: Array(triadicColors.prefix(targetCount)),
            name: "Triadic Palette",
            style: .triadic,
            source: .generated
        )
    }

    private static func createAnalogousPalette(from colors: [UIColor], targetCount: Int) -> ColorPalette {
        guard let baseColor = colors.first else {
            return ColorPalette(colors: [], name: "Empty Palette", style: .analogous, source: .generated)
        }

        let analogousColors = ColorHarmonyGenerator.generateHarmony(for: baseColor, type: .analogous)

        return ColorPalette(
            colors: Array(analogousColors.prefix(targetCount)),
            name: "Analogous Palette",
            style: .analogous,
            source: .generated
        )
    }

    // MARK: - Helper Methods

    private static func sortColorsByProminence(_ colors: [UIColor]) -> [UIColor] {
        // Sort by a combination of saturation, brightness, and perceptual weight
        return colors.sorted { color1, color2 in
            guard let hsl1 = color1.hslComponents, let hsl2 = color2.hslComponents else {
                return false
            }

            // Calculate prominence score (higher is more prominent)
            let score1 = hsl1.saturation * 0.4 + hsl1.brightness * 0.4 + (1.0 - abs(hsl1.brightness - 0.5) * 2) * 0.2
            let score2 = hsl2.saturation * 0.4 + hsl2.brightness * 0.4 + (1.0 - abs(hsl2.brightness - 0.5) * 2) * 0.2

            return score1 > score2
        }
    }

    private static func determineBestHarmony(for colors: [UIColor]) -> HarmonyType {
        // Analyze color distribution to suggest the best harmony
        guard colors.count >= 2 else { return .complementary }

        // Simple heuristic: if colors are spread out, suggest complementary
        // If clustered, suggest analogous
        let hues = colors.compactMap { $0.hslComponents?.hue }.sorted()
        let hueRange = hues.last! - hues.first!

        if hueRange > 180 {
            return .complementary
        } else if hueRange > 90 {
            return .triadic
        } else {
            return .analogous
        }
    }

    // MARK: - Palette Analysis

    static func analyzePalette(_ palette: ColorPalette) -> PaletteAnalysis {
        var analysis = PaletteAnalysis()

        analysis.colorCount = palette.colors.count

        // Analyze harmony
        if palette.colors.count >= 2 {
            let harmonyAnalysis = ColorHarmonyGenerator.analyzeHarmonyQuality(palette.colors)
            analysis.harmonyScore = harmonyAnalysis.score
            analysis.harmonyStrengths = harmonyAnalysis.strengths
            analysis.harmonySuggestions = harmonyAnalysis.suggestions
        }

        // Analyze contrast
        if palette.colors.count >= 2 {
            let contrastRatios = calculatePaletteContrastRatios(palette.colors)
            analysis.contrastRatios = contrastRatios
            analysis.maxContrastRatio = contrastRatios.max() ?? 1.0
            analysis.minContrastRatio = contrastRatios.min() ?? 1.0
        }

        // Analyze accessibility
        let accessibilityContext = AccessibilityContext(fontSize: 14, isBold: false)
        analysis.accessibilityIssues = ColorAccessibilityAnalyzer.generateAccessibilityRecommendations(
            for: palette.colors,
            context: accessibilityContext
        )

        // Analyze color properties
        analysis.hasWarmColors = palette.colors.contains { $0.isWarm }
        analysis.hasCoolColors = palette.colors.contains { $0.isCool }
        analysis.hasNeutralColors = palette.colors.contains { $0.isNeutral }

        let brightnesses = palette.colors.compactMap { $0.hslComponents?.brightness }
        analysis.averageBrightness = brightnesses.reduce(0, +) / Double(brightnesses.count)

        let saturations = palette.colors.compactMap { $0.hslComponents?.saturation }
        analysis.averageSaturation = saturations.reduce(0, +) / Double(saturations.count)

        return analysis
    }

    private static func calculatePaletteContrastRatios(_ colors: [UIColor]) -> [Double] {
        var ratios: [Double] = []

        for i in 0..<colors.count {
            for j in (i+1)..<colors.count {
                let ratio = ColorAccessibilityAnalyzer.calculateContrastRatio(colors[i], colors[j])
                ratios.append(ratio)
            }
        }

        return ratios.sorted(by: >)
    }

    // MARK: - Palette Optimization

    static func optimizePalette(_ palette: ColorPalette, for purpose: PalettePurpose) -> ColorPalette {
        var optimizedColors = palette.colors

        switch purpose {
        case .ui:
            // For UI, ensure good contrast and readability
            optimizedColors = ensurePaletteContrast(colors: palette.colors, minRatio: 3.0)
            optimizedColors = balancePaletteBrightness(colors: optimizedColors)

        case .branding:
            // For branding, maintain strong identity while ensuring versatility
            optimizedColors = enhancePaletteVibrancy(colors: palette.colors)
            optimizedColors = ensurePaletteUniqueness(colors: optimizedColors)

        case .artistic:
            // For artistic purposes, preserve creative intent
            return palette

        case .accessible:
            // For accessibility, prioritize contrast and color blindness considerations
            optimizedColors = ensurePaletteContrast(colors: palette.colors, minRatio: 4.5)
            optimizedColors = optimizeForColorBlindness(colors: optimizedColors)
        }

        return ColorPalette(
            colors: optimizedColors,
            name: "\(palette.name) (Optimized)",
            style: palette.style,
            source: .optimized
        )
    }

    private static func ensurePaletteContrast(colors: [UIColor], minRatio: Double) -> [UIColor] {
        var adjustedColors = colors

        // Ensure minimum contrast between all color pairs
        for i in 0..<adjustedColors.count {
            for j in (i+1)..<adjustedColors.count {
                let ratio = ColorAccessibilityAnalyzer.calculateContrastRatio(adjustedColors[i], adjustedColors[j])

                if ratio < minRatio {
                    // Adjust the less saturated color to increase contrast
                    let color1 = adjustedColors[i]
                    let color2 = adjustedColors[j]

                    guard let hsl1 = color1.hslComponents, let hsl2 = color2.hslComponents else { continue }

                    if hsl1.saturation < hsl2.saturation {
                        adjustedColors[i] = adjustColorSaturation(color1, factor: 1.2)
                    } else {
                        adjustedColors[j] = adjustColorSaturation(color2, factor: 1.2)
                    }
                }
            }
        }

        return adjustedColors
    }

    private static func balancePaletteBrightness(colors: [UIColor]) -> [UIColor] {
        let brightnesses = colors.compactMap { $0.hslComponents?.brightness }
        guard let minBrightness = brightnesses.min(),
              let maxBrightness = brightnesses.max() else { return colors }

        // Ensure good brightness range
        let desiredRange = 0.6
        if maxBrightness - minBrightness < desiredRange {
            return adjustBrightnessRange(colors: colors, targetRange: desiredRange)
        }

        return colors
    }

    private static func adjustBrightnessRange(colors: [UIColor], targetRange: Double) -> [UIColor] {
        var adjustedColors = colors
        let brightnesses = colors.compactMap { $0.hslComponents?.brightness }
        let currentMin = brightnesses.min()!
        let currentMax = brightnesses.max()!

        for i in 0..<adjustedColors.count {
            guard let hsl = adjustedColors[i].hslComponents else { continue }

            let normalizedBrightness = (hsl.brightness - currentMin) / (currentMax - currentMin)
            let newBrightness = normalizedBrightness * targetRange + (1.0 - targetRange) / 2.0

            adjustedColors[i] = UIColor(hue: hsl.hue / 360.0,
                                      saturation: hsl.saturation,
                                      brightness: min(1.0, max(0.0, newBrightness)),
                                      alpha: 1.0)
        }

        return adjustedColors
    }

    private static func enhancePaletteVibrancy(colors: [UIColor]) -> [UIColor] {
        return colors.map { color in
            guard let hsl = color.hslComponents else { return color }

            let newSaturation = min(1.0, hsl.saturation * 1.1)
            let newBrightness = min(1.0, hsl.brightness * 1.05)

            return UIColor(hue: hsl.hue / 360.0,
                          saturation: newSaturation,
                          brightness: newBrightness,
                          alpha: 1.0)
        }
    }

    private static func ensurePaletteUniqueness(colors: [UIColor]) -> [UIColor] {
        var uniqueColors = [UIColor]()

        for color in colors {
            // Check if this color is too similar to existing ones
            let isUnique = uniqueColors.allSatisfy { existingColor in
                let distance = ColorAccessibilityAnalyzer.calculateContrastRatio(color, existingColor)
                return distance > 2.0 // Minimum contrast ratio for uniqueness
            }

            if isUnique || uniqueColors.isEmpty {
                uniqueColors.append(color)
            }
        }

        return uniqueColors
    }

    private static func optimizeForColorBlindness(colors: [UIColor]) -> [UIColor] {
        // Ensure colors are distinguishable for common color vision deficiencies
        var optimizedColors = colors

        for i in 0..<optimizedColors.count {
            for j in (i+1)..<optimizedColors.count {
                // Check if colors are confusable for color blind users
                let analyses = ColorVisionSimulator.analyzeColorConfusion(for: optimizedColors[i], visionTypes: [.deuteranopia, .protanopia])

                let hasSevereConfusion = analyses.contains { $0.confusionSeverity == .severe }

                if hasSevereConfusion {
                    // Adjust one of the colors to reduce confusion
                    optimizedColors[j] = adjustColorForVisibility(optimizedColors[j])
                }
            }
        }

        return optimizedColors
    }

    private static func adjustColorSaturation(_ color: UIColor, factor: Double) -> UIColor {
        guard let hsl = color.hslComponents else { return color }

        let newSaturation = min(1.0, max(0.0, hsl.saturation * factor))
        return UIColor(hue: hsl.hue / 360.0,
                      saturation: newSaturation,
                      brightness: hsl.brightness,
                      alpha: 1.0)
    }

    private static func adjustColorForVisibility(_ color: UIColor) -> UIColor {
        guard let hsl = color.hslComponents else { return color }

        // Increase saturation and adjust brightness for better visibility
        let newSaturation = min(1.0, hsl.saturation * 1.3)
        let newBrightness = hsl.brightness < 0.5 ? min(1.0, hsl.brightness * 1.2) : max(0.0, hsl.brightness * 0.9)

        return UIColor(hue: hsl.hue / 360.0,
                      saturation: newSaturation,
                      brightness: newBrightness,
                      alpha: 1.0)
    }
}

// MARK: - Supporting Types

struct ColorPalette {
    let colors: [UIColor]
    let name: String
    let style: PaletteStyle
    let source: PaletteSource

    var swiftUIColors: [Color] {
        colors.map { Color($0) }
    }
}

enum PaletteStyle: String {
    case adaptive = "Adaptive"
    case harmonic = "Harmonic"
    case monochromatic = "Monochromatic"
    case complementary = "Complementary"
    case triadic = "Triadic"
    case analogous = "Analogous"
}

enum PaletteSource {
    case image
    case generated
    case optimized
}

enum PalettePurpose {
    case ui
    case branding
    case artistic
    case accessible
}

struct PaletteAnalysis {
    var colorCount: Int = 0
    var harmonyScore: Double = 0.0
    var harmonyStrengths: [String] = []
    var harmonySuggestions: [String] = []
    var contrastRatios: [Double] = []
    var maxContrastRatio: Double = 1.0
    var minContrastRatio: Double = 1.0
    var accessibilityIssues: [AccessibilityRecommendation] = []
    var hasWarmColors: Bool = false
    var hasCoolColors: Bool = false
    var hasNeutralColors: Bool = false
    var averageBrightness: Double = 0.0
    var averageSaturation: Double = 0.0

    var overallQuality: String {
        let harmonyWeight = 0.3
        let contrastWeight = 0.3
        let accessibilityWeight = 0.4

        let harmonyScore = min(100.0, self.harmonyScore) / 100.0
        let contrastScore = min(1.0, maxContrastRatio / 7.0) // Normalize to WCAG AAA max
        let accessibilityScore = accessibilityIssues.isEmpty ? 1.0 : max(0.0, 1.0 - Double(accessibilityIssues.count) * 0.15)

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

// MARK: - Array Extensions

extension Array where Element == UIColor {
    func unique() -> [UIColor] {
        var uniqueColors: [UIColor] = []

        for color in self {
            let isUnique = uniqueColors.allSatisfy { existingColor in
                // Consider colors unique if they have meaningful difference
                let distance = ColorAccessibilityAnalyzer.calculateContrastRatio(color, existingColor)
                return distance > 1.2 // Very low threshold for uniqueness in this context
            }

            if isUnique {
                uniqueColors.append(color)
            }
        }

        return uniqueColors
    }
}