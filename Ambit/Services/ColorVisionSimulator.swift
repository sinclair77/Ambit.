//
//  ColorVisionSimulator.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI

enum ColorVisionSimulator {
    // MARK: - Vision Deficiency Simulation

    static func simulateVisionDeficiency(_ image: UIImage, type: VisionType) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Create bitmap context
        guard let context = CGContext(data: nil,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        // Draw original image
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get pixel data
        guard let pixelData = context.data else { return nil }
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

        // Apply vision deficiency simulation
        applyVisionSimulation(to: data, width: width, height: height, type: type)

        // Create new image from modified context
        guard let outputImage = context.makeImage() else { return nil }
        return UIImage(cgImage: outputImage)
    }

    private static func applyVisionSimulation(to pixelData: UnsafeMutablePointer<UInt8>,
                                            width: Int,
                                            height: Int,
                                            type: VisionType) {

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4

                let r = Double(pixelData[pixelIndex]) / 255.0
                let g = Double(pixelData[pixelIndex + 1]) / 255.0
                let b = Double(pixelData[pixelIndex + 2]) / 255.0

                let simulated = simulateColor(r: r, g: g, b: b, type: type)

                pixelData[pixelIndex] = UInt8(simulated.r * 255.0)
                pixelData[pixelIndex + 1] = UInt8(simulated.g * 255.0)
                pixelData[pixelIndex + 2] = UInt8(simulated.b * 255.0)
            }
        }
    }

    private static func simulateColor(r: Double, g: Double, b: Double, type: VisionType) -> (r: Double, g: Double, b: Double) {
        switch type {
        case .normal:
            return (r, g, b)
        case .protanopia:
            return simulateProtanopia(r: r, g: g, b: b)
        case .deuteranopia:
            return simulateDeuteranopia(r: r, g: g, b: b)
        case .tritanopia:
            return simulateTritanopia(r: r, g: g, b: b)
        case .achromatopsia:
            return simulateAchromatopsia(r: r, g: g, b: b)
        case .protanomaly:
            return simulateProtanomaly(r: r, g: g, b: b)
        case .deuteranomaly:
            return simulateDeuteranomaly(r: r, g: g, b: b)
        case .tritanomaly:
            return simulateTritanomaly(r: r, g: g, b: b)
        }
    }

    // MARK: - Individual Vision Deficiency Simulations

    private static func simulateProtanopia(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Protanopia: Missing red cones
        let r_new = 0.567 * r + 0.433 * g
        let g_new = 0.558 * r + 0.442 * g
        return (r: r_new, g: g_new, b: b)
    }

    private static func simulateDeuteranopia(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Deuteranopia: Missing green cones
        let r_new = 0.625 * r + 0.375 * g
        let g_new = 0.7 * r + 0.3 * g
        return (r: r_new, g: g_new, b: b)
    }

    private static func simulateTritanopia(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Tritanopia: Missing blue cones
        let r_new = 0.95 * r + 0.05 * b
        let g_new = g
        let b_new = 0.433 * r + 0.567 * b
        return (r: r_new, g: g_new, b: b_new)
    }

    private static func simulateAchromatopsia(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Achromatopsia: Complete color blindness
        let gray = 0.299 * r + 0.587 * g + 0.114 * b
        return (r: gray, g: gray, b: gray)
    }

    private static func simulateProtanomaly(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Protanomaly: Reduced red sensitivity
        let r_new = 0.817 * r + 0.183 * g
        let g_new = 0.333 * r + 0.667 * g
        return (r: r_new, g: g_new, b: b)
    }

    private static func simulateDeuteranomaly(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Deuteranomaly: Reduced green sensitivity
        let r_new = 0.8 * r + 0.2 * g
        let g_new = 0.258 * r + 0.742 * g
        return (r: r_new, g: g_new, b: b)
    }

    private static func simulateTritanomaly(r: Double, g: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        // Tritanomaly: Reduced blue sensitivity
        let r_new = 0.967 * r + 0.033 * b
        let g_new = g
        let b_new = 0.733 * r + 0.267 * b
        return (r: r_new, g: g_new, b: b_new)
    }

    // MARK: - Color Analysis for Vision Deficiencies

    static func analyzeColorConfusion(for color: UIColor, visionTypes: [VisionType] = VisionType.allCases) -> [VisionAnalysis] {
        var analyses: [VisionAnalysis] = []

        for visionType in visionTypes {
            let simulated = simulateVisionDeficiency(for: color, type: visionType)

            // Calculate color difference
            let originalComponents = color.rgbComponents
            let simulatedComponents = simulated?.rgbComponents

            guard let orig = originalComponents, let sim = simulatedComponents else { continue }

            let deltaE = calculateColorDifference(orig, sim)

            // Determine confusion severity
            let severity: ConfusionSeverity
            if deltaE < 5 {
                severity = .none
            } else if deltaE < 15 {
                severity = .mild
            } else if deltaE < 30 {
                severity = .moderate
            } else {
                severity = .severe
            }

            analyses.append(VisionAnalysis(
                visionType: visionType,
                simulatedColor: simulated ?? color,
                colorDifference: deltaE,
                confusionSeverity: severity
            ))
        }

        return analyses
    }

    private static func simulateVisionDeficiency(for color: UIColor, type: VisionType) -> UIColor? {
        guard let rgb = color.rgbComponents else { return nil }

        let simulated = simulateColor(r: rgb.red, g: rgb.green, b: rgb.blue, type: type)
        return UIColor(red: simulated.r, green: simulated.g, blue: simulated.b, alpha: 1.0)
    }

    private static func calculateColorDifference(_ rgb1: RGBComponents, _ rgb2: RGBComponents) -> Double {
        // Convert to LAB color space for better perceptual difference
        let lab1 = rgbToLab(r: rgb1.red, g: rgb1.green, b: rgb1.blue)
        let lab2 = rgbToLab(r: rgb2.red, g: rgb2.green, b: rgb2.blue)

        // Calculate CIEDE2000 color difference (simplified)
        let deltaL = lab2.l - lab1.l
        let deltaA = lab2.a - lab1.a
        let deltaB = lab2.b - lab1.b

        return sqrt(deltaL * deltaL + deltaA * deltaA + deltaB * deltaB)
    }

    private static func rgbToLab(r: Double, g: Double, b: Double) -> (l: Double, a: Double, b: Double) {
        // Simplified RGB to LAB conversion
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505

        let xr = x / 0.95047
        let yr = y / 1.0
        let zr = z / 1.08883

        let fx = xr > 0.008856 ? pow(xr, 1.0/3.0) : (7.787 * xr + 16.0/116.0)
        let fy = yr > 0.008856 ? pow(yr, 1.0/3.0) : (7.787 * yr + 16.0/116.0)
        let fz = zr > 0.008856 ? pow(zr, 1.0/3.0) : (7.787 * zr + 16.0/116.0)

        let l = 116 * fy - 16
        let a = 500 * (fx - fy)
        let b_lab = 200 * (fy - fz)

        return (l: l, a: a, b: b_lab)
    }

    // MARK: - Vision Simulation Metadata

    static func getVisionTypeInfo(_ type: VisionType) -> ColorVisionTypeInfo {
        switch type {
        case .normal:
            return ColorVisionTypeInfo(
                name: "Normal Vision",
                description: "Standard human color vision",
                prevalence: "Standard",
                characteristics: "Full color perception across visible spectrum"
            )
        case .protanopia:
            return ColorVisionTypeInfo(
                name: "Protanopia",
                description: "Red-blind color vision deficiency",
                prevalence: "1.3% of males, 0.02% of females",
                characteristics: "Difficulty distinguishing red and green hues"
            )
        case .deuteranopia:
            return ColorVisionTypeInfo(
                name: "Deuteranopia",
                description: "Green-blind color vision deficiency",
                prevalence: "1.2% of males, 0.01% of females",
                characteristics: "Difficulty distinguishing red and green hues"
            )
        case .tritanopia:
            return ColorVisionTypeInfo(
                name: "Tritanopia",
                description: "Blue-blind color vision deficiency",
                prevalence: "0.003% of population",
                characteristics: "Difficulty distinguishing blue and yellow hues"
            )
        case .achromatopsia:
            return ColorVisionTypeInfo(
                name: "Achromatopsia",
                description: "Complete color blindness",
                prevalence: "0.00003% of population",
                characteristics: "No color perception, only shades of gray"
            )
        case .protanomaly:
            return ColorVisionTypeInfo(
                name: "Protanomaly",
                description: "Reduced red sensitivity",
                prevalence: "1.3% of males, 0.02% of females",
                characteristics: "Reduced sensitivity to red light"
            )
        case .deuteranomaly:
            return ColorVisionTypeInfo(
                name: "Deuteranomaly",
                description: "Reduced green sensitivity",
                prevalence: "5.0% of males, 0.35% of females",
                characteristics: "Reduced sensitivity to green light"
            )
        case .tritanomaly:
            return ColorVisionTypeInfo(
                name: "Tritanomaly",
                description: "Reduced blue sensitivity",
                prevalence: "0.01% of population",
                characteristics: "Reduced sensitivity to blue light"
            )
        }
    }
}

// MARK: - Supporting Types

enum VisionType: String, CaseIterable {
    case normal = "Normal"
    case protanopia = "Protanopia"
    case deuteranopia = "Deuteranopia"
    case tritanopia = "Tritanopia"
    case achromatopsia = "Achromatopsia"
    case protanomaly = "Protanomaly"
    case deuteranomaly = "Deuteranomaly"
    case tritanomaly = "Tritanomaly"
}

struct VisionAnalysis {
    let visionType: VisionType
    let simulatedColor: UIColor
    let colorDifference: Double
    let confusionSeverity: ConfusionSeverity
}

enum ConfusionSeverity {
    case none
    case mild
    case moderate
    case severe

    var description: String {
        switch self {
        case .none: return "No confusion"
        case .mild: return "Mild confusion possible"
        case .moderate: return "Moderate confusion likely"
        case .severe: return "Severe confusion expected"
        }
    }
}

struct ColorVisionTypeInfo {
    let name: String
    let description: String
    let prevalence: String
    let characteristics: String
}
