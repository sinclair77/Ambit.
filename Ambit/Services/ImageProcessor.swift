//
//  ImageProcessor.swift
//  Ambit
//
//  Created by Assistant on 2024
//

import UIKit
import ImageIO
import CoreImage

enum ImageProcessor {
    static func loadImage(from data: Data) -> UIImage? {
        if let direct = UIImage(data: data) {
            let normalized = direct.normalizedImage()
            return normalized.resizedIfNecessary(maxDimension: 2048)
        }

        if let source = CGImageSourceCreateWithData(data as CFData, nil) {
            let fullOptions: CFDictionary = [
                kCGImageSourceShouldCache: true,
                kCGImageSourceShouldAllowFloat: true
            ] as CFDictionary

            if let cgImage = CGImageSourceCreateImageAtIndex(source, 0, fullOptions) {
                return UIImage(cgImage: cgImage).normalizedImage().resizedIfNecessary(maxDimension: 2048)
            }

            let maxDimension: CGFloat = 4096
            let thumbnailOptions: CFDictionary = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldAllowFloat: true
            ] as CFDictionary

            if let cgThumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) {
                return UIImage(cgImage: cgThumbnail).normalizedImage().resizedIfNecessary(maxDimension: 2048)
            }
        }

        if let ciImage = CIImage(data: data, options: [.applyOrientationProperty: true]) {
            let context = CIContext(options: [.useSoftwareRenderer: false])
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                return UIImage(cgImage: cgImage).normalizedImage().resizedIfNecessary(maxDimension: 2048)
            }
        }

        return nil
    }
}

extension UIImage {
    func resizedIfNecessary(maxDimension: CGFloat) -> UIImage {
        let maxSize = max(size.width * scale, size.height * scale)
        guard maxSize > maxDimension else { return self }
        let scaleFactor = maxDimension / maxSize
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }.normalizedImage()
    }
}

enum PermissionManager {
    static func requestPermissions(completion: @escaping () -> Void) {
        completion() // no-op placeholder
    }
}

enum ColorTheory {
    static func generateHarmonizedPalette(from color: UIColor) -> (palette: [UIColor], harmony: String) {
        var h: CGFloat=0,s:CGFloat=0,b:CGFloat=0,a:CGFloat=0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let steps: [CGFloat] = [0, 0.1, 0.2, 0.3, 0.4]
        let palette = steps.map { UIColor(hue: (h+$0).truncatingRemainder(dividingBy: 1), saturation: max(0.4, s), brightness: max(0.6, b), alpha: 1) }
        return (palette, "Analogous")
    }
}

extension UIImage {
    func normalizedImage() -> UIImage {
        if imageOrientation == .up { return self }

        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale
        rendererFormat.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func color(at point: CGPoint, sampleRadius radius: Int = 0) -> UIColor? {
        guard let cgImage = cgImage else { return nil }

        let pixelWidth = cgImage.width
        let pixelHeight = cgImage.height
        guard pixelWidth > 0, pixelHeight > 0 else { return nil }

        let targetX = Int(point.x.rounded())
        let targetY = Int(point.y.rounded())
        guard (0..<pixelWidth).contains(targetX), (0..<pixelHeight).contains(targetY) else { return nil }

                guard let dataProvider = cgImage.dataProvider,
                            let data = dataProvider.data,
                            let pixelData = CFDataGetBytePtr(data) else { return nil }

                let width = max(cgImage.width, 1)
                let bytesPerPixel = max(cgImage.bytesPerRow / width, 1)
        let bytesPerRow = cgImage.bytesPerRow
        let clampedRadius = max(radius, 0)
                let bitsPerComponent = max(cgImage.bitsPerComponent, 1)
                let componentBytes = max((bitsPerComponent + 7) / 8, 1)

        let minX = max(targetX - clampedRadius, 0)
        let maxX = min(targetX + clampedRadius, pixelWidth - 1)
        let minY = max(targetY - clampedRadius, 0)
        let maxY = min(targetY + clampedRadius, pixelHeight - 1)

    let alphaInfo = cgImage.alphaInfo
    let bitmapInfo = cgImage.bitmapInfo
    let isLittleEndian = bitmapInfo.contains(.byteOrder32Little) || bitmapInfo.contains(.byteOrder16Little)
    let isBigEndian = bitmapInfo.contains(.byteOrder32Big) || bitmapInfo.contains(.byteOrder16Big)

        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var totalA: CGFloat = 0
        var sampleCount: Int = 0

        for y in minY...maxY {
            for x in minX...maxX {
                let pixelIndex = y * bytesPerRow + x * bytesPerPixel
                let components = rgbaComponents(
                    pixelData: pixelData,
                    index: pixelIndex,
                    bytesPerPixel: bytesPerPixel,
                    componentBytes: componentBytes,
                    bitsPerComponent: bitsPerComponent,
                    alphaInfo: alphaInfo,
                    isLittleEndian: isLittleEndian,
                    isBigEndian: isBigEndian
                )

                totalR += components.red
                totalG += components.green
                totalB += components.blue
                totalA += components.alpha
                sampleCount += 1
            }
        }

        guard sampleCount > 0 else { return nil }
        let divisor = CGFloat(sampleCount)

        return UIColor(
            red: totalR / divisor,
            green: totalG / divisor,
            blue: totalB / divisor,
            alpha: totalA / divisor
        )
    }

    private func rgbaComponents(
        pixelData: UnsafePointer<UInt8>,
        index: Int,
        bytesPerPixel: Int,
        componentBytes: Int,
        bitsPerComponent: Int,
        alphaInfo: CGImageAlphaInfo,
        isLittleEndian: Bool,
        isBigEndian: Bool
    ) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let pixelPointer = pixelData + index

        let hasAlpha: Bool = {
            switch alphaInfo {
            case .premultipliedFirst, .premultipliedLast, .first, .last, .alphaOnly:
                return true
            default:
                return false
            }
        }()

        let componentsPerPixel = max(bytesPerPixel / componentBytes, 1)

        func componentValue(at index: Int) -> CGFloat {
            let byteIndex = index * componentBytes
            let componentPointer = pixelPointer + byteIndex

            switch componentBytes {
            case 1:
                return CGFloat(componentPointer[0]) / 255.0
            case 2:
                let value: UInt16
                if isLittleEndian {
                    value = UInt16(componentPointer[0]) | (UInt16(componentPointer[1]) << 8)
                } else {
                    value = (UInt16(componentPointer[0]) << 8) | UInt16(componentPointer[1])
                }
                return CGFloat(value) / 65535.0
            default:
                var accum: UInt32 = 0
                for i in 0..<componentBytes {
                    let shift = isLittleEndian ? i * 8 : (componentBytes - 1 - i) * 8
                    accum |= UInt32(componentPointer[i]) << shift
                }
                let maxValue = max(CGFloat((1 << bitsPerComponent) - 1), 1)
                return CGFloat(accum) / maxValue
            }
        }

        let rIndex: Int
        let gIndex: Int
        let bIndex: Int
        let aIndex: Int?

        switch bytesPerPixel {
        case 4:
            if isLittleEndian {
                // BGRA ordering (little endian)
                bIndex = 0
                gIndex = 1
                rIndex = 2
                aIndex = hasAlpha ? 3 : nil
            } else if isBigEndian {
                // ARGB ordering (big endian)
                aIndex = hasAlpha ? 0 : nil
                rIndex = 1
                gIndex = 2
                bIndex = 3
            } else {
                // Assume RGBA ordering
                rIndex = 0
                gIndex = 1
                bIndex = 2
                aIndex = hasAlpha ? 3 : nil
            }
        case 3:
            rIndex = 0
            gIndex = 1
            bIndex = 2
            aIndex = nil
        default:
            rIndex = 0
            gIndex = min(1, componentsPerPixel - 1)
            bIndex = min(2, componentsPerPixel - 1)
            aIndex = hasAlpha && componentsPerPixel > 3 ? componentsPerPixel - 1 : nil
        }

        let red = componentValue(at: rIndex)
        let green = componentValue(at: gIndex)
        let blue = componentValue(at: bIndex)
        let alpha = aIndex.flatMap { $0 < componentsPerPixel ? componentValue(at: $0) : 1.0 } ?? 1.0

        return (red, green, blue, alpha)
    }

    var pixelSize: CGSize {
        if let cgImage = cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        }
        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    // Maps a normalized point in the rendered image (origin at top-left) back into raw pixel space.
    func pixelPoint(forNormalizedPoint normalized: CGPoint) -> CGPoint {
        let rawSize = pixelSize
        guard rawSize.width > 0, rawSize.height > 0 else { return .zero }

        let orientation = imageOrientation
        let displayWidth: CGFloat
        let displayHeight: CGFloat

        if orientation == .left || orientation == .leftMirrored || orientation == .right || orientation == .rightMirrored {
            displayWidth = max(rawSize.height - 1, 0)
            displayHeight = max(rawSize.width - 1, 0)
        } else {
            displayWidth = max(rawSize.width - 1, 0)
            displayHeight = max(rawSize.height - 1, 0)
        }

        var point = CGPoint(
            x: normalized.x * displayWidth,
            y: normalized.y * displayHeight
        )

        switch orientation {
        case .up:
            break
        case .upMirrored:
            point.x = displayWidth - point.x
        case .down:
            point.x = displayWidth - point.x
            point.y = displayHeight - point.y
        case .downMirrored:
            point.y = displayHeight - point.y
        case .left:
            point = CGPoint(x: point.y, y: displayWidth - point.x)
        case .leftMirrored:
            point = CGPoint(x: displayHeight - point.y, y: displayWidth - point.x)
        case .right:
            point = CGPoint(x: displayHeight - point.y, y: point.x)
        case .rightMirrored:
            point = CGPoint(x: point.y, y: point.x)
        @unknown default:
            break
        }

        let clampedX = min(max(point.x, 0), max(rawSize.width - 1, 0))
        let clampedY = min(max(point.y, 0), max(rawSize.height - 1, 0))
        return CGPoint(x: clampedX, y: clampedY)
    }
}