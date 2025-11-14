//
//  SavedPalette.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class SavedPalette {
    @Attribute(.unique) var syncIdentifier: String
    var name: String
    var imageData: Data?
    @Attribute(.transformable(by: ColorArrayTransformer.self))
    var colors: [UIColor]
    var timestamp: Date
    var isFavorite: Bool = false

    init(name: String, image: UIImage? = nil, colors: [UIColor], syncIdentifier: String = UUID().uuidString, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.syncIdentifier = syncIdentifier
        self.name = name
        self.imageData = image?.jpegData(compressionQuality: 0.8)
        self.colors = colors
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }

    var uiImage: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }

    var uiColors: [UIColor] {
        colors
    }

    var hexCodes: [String] {
        uiColors.map { $0.hexString }
    }

    var shareSummary: String {
        hexCodes.joined(separator: ", ")
    }
}

@Model
final class SavedCard {
    @Attribute(.unique) var syncIdentifier: String
    var imageData: Data
    var timestamp: Date
    var isFavorite: Bool = false

    init(imageData: Data, syncIdentifier: String = UUID().uuidString, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.syncIdentifier = syncIdentifier
        self.imageData = imageData
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }

    var uiImage: UIImage? {
        UIImage(data: imageData)
    }
}

@Model
final class SavedGradient {
    @Attribute(.unique) var syncIdentifier: String
    var name: String
    @Attribute(.transformable(by: ColorArrayTransformer.self))
    var colors: [UIColor]
    var locations: [CGFloat]
    @Attribute(.transformable(by: UnitPointTransformer.self))
    var startPoint: UnitPoint
    @Attribute(.transformable(by: UnitPointTransformer.self))
    var endPoint: UnitPoint
    var style: String = "linear"
    var angle: Double = 0
    var timestamp: Date
    var isFavorite: Bool = false

    init(name: String, colors: [UIColor], locations: [CGFloat], startPoint: UnitPoint, endPoint: UnitPoint, style: String = "linear", angle: Double = 0, syncIdentifier: String = UUID().uuidString, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.syncIdentifier = syncIdentifier
        self.name = name
        self.colors = colors
        self.locations = locations
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.style = style
        self.angle = angle
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
}

// MARK: - Value Transformers

@objc(ColorArrayTransformer)
final class ColorArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let colors = value as? [UIColor] else { return nil }
        let codable = colors.compactMap(CodableColor.init)
        return try? JSONEncoder().encode(codable)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return [UIColor]() }
        if let codable = try? JSONDecoder().decode([CodableColor].self, from: data) {
            return codable.map { $0.uiColor }
        }
        if let legacy = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: UIColor.self, from: data) {
            return legacy
        }
        return [UIColor]()
    }

    static let name = NSValueTransformerName(String(describing: ColorArrayTransformer.self))

    static func register() {
        ValueTransformer.setValueTransformer(ColorArrayTransformer(), forName: name)
    }
}

@objc(UnitPointTransformer)
final class UnitPointTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let point = value as? UnitPoint else { return nil }
        let codable = CodableUnitPoint(point: point)
        return try? JSONEncoder().encode(codable)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return UnitPoint.center }
        if let codable = try? JSONDecoder().decode(CodableUnitPoint.self, from: data) {
            return codable.unitPoint
        }
        if let dict = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSNumber.self], from: data) as? [String: CGFloat],
           let x = dict["x"], let y = dict["y"] {
            return UnitPoint(x: x, y: y)
        }
        if let wrapper = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UnitPointLegacyWrapper.self, from: data) {
            return wrapper.unitPoint
        }
        return UnitPoint.center
    }

    static let name = NSValueTransformerName(String(describing: UnitPointTransformer.self))

    static func register() {
        ValueTransformer.setValueTransformer(UnitPointTransformer(), forName: name)
    }
}

private struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init?(color: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            self.red = Double(r)
            self.green = Double(g)
            self.blue = Double(b)
            self.alpha = Double(a)
            return
        }

        guard let converted = color.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil),
              let components = converted.components, components.count >= 3 else { return nil }

        self.red = Double(components[0])
        self.green = Double(components[1])
        self.blue = Double(components[2])
        self.alpha = components.count >= 4 ? Double(components[3]) : Double(color.cgColor.alpha)
    }

    var uiColor: UIColor {
        UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}

private struct CodableUnitPoint: Codable {
    let x: Double
    let y: Double

    init(point: UnitPoint) {
        self.x = Double(point.x)
        self.y = Double(point.y)
    }

    var unitPoint: UnitPoint { UnitPoint(x: CGFloat(x), y: CGFloat(y)) }
}

@objc(AmbitUnitPointWrapper)
private final class UnitPointLegacyWrapper: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }

    let x: CGFloat
    let y: CGFloat

    init(point: UnitPoint) {
        self.x = point.x
        self.y = point.y
        super.init()
    }

    required init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "x"), coder.containsValue(forKey: "y") else { return nil }
        self.x = CGFloat(coder.decodeDouble(forKey: "x"))
        self.y = CGFloat(coder.decodeDouble(forKey: "y"))
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(Double(x), forKey: "x")
        coder.encode(Double(y), forKey: "y")
    }

    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}
