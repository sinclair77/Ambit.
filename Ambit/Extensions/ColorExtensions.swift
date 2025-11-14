//
//  ColorExtensions.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI

// MARK: - UIColor Extensions

extension UIColor {
    // MARK: - Component Access

    var rgbComponents: RGBComponents? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return RGBComponents(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }

    var hslComponents: HSLComponents? {
        guard let rgb = rgbComponents else { return nil }

        let max = Swift.max(rgb.red, rgb.green, rgb.blue)
        let min = Swift.min(rgb.red, rgb.green, rgb.blue)
        let delta = max - min

        let lightness = (max + min) / 2.0
        var saturation: Double = 0
        var hue: Double = 0

        if delta != 0 {
            saturation = lightness > 0.5 ? delta / (2.0 - max - min) : delta / (max + min)

            switch max {
            case rgb.red:
                hue = (rgb.green - rgb.blue) / delta + (rgb.green < rgb.blue ? 6 : 0)
            case rgb.green:
                hue = (rgb.blue - rgb.red) / delta + 2
            case rgb.blue:
                hue = (rgb.red - rgb.green) / delta + 4
            default:
                break
            }
            hue /= 6
        }

        return HSLComponents(hue: hue * 360.0, saturation: saturation, brightness: lightness)
    }

    var hsbComponents: HSBComponents? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }

        return HSBComponents(hue: Double(hue * 360), saturation: Double(saturation), brightness: Double(brightness), alpha: Double(alpha))
    }

    var rgbaComponents: RGBAComponents? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return RGBAComponents(red: Int(red * 255), green: Int(green * 255), blue: Int(blue * 255), alpha: Int(alpha * 255))
    }

    // MARK: - Color Properties

    var isWarm: Bool {
        guard let hsl = hslComponents else { return false }
        return hsl.hue >= 0 && hsl.hue <= 60 || hsl.hue >= 300 && hsl.hue <= 360
    }

    var isCool: Bool {
        guard let hsl = hslComponents else { return false }
        return hsl.hue > 60 && hsl.hue < 300
    }

    var isNeutral: Bool {
        guard let hsl = hslComponents else { return false }
        return hsl.saturation < 0.1
    }

    var relativeLuminance: Double {
        guard let rgb = rgbComponents else { return 0.0 }

        let toLinear = { (value: Double) -> Double in
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }

        let r = toLinear(rgb.red)
        let g = toLinear(rgb.green)
        let b = toLinear(rgb.blue)

        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    // MARK: - Color Manipulation

    func withHue(_ hue: Double) -> UIColor {
        guard let hsl = hslComponents else { return self }
        return UIColor(hue: hue / 360.0, saturation: hsl.saturation, brightness: hsl.brightness, alpha: 1.0)
    }

    func withSaturation(_ saturation: Double) -> UIColor {
        guard let hsl = hslComponents else { return self }
        return UIColor(hue: hsl.hue / 360.0, saturation: saturation, brightness: hsl.brightness, alpha: 1.0)
    }

    func withBrightness(_ brightness: Double) -> UIColor {
        guard let hsl = hslComponents else { return self }
        return UIColor(hue: hsl.hue / 360.0, saturation: hsl.saturation, brightness: brightness, alpha: 1.0)
    }

    func adjustedHue(by degrees: Double) -> UIColor {
        guard let hsl = hslComponents else { return self }
        let newHue = (hsl.hue + degrees).truncatingRemainder(dividingBy: 360.0)
        return UIColor(hue: newHue / 360.0, saturation: hsl.saturation, brightness: hsl.brightness, alpha: 1.0)
    }

    func adjustedSaturation(by factor: Double) -> UIColor {
        guard let hsl = hslComponents else { return self }
        let newSaturation = min(1.0, max(0.0, hsl.saturation * factor))
        return UIColor(hue: hsl.hue / 360.0, saturation: newSaturation, brightness: hsl.brightness, alpha: 1.0)
    }

    func adjustedBrightness(by factor: Double) -> UIColor {
        guard let hsl = hslComponents else { return self }
        let newBrightness = min(1.0, max(0.0, hsl.brightness * factor))
        return UIColor(hue: hsl.hue / 360.0, saturation: hsl.saturation, brightness: newBrightness, alpha: 1.0)
    }

    // MARK: - Color Distance

    func colorDistance(to other: UIColor) -> Double {
        guard let rgb1 = self.rgbComponents, let rgb2 = other.rgbComponents else { return 0.0 }

        let deltaR = rgb1.red - rgb2.red
        let deltaG = rgb1.green - rgb2.green
        let deltaB = rgb1.blue - rgb2.blue

        return sqrt(deltaR * deltaR + deltaG * deltaG + deltaB * deltaB)
    }

    // MARK: - String Representations

    var hexString: String {
        guard let rgba = rgbaComponents else { return "#000000" }
        return String(format: "#%02X%02X%02X", rgba.red, rgba.green, rgba.blue)
    }

    var rgbString: String {
        guard let rgba = rgbaComponents else { return "rgb(0, 0, 0)" }
        return "rgb(\(rgba.red), \(rgba.green), \(rgba.blue))"
    }

    var hslString: String {
        guard let hsl = hslComponents else { return "hsl(0, 0%, 0%)" }
        return String(format: "hsl(%.0f, %.0f%%, %.0f%%)", hsl.hue, hsl.saturation * 100, hsl.brightness * 100)
    }

    func toHex(includeAlpha: Bool = false) -> String? {
        guard let rgba = rgbaComponents else { return nil }
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", rgba.red, rgba.green, rgba.blue, rgba.alpha)
        }
        return String(format: "#%02X%02X%02X", rgba.red, rgba.green, rgba.blue)
    }

    func toRGBString() -> String {
        guard let rgba = rgbaComponents else { return "rgb(0, 0, 0)" }
        return "rgb(\(rgba.red), \(rgba.green), \(rgba.blue))"
    }

    func toHSLString() -> String {
        guard let hsl = hslComponents else { return "hsl(0, 0%, 0%)" }
        return String(format: "hsl(%.0f, %.0f%%, %.0f%%)", hsl.hue, hsl.saturation * 100, hsl.brightness * 100)
    }

    // MARK: - Initialization from Strings

    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    convenience init?(rgbString: String) {
        let components = rgbString
            .replacingOccurrences(of: "rgb(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

        guard components.count >= 3 else { return nil }

        self.init(red: components[0] / 255.0, green: components[1] / 255.0, blue: components[2] / 255.0, alpha: 1.0)
    }

    convenience init?(hslString: String) {
        let components = hslString
            .replacingOccurrences(of: "hsl(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "%", with: "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

        guard components.count >= 3 else { return nil }

        let hue = components[0] / 360.0
        let saturation = components[1] / 100.0
        let brightness = components[2] / 100.0

        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

// MARK: - SwiftUI Color Extensions

extension Color {
    func toHex(includeAlpha: Bool = false) -> String {
        UIColor(self).toHex(includeAlpha: includeAlpha) ?? "#000000"
    }

    func toRGBString() -> String {
        UIColor(self).toRGBString()
    }

    func toHSLString() -> String {
        UIColor(self).toHSLString()
    }
}

// MARK: - Component Structs

struct RGBComponents {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}

struct HSLComponents {
    let hue: Double
    let saturation: Double
    let brightness: Double
}

struct HSBComponents {
    let hue: Double
    let saturation: Double
    let brightness: Double
    let alpha: Double
}

struct RGBAComponents {
    let red: Int
    let green: Int
    let blue: Int
    let alpha: Int
}

// MARK: - Array Extensions for Colors

extension Array where Element == UIColor {
    func sortedByHue() -> [UIColor] {
        sorted { (color1, color2) -> Bool in
            guard let hsl1 = color1.hslComponents, let hsl2 = color2.hslComponents else {
                return false
            }
            return hsl1.hue < hsl2.hue
        }
    }

    func sortedByBrightness() -> [UIColor] {
        sorted { (color1, color2) -> Bool in
            guard let hsl1 = color1.hslComponents, let hsl2 = color2.hslComponents else {
                return false
            }
            return hsl1.brightness < hsl2.brightness
        }
    }

    func sortedBySaturation() -> [UIColor] {
        sorted { (color1, color2) -> Bool in
            guard let hsl1 = color1.hslComponents, let hsl2 = color2.hslComponents else {
                return false
            }
            return hsl1.saturation < hsl2.saturation
        }
    }
}

extension Array where Element == Color {
    func sortedByHue() -> [Color] {
        map { UIColor($0) }.sortedByHue().map { Color($0) }
    }

    func sortedByBrightness() -> [Color] {
        map { UIColor($0) }.sortedByBrightness().map { Color($0) }
    }

    func sortedBySaturation() -> [Color] {
        map { UIColor($0) }.sortedBySaturation().map { Color($0) }
    }
}