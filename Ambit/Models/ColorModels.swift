//
//  ColorModels.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import SwiftUI

struct NamedColor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let hex: String
    let color: Color

    var uiColor: UIColor {
        UIColor(color)
    }
}

struct SampledColor: Identifiable {
    let id = UUID()
    let color: Color
    let uiColor: UIColor
    let position: CGPoint
}

// Color Harmony Types
enum HarmonyType: String, CaseIterable {
    case complementary = "Complementary"
    case analogous = "Analogous"
    case triadic = "Triadic"
    case tetradic = "Tetradic"
    case splitComplementary = "Split-Complementary"
    case monochromatic = "Monochromatic"
    case square = "Square"
}

// Color Spaces
enum ColorSpace: String, CaseIterable {
    case rgb = "RGB"
    case hsl = "HSL"
    case hsv = "HSV"
    case lab = "LAB"
    case cmyk = "CMYK"
    case hex = "HEX"
}

// Sampling Modes
enum SamplingMode: String, CaseIterable, Identifiable {
    case single = "Single Point"
    case area = "Area Average"
    case dominant = "Dominant Colors"

    var id: String { rawValue }
}

// Card Aspect Ratios
enum CardAspect: String, CaseIterable, Identifiable {
    case square = "1:1"
    case fourFive = "4:5"
    case threeFour = "3:4"
    case nineSixteen = "9:16"

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .square:      return CGSize(width: 1000, height: 1000)
        case .fourFive:    return CGSize(width: 1000, height: 1250)
        case .threeFour:   return CGSize(width: 1200, height: 1600)
        case .nineSixteen: return CGSize(width: 1080, height: 1920)
        }
    }
}

// Palette Layouts
enum PaletteLayout: String, CaseIterable, Identifiable {
    case strip = "Strip"
    case grid = "Grid"
    case chips = "Chips"

    var id: String { rawValue }
}

// Frame Styles
enum FrameStyle: String, CaseIterable, Identifiable {
    case none = "None"
    case rounded = "Rounded"
    case polaroid = "Polaroid"

    var id: String { rawValue }
}

// Background Modes
enum BackgroundMode: String, CaseIterable, Identifiable {
    case solid = "Solid"
    case gradient = "Gradient"
    case image = "Image"

    var id: String { rawValue }
}

// Preset Templates
enum PresetTemplate: String, CaseIterable, Identifiable {
    case defaultMinimal = "Default"
    case posterA = "Poster A"
    case magazine = "Magazine"
    case minimalTag = "Minimal With Tag"
    case elegant = "Elegant"
    case bold = "Bold"
    case minimalist = "Minimalist"
    case vintage = "Vintage"
    case modern = "Modern"
    case nature = "Nature"
    case corporate = "Corporate"
    case playful = "Playful"

    var id: String { rawValue }
}