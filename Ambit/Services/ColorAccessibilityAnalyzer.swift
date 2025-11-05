//
//  ColorAccessibilityAnalyzer.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI

enum ColorAccessibilityAnalyzer {
    // MARK: - WCAG Compliance Analysis

    static func analyzeContrast(textColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat = 14.0, isBold: Bool = false) -> ContrastAnalysis {
        let ratio = calculateContrastRatio(textColor, backgroundColor)
        let levelAA = meetsWCAGLevelAA(ratio: ratio, fontSize: fontSize, isBold: isBold)
        let levelAAA = meetsWCAGLevelAAA(ratio: ratio, fontSize: fontSize, isBold: isBold)

        var recommendations: [String] = []

        if !levelAA.normal && !levelAA.large {
            recommendations.append("Does not meet WCAG AA standards")
        }
        if !levelAAA.normal && !levelAAA.large {
            recommendations.append("Does not meet WCAG AAA standards")
        }

        if ratio < 4.5 {
            recommendations.append("Consider using a darker text color or lighter background")
        }

        return ContrastAnalysis(
            ratio: ratio,
            wcagAA: levelAA,
            wcagAAA: levelAAA,
            recommendations: recommendations
        )
    }

    static func calculateContrastRatio(_ color1: UIColor, _ color2: UIColor) -> Double {
        let luminance1 = color1.relativeLuminance
        let luminance2 = color2.relativeLuminance

        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)

        return (lighter + 0.05) / (darker + 0.05)
    }

    // MARK: - WCAG Level Checks

    private static func meetsWCAGLevelAA(ratio: Double, fontSize: CGFloat, isBold: Bool) -> WCAGCompliance {
        let normalThreshold: Double
        let largeThreshold: Double

        if isBold && fontSize >= 14 {
            normalThreshold = 4.5
            largeThreshold = 4.5
        } else if !isBold && fontSize >= 18 {
            normalThreshold = 4.5
            largeThreshold = 4.5
        } else {
            normalThreshold = 4.5
            largeThreshold = 3.0
        }

        return WCAGCompliance(
            normal: ratio >= normalThreshold,
            large: ratio >= largeThreshold
        )
    }

    private static func meetsWCAGLevelAAA(ratio: Double, fontSize: CGFloat, isBold: Bool) -> WCAGCompliance {
        let normalThreshold: Double
        let largeThreshold: Double

        if isBold && fontSize >= 14 {
            normalThreshold = 7.0
            largeThreshold = 7.0
        } else if !isBold && fontSize >= 18 {
            normalThreshold = 7.0
            largeThreshold = 7.0
        } else {
            normalThreshold = 7.0
            largeThreshold = 4.5
        }

        return WCAGCompliance(
            normal: ratio >= normalThreshold,
            large: ratio >= largeThreshold
        )
    }

    // MARK: - Color Blindness Simulation

    static func simulateColorBlindness(_ color: UIColor, type: ColorBlindnessType) -> UIColor {
        guard let rgb = color.rgbComponents else { return color }

        let r = rgb.red
        let g = rgb.green
        let b = rgb.blue

        let simulated: (r: Double, g: Double, b: Double)

        switch type {
        case .protanopia:
            simulated = (
                r: 0.567 * r + 0.433 * g,
                g: 0.558 * r + 0.442 * g,
                b: b
            )
        case .deuteranopia:
            simulated = (
                r: 0.625 * r + 0.375 * g,
                g: 0.7 * r + 0.3 * g,
                b: b
            )
        case .tritanopia:
            simulated = (
                r: 0.95 * r + 0.05 * b,
                g: g,
                b: 0.433 * r + 0.567 * b
            )
        case .achromatopsia:
            let gray = 0.299 * r + 0.587 * g + 0.114 * b
            simulated = (r: gray, g: gray, b: gray)
        }

        return UIColor(red: simulated.r, green: simulated.g, blue: simulated.b, alpha: 1.0)
    }

    // MARK: - Accessibility Recommendations

    static func generateAccessibilityRecommendations(for colors: [UIColor], context: AccessibilityContext) -> [AccessibilityRecommendation] {
        var recommendations: [AccessibilityRecommendation] = []

        // Analyze contrast between all color pairs
        for i in 0..<colors.count {
            for j in (i+1)..<colors.count {
                let analysis = analyzeContrast(
                    textColor: colors[i],
                    backgroundColor: colors[j],
                    fontSize: context.fontSize,
                    isBold: context.isBold
                )

                if !analysis.wcagAA.normal && !analysis.wcagAA.large {
                    recommendations.append(.init(
                        type: .contrast,
                        severity: .high,
                        message: "Low contrast between colors \(i+1) and \(j+1) (\(String(format: "%.1f", analysis.ratio)):1)",
                        suggestion: "Increase contrast to meet WCAG AA standards (minimum \(context.isLargeText ? "3.0" : "4.5"):1)"
                    ))
                }
            }
        }

        // Check for color blindness issues
        for (index, color) in colors.enumerated() {
            for blindnessType in ColorBlindnessType.allCases {
                let simulated = simulateColorBlindness(color, type: blindnessType)
                let originalLuminance = color.relativeLuminance
                let simulatedLuminance = simulated.relativeLuminance

                // If luminance changes significantly, it might be confusing for color blind users
                if abs(originalLuminance - simulatedLuminance) > 0.1 {
                    recommendations.append(.init(
                        type: .colorBlindness,
                        severity: .medium,
                        message: "Color \(index+1) may be confusing for \(blindnessType.rawValue) users",
                        suggestion: "Consider adding patterns or text labels to distinguish this color"
                    ))
                }
            }
        }

        // Check for sufficient color variety
        if colors.count < 3 {
            recommendations.append(.init(
                type: .variety,
                severity: .low,
                message: "Limited color palette may reduce accessibility",
                suggestion: "Consider adding more colors for better visual distinction"
            ))
        }

        return recommendations
    }

    // MARK: - Color Suggestions for Accessibility

    static func suggestAccessibleColors(for baseColor: UIColor, count: Int = 5) -> [UIColor] {
        var suggestions: [UIColor] = []

        // Start with the base color
        suggestions.append(baseColor)

        // Generate high contrast variations
        guard let hsl = baseColor.hslComponents else { return suggestions }

        // Darker variations for text on light backgrounds
        for i in 1...2 {
            let brightness = max(0.1, hsl.brightness - Double(i) * 0.3)
            let color = UIColor(hue: hsl.hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: brightness,
                              alpha: 1.0)
            suggestions.append(color)
        }

        // Lighter variations for text on dark backgrounds
        for i in 1...2 {
            let brightness = min(1.0, hsl.brightness + Double(i) * 0.3)
            let color = UIColor(hue: hsl.hue / 360.0,
                              saturation: hsl.saturation,
                              brightness: brightness,
                              alpha: 1.0)
            suggestions.append(color)
        }

        return Array(suggestions.prefix(count))
    }
}

// MARK: - Supporting Types

struct ContrastAnalysis {
    let ratio: Double
    let wcagAA: WCAGCompliance
    let wcagAAA: WCAGCompliance
    let recommendations: [String]

    var grade: String {
        if wcagAAA.normal || wcagAAA.large {
            return "AAA"
        } else if wcagAA.normal || wcagAA.large {
            return "AA"
        } else {
            return "Fail"
        }
    }
}

struct WCAGCompliance {
    let normal: Bool
    let large: Bool

    var overall: Bool {
        normal || large
    }
}

enum ColorBlindnessType: String, CaseIterable {
    case protanopia = "Protanopia"
    case deuteranopia = "Deuteranopia"
    case tritanopia = "Tritanopia"
    case achromatopsia = "Achromatopsia"
}

struct AccessibilityContext {
    let fontSize: CGFloat
    let isBold: Bool

    var isLargeText: Bool {
        (isBold && fontSize >= 14) || (!isBold && fontSize >= 18)
    }
}

struct AccessibilityRecommendation {
    let type: RecommendationType
    let severity: Severity
    let message: String
    let suggestion: String
}

enum RecommendationType {
    case contrast
    case colorBlindness
    case variety
}

enum Severity {
    case low
    case medium
    case high
}