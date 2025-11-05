//
//  ColorHarmonyGenerator.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI

enum ColorHarmonyGenerator {
    // MARK: - Harmony Generation

    static func generateHarmony(for baseColor: UIColor, type: HarmonyType) -> [UIColor] {
        switch type {
        case .complementary:
            return generateComplementary(baseColor)
        case .analogous:
            return generateAnalogous(baseColor)
        case .triadic:
            return generateTriadic(baseColor)
        case .tetradic:
            return generateTetradic(baseColor)
        case .splitComplementary:
            return generateSplitComplementary(baseColor)
        case .monochromatic:
            return generateMonochromatic(baseColor)
        case .square:
            return generateSquare(baseColor)
        }
    }

    // MARK: - Individual Harmony Types

    private static func generateComplementary(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        let complementaryHue = (hsl.hue + 180.0).truncatingRemainder(dividingBy: 360.0)
        let complementaryColor = UIColor(hue: complementaryHue / 360.0,
                                       saturation: hsl.saturation,
                                       brightness: hsl.brightness,
                                       alpha: 1.0)

        return [baseColor, complementaryColor]
    }

    private static func generateAnalogous(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        var colors: [UIColor] = []

        // Generate 5 analogous colors (base ± 2 × 30°)
        for i in -2...2 {
            let hue = (hsl.hue + Double(i) * 30.0).truncatingRemainder(dividingBy: 360.0)
            let color = UIColor(hue: hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: hsl.brightness,
                              alpha: 1.0)
            colors.append(color)
        }

        return colors
    }

    private static func generateTriadic(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        var colors: [UIColor] = [baseColor]

        // Generate triadic colors (120° and 240° apart)
        for i in 1...2 {
            let hue = (hsl.hue + Double(i) * 120.0).truncatingRemainder(dividingBy: 360.0)
            let color = UIColor(hue: hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: hsl.brightness,
                              alpha: 1.0)
            colors.append(color)
        }

        return colors
    }

    private static func generateTetradic(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        var colors: [UIColor] = [baseColor]

        // Generate tetradic colors (90° apart, but typically shown as square)
        for i in 1...3 {
            let hue = (hsl.hue + Double(i) * 90.0).truncatingRemainder(dividingBy: 360.0)
            let color = UIColor(hue: hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: hsl.brightness,
                              alpha: 1.0)
            colors.append(color)
        }

        return colors
    }

    private static func generateSplitComplementary(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        var colors: [UIColor] = [baseColor]

        // Generate split complementary (complementary ± 30°)
        let complementaryHue = (hsl.hue + 180.0).truncatingRemainder(dividingBy: 360.0)

        for i in [-1, 1] {
            let hue = (complementaryHue + Double(i) * 30.0).truncatingRemainder(dividingBy: 360.0)
            let color = UIColor(hue: hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: hsl.brightness,
                              alpha: 1.0)
            colors.append(color)
        }

        return colors
    }

    private static func generateMonochromatic(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        var colors: [UIColor] = []

        // Generate 5 monochromatic colors with varying brightness
        let brightnessSteps: [CGFloat] = [0.2, 0.4, 0.6, 0.8, 1.0]

        for brightness in brightnessSteps {
            let color = UIColor(hue: hsl.hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: brightness,
                              alpha: 1.0)
            colors.append(color)
        }

        return colors
    }

    private static func generateSquare(_ baseColor: UIColor) -> [UIColor] {
        guard let hsl = baseColor.hslComponents else { return [baseColor] }

        var colors: [UIColor] = [baseColor]

        // Generate square harmony (90° apart)
        for i in 1...3 {
            let hue = (hsl.hue + Double(i) * 90.0).truncatingRemainder(dividingBy: 360.0)
            let color = UIColor(hue: hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: hsl.brightness,
                              alpha: 1.0)
            colors.append(color)
        }

        return colors
    }

    // MARK: - Advanced Harmony Features

    static func generateAdvancedHarmony(for baseColor: UIColor, type: HarmonyType, variations: Int = 3) -> [[UIColor]] {
        let baseHarmony = generateHarmony(for: baseColor, type: type)

        guard variations > 1 else { return [baseHarmony] }

        var harmonies: [[UIColor]] = [baseHarmony]

        // Generate variations by slightly adjusting saturation and brightness
        for variation in 1..<variations {
            let factor = Double(variation) / Double(variations)
            var variedColors: [UIColor] = []

            for color in baseHarmony {
                guard let hsl = color.hslComponents else {
                    variedColors.append(color)
                    continue
                }

                // Vary saturation and brightness slightly
                let saturationVariation = hsl.saturation * (0.8 + factor * 0.4) // 0.8 to 1.2
                let brightnessVariation = hsl.brightness * (0.9 + factor * 0.2) // 0.9 to 1.1

                let variedColor = UIColor(hue: hsl.hue / 360.0,
                                        saturation: min(1.0, max(0.0, saturationVariation)),
                                        brightness: min(1.0, max(0.0, brightnessVariation)),
                                        alpha: 1.0)
                variedColors.append(variedColor)
            }

            harmonies.append(variedColors)
        }

        return harmonies
    }

    // MARK: - Harmony Analysis

    static func analyzeHarmonyQuality(_ colors: [UIColor]) -> HarmonyAnalysis {
        guard colors.count >= 2 else {
            return HarmonyAnalysis(score: 0.0, strengths: [], suggestions: ["Need at least 2 colors for harmony analysis"])
        }

        var totalScore = 0.0
        var strengths: [String] = []
        var suggestions: [String] = []

        // Convert colors to HSL for analysis
        let hslColors = colors.compactMap { $0.hslComponents }

        // Analyze hue relationships
        let hueScore = analyzeHueRelationships(hslColors)
        totalScore += hueScore.score
        strengths.append(contentsOf: hueScore.strengths)
        suggestions.append(contentsOf: hueScore.suggestions)

        // Analyze saturation balance
        let saturationScore = analyzeSaturationBalance(hslColors)
        totalScore += saturationScore.score
        strengths.append(contentsOf: saturationScore.strengths)
        suggestions.append(contentsOf: saturationScore.suggestions)

        // Analyze brightness balance
        let brightnessScore = analyzeBrightnessBalance(hslColors)
        totalScore += brightnessScore.score
        strengths.append(contentsOf: brightnessScore.strengths)
        suggestions.append(contentsOf: brightnessScore.suggestions)

        // Normalize total score
        let normalizedScore = min(100.0, max(0.0, totalScore / 3.0))

        return HarmonyAnalysis(score: normalizedScore, strengths: strengths, suggestions: suggestions)
    }

    private static func analyzeHueRelationships(_ hslColors: [HSLComponents]) -> (score: Double, strengths: [String], suggestions: [String]) {
        var score = 0.0
        var strengths: [String] = []
        var suggestions: [String] = []

        let hues = hslColors.map { $0.hue }.sorted()

        // Check for complementary relationships (180° apart)
        var complementaryCount = 0
        for i in 0..<hues.count {
            for j in (i+1)..<hues.count {
                let diff = abs(hues[j] - hues[i])
                let minDiff = min(diff, 360 - diff)
                if minDiff >= 170 && minDiff <= 190 {
                    complementaryCount += 1
                }
            }
        }

        if complementaryCount > 0 {
            score += 30.0
            strengths.append("Good complementary relationships found")
        }

        // Check for triadic relationships (120° apart)
        var triadicCount = 0
        for i in 0..<hues.count {
            for j in (i+1)..<hues.count {
                let diff = abs(hues[j] - hues[i])
                let minDiff = min(diff, 360 - diff)
                if minDiff >= 110 && minDiff <= 130 {
                    triadicCount += 1
                }
            }
        }

        if triadicCount > 0 {
            score += 25.0
            strengths.append("Triadic harmony detected")
        }

        // Check for analogous relationships (30° apart)
        var analogousCount = 0
        for i in 0..<hues.count {
            for j in (i+1)..<hues.count {
                let diff = abs(hues[j] - hues[i])
                let minDiff = min(diff, 360 - diff)
                if minDiff >= 20 && minDiff <= 40 {
                    analogousCount += 1
                }
            }
        }

        if analogousCount > 0 {
            score += 20.0
            strengths.append("Analogous colors work well together")
        }

        // Check for hue clustering (too similar)
        let hueRange = hues.last! - hues.first!
        if hueRange < 30 {
            score -= 15.0
            suggestions.append("Colors are too similar - consider adding more variety")
        }

        return (score, strengths, suggestions)
    }

    private static func analyzeSaturationBalance(_ hslColors: [HSLComponents]) -> (score: Double, strengths: [String], suggestions: [String]) {
        var score = 0.0
        var strengths: [String] = []
        var suggestions: [String] = []

        let saturations = hslColors.map { $0.saturation }
        let avgSaturation = saturations.reduce(0, +) / Double(saturations.count)
        let saturationVariance = saturations.map { pow($0 - avgSaturation, 2) }.reduce(0, +) / Double(saturations.count)

        // Good balance if variance is moderate
        if saturationVariance > 0.01 && saturationVariance < 0.1 {
            score += 20.0
            strengths.append("Good saturation balance")
        } else if saturationVariance < 0.01 {
            score -= 10.0
            suggestions.append("Saturation is too uniform - consider varying saturation levels")
        }

        return (score, strengths, suggestions)
    }

    private static func analyzeBrightnessBalance(_ hslColors: [HSLComponents]) -> (score: Double, strengths: [String], suggestions: [String]) {
        var score = 0.0
        var strengths: [String] = []
        var suggestions: [String] = []

        let brightnesses = hslColors.map { $0.brightness }
        let avgBrightness = brightnesses.reduce(0, +) / Double(brightnesses.count)
        let brightnessVariance = brightnesses.map { pow($0 - avgBrightness, 2) }.reduce(0, +) / Double(brightnesses.count)

        // Good balance if variance is moderate
        if brightnessVariance > 0.01 && brightnessVariance < 0.1 {
            score += 20.0
            strengths.append("Good brightness balance")
        } else if brightnessVariance < 0.01 {
            score -= 10.0
            suggestions.append("Brightness is too uniform - consider varying brightness levels")
        }

        // Check for good contrast range
        let brightnessRange = brightnesses.max()! - brightnesses.min()!
        if brightnessRange > 0.5 {
            score += 15.0
            strengths.append("Good contrast range")
        } else if brightnessRange < 0.2 {
            suggestions.append("Low contrast - consider adding darker and lighter shades")
        }

        return (score, strengths, suggestions)
    }
}

// MARK: - Supporting Types

struct HarmonyAnalysis {
    let score: Double // 0-100
    let strengths: [String]
    let suggestions: [String]

    var grade: String {
        switch score {
        case 90...100: return "Excellent"
        case 80..<90: return "Very Good"
        case 70..<80: return "Good"
        case 60..<70: return "Fair"
        case 0..<60: return "Needs Improvement"
        default: return "Unknown"
        }
    }
}