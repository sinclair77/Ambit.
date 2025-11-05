//
//  ColorExtractor.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit
import SwiftUI
import Vision
import CoreVideo

enum ColorExtractor {
    // MARK: - High-Accuracy Color Extraction

    static func extractRandomColors(from image: UIImage, count: Int, avoidDark: Bool) async -> [UIColor] {
        await Task.detached {
            extractProminentColors(from: image, in: nil, count: count, avoidDark: avoidDark)
        }.value
    }

    static func extractProminentColors(from image: UIImage, in rect: CGRect? = nil, count: Int, avoidDark: Bool) -> [UIColor] {
        guard let cgImage = image.cgImage else { return [] }

        let sampleWidth = 200
        let sampleHeight = 200
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * sampleWidth
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: sampleWidth * sampleHeight * bytesPerPixel)
        defer { rawData.deallocate() }

        guard let context = CGContext(data: rawData,
                                      width: sampleWidth,
                                      height: sampleHeight,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return []
        }

        context.interpolationQuality = .high
        context.setShouldAntialias(false)

        var analysisImage = cgImage
        if let cropRect = rect {
            let scaleX = CGFloat(cgImage.width) / image.size.width
            let scaleY = CGFloat(cgImage.height) / image.size.height
            let scaledRect = CGRect(x: cropRect.minX * scaleX,
                                    y: cropRect.minY * scaleY,
                                    width: cropRect.width * scaleX,
                                    height: cropRect.height * scaleY)

            if let croppedImage = cgImage.cropping(to: scaledRect) {
                analysisImage = croppedImage
            }
        }

        let drawRect = CGRect(x: 0, y: 0, width: sampleWidth, height: sampleHeight)
        context.draw(analysisImage, in: drawRect)

        let saliencyWeights = computeSaliencyWeights(for: analysisImage,
                                                     width: sampleWidth,
                                                     height: sampleHeight)

        let result = extractColorsWithConfidence(from: rawData,
                                                 width: sampleWidth,
                                                 height: sampleHeight,
                                                 count: count,
                                                 avoidDark: avoidDark,
                                                 saliencyWeights: saliencyWeights)
        return result.colors
    }

    /// New: returns colors plus a confidence (0..1) indicating how dominant the top color is.
    static func extractProminentColorsWithConfidence(from image: UIImage, count: Int, avoidDark: Bool) -> (colors: [UIColor], confidence: Double) {
        guard let cgImage = image.cgImage else { return ([], 0.0) }

        let sampleWidth = 200
        let sampleHeight = 200
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * sampleWidth
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: sampleWidth * sampleHeight * bytesPerPixel)
        defer { rawData.deallocate() }

        guard let context = CGContext(data: rawData,
                                      width: sampleWidth,
                                      height: sampleHeight,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return ([], 0.0)
        }

        context.interpolationQuality = .high
        context.setShouldAntialias(false)
        let drawRect = CGRect(x: 0, y: 0, width: sampleWidth, height: sampleHeight)
        context.draw(cgImage, in: drawRect)

        let saliencyWeights = computeSaliencyWeights(for: cgImage,
                                                     width: sampleWidth,
                                                     height: sampleHeight)

        return extractColorsWithConfidence(from: rawData,
                                           width: sampleWidth,
                                           height: sampleHeight,
                                           count: count,
                                           avoidDark: avoidDark,
                                           saliencyWeights: saliencyWeights)
    }

    private static func extractColorsWithConfidence(from pixelData: UnsafeMutablePointer<UInt8>,
                                                    width: Int,
                                                    height: Int,
                                                    count: Int,
                                                    avoidDark: Bool,
                                                    saliencyWeights: [Double]?) -> (colors: [UIColor], confidence: Double) {
        var labPixels: [(l: Double, a: Double, b: Double, weight: Double)] = []

        let centerX = Double(width) / 2.0
        let centerY = Double(height) / 2.0
        let maxDist = sqrt(centerX * centerX + centerY * centerY)

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                let r = Double(pixelData[pixelIndex]) / 255.0
                let g = Double(pixelData[pixelIndex + 1]) / 255.0
                let b = Double(pixelData[pixelIndex + 2]) / 255.0

                if avoidDark && (r < 0.03 && g < 0.03 && b < 0.03) { continue }

                let maxComponent = max(r, g, b)
                let minComponent = min(r, g, b)
                let saturation = maxComponent > 0 ? (maxComponent - minComponent) / maxComponent : 0

                if saturation < 0.06 && maxComponent > 0.94 { continue }

                let dx = Double(x) - centerX
                let dy = Double(y) - centerY
                let dist = sqrt(dx * dx + dy * dy)
                let centerWeight = 1.0 + (1.0 - min(dist / maxDist, 1.0)) * 1.6
                let satWeight = 0.5 + saturation * 1.5

                var weight = centerWeight * satWeight
                if let saliencyWeights, saliencyWeights.count == width * height {
                    let saliency = saliencyWeights[y * width + x]
                    let saliencyFactor = 0.35 + 0.65 * saliency
                    weight *= max(0.05, saliencyFactor)
                }

                if weight <= 0.0 { continue }

                let lab = rgbToLab((r: r, g: g, b: b))
                labPixels.append((l: lab.l, a: lab.a, b: lab.b, weight: weight))
            }
        }

        guard !labPixels.isEmpty else { return ([], 0.0) }

        let clusters = kMeansClusteringLAB(pixels: labPixels, k: min(count, labPixels.count))
        let totalWeight = clusters.reduce(0.0) { $0 + $1.totalWeight }
        let topWeight = clusters.map { $0.totalWeight }.max() ?? 0.0
        let confidence = totalWeight > 0 ? min(1.0, topWeight / totalWeight) : 0.0

        let colors = clusters.sorted { $0.totalWeight > $1.totalWeight }
            .prefix(count)
            .compactMap { cluster -> UIColor? in
                let rgb = labToRgb((l: cluster.centroid.l, a: cluster.centroid.a, b: cluster.centroid.b))
                guard (0...1).contains(rgb.r), (0...1).contains(rgb.g), (0...1).contains(rgb.b) else { return nil }
                return UIColor(red: CGFloat(rgb.r), green: CGFloat(rgb.g), blue: CGFloat(rgb.b), alpha: 1.0)
            }

        return (colors, confidence)
    }

    // MARK: - Vision Saliency

    private static func computeSaliencyWeights(for cgImage: CGImage,
                                               width: Int,
                                               height: Int) -> [Double]? {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                return nil
            }

            if let map = resizeSaliencyMap(pixelBuffer: observation.pixelBuffer,
                                           targetWidth: width,
                                           targetHeight: height) {
                return map
            }

            if let boxes = observation.salientObjects, !boxes.isEmpty {
                return rasterizeSalientBoxes(boxes,
                                             targetWidth: width,
                                             targetHeight: height)
            }
        } catch {
            return nil
        }

        return nil
    }

    private static func resizeSaliencyMap(pixelBuffer: CVPixelBuffer,
                                          targetWidth: Int,
                                          targetHeight: Int) -> [Double]? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }

        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let sourceWidth = CVPixelBufferGetWidth(pixelBuffer)
        let sourceHeight = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        guard sourceWidth > 0,
              sourceHeight > 0,
              targetWidth > 0,
              targetHeight > 0 else { return nil }

        var weights = [Double](repeating: 0.0, count: targetWidth * targetHeight)

        func normalized(_ value: Double) -> Double {
            return value.isFinite ? max(0.0, min(value, 1.0)) : 0.0
        }

        switch pixelFormat {
        case kCVPixelFormatType_OneComponent8:
            let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
            for ty in 0..<targetHeight {
                let normalizedY = targetHeight > 1 ? Double(ty) / Double(targetHeight - 1) : 0.0
                let sourceY = Int(round(normalizedY * Double(sourceHeight - 1)))
                let row = buffer.advanced(by: sourceY * bytesPerRow)
                for tx in 0..<targetWidth {
                    let normalizedX = targetWidth > 1 ? Double(tx) / Double(targetWidth - 1) : 0.0
                    let sourceX = Int(round(normalizedX * Double(sourceWidth - 1)))
                    let value = Double(row[sourceX]) / 255.0
                    let flippedIndex = (targetHeight - 1 - ty) * targetWidth + tx
                    weights[flippedIndex] = normalized(value)
                }
            }
        case kCVPixelFormatType_OneComponent32Float:
            let buffer = baseAddress.assumingMemoryBound(to: Float32.self)
            let stride = bytesPerRow / MemoryLayout<Float32>.size
            for ty in 0..<targetHeight {
                let normalizedY = targetHeight > 1 ? Double(ty) / Double(targetHeight - 1) : 0.0
                let sourceY = Int(round(normalizedY * Double(sourceHeight - 1)))
                let row = buffer.advanced(by: sourceY * stride)
                for tx in 0..<targetWidth {
                    let normalizedX = targetWidth > 1 ? Double(tx) / Double(targetWidth - 1) : 0.0
                    let sourceX = Int(round(normalizedX * Double(sourceWidth - 1)))
                    let value = Double(row[sourceX])
                    let flippedIndex = (targetHeight - 1 - ty) * targetWidth + tx
                    weights[flippedIndex] = normalized(value)
                }
            }
        default:
            return nil
        }

        if let maxValue = weights.max(), maxValue > 0.0001 {
            let invMax = 1.0 / maxValue
            for index in weights.indices {
                weights[index] *= invMax
            }
            return weights
        }

        return nil
    }

    private static func rasterizeSalientBoxes(_ boxes: [VNRectangleObservation],
                                               targetWidth: Int,
                                               targetHeight: Int) -> [Double]? {
        guard targetWidth > 0, targetHeight > 0 else { return nil }

        var weights = [Double](repeating: 0.0, count: targetWidth * targetHeight)

        for box in boxes {
            let confidence = Double(box.confidence)
            if confidence <= 0 { continue }

            let minX = Int(floor(box.boundingBox.minX * CGFloat(targetWidth)))
            let maxX = Int(ceil(box.boundingBox.maxX * CGFloat(targetWidth)))
            let minYNormalized = box.boundingBox.minY
            let maxYNormalized = box.boundingBox.maxY

            let minY = Int(floor((1.0 - maxYNormalized) * CGFloat(targetHeight)))
            let maxY = Int(ceil((1.0 - minYNormalized) * CGFloat(targetHeight)))

            let clampedMinX = max(0, min(targetWidth, minX))
            let clampedMaxX = max(0, min(targetWidth, maxX))
            let clampedMinY = max(0, min(targetHeight, minY))
            let clampedMaxY = max(0, min(targetHeight, maxY))

            if clampedMinX >= clampedMaxX || clampedMinY >= clampedMaxY { continue }

            for y in clampedMinY..<clampedMaxY {
                for x in clampedMinX..<clampedMaxX {
                    let index = y * targetWidth + x
                    weights[index] = max(weights[index], confidence)
                }
            }
        }

        if let maxValue = weights.max(), maxValue > 0.0001 {
            let invMax = 1.0 / maxValue
            for index in weights.indices {
                weights[index] *= invMax
            }
            return weights
        }

        return nil
    }

    // MARK: - K-Means Implementation

    private struct ColorCluster {
        var centroid: (l: Double, a: Double, b: Double)
        var points: [(l: Double, a: Double, b: Double, weight: Double)]
        var totalWeight: Double { points.reduce(0) { $0 + $1.weight } }

        init(centroid: (l: Double, a: Double, b: Double)) {
            self.centroid = centroid
            self.points = []
        }
    }

    // K-means in LAB space with weights
    private static func kMeansClusteringLAB(pixels: [(l: Double, a: Double, b: Double, weight: Double)], k: Int) -> [ColorCluster] {
        guard k > 0 && !pixels.isEmpty else { return [] }

        // Initialize centroids using k-means++ but in LAB space
        let centroids = kMeansPlusPlusInitializationLAB(pixels: pixels, k: k)
        var clusters = centroids.map { ColorCluster(centroid: $0) }

        let maxIterations = 30
        var iteration = 0
        var hasChanged = true

        while hasChanged && iteration < maxIterations {
            iteration += 1
            hasChanged = false

            // Clear assignments
            clusters = clusters.map { cluster in
                var nc = cluster
                nc.points = []
                return nc
            }

            // Assign each pixel to nearest centroid (Euclidean in LAB)
            for pixel in pixels {
                var minDist = Double.infinity
                var bestIndex = 0
                for (i, c) in clusters.enumerated() {
                    let dx = pixel.l - c.centroid.l
                    let dy = pixel.a - c.centroid.a
                    let dz = pixel.b - c.centroid.b
                    let d = dx*dx + dy*dy + dz*dz
                    if d < minDist { minDist = d; bestIndex = i }
                }
                clusters[bestIndex].points.append(pixel)
            }

            // Recompute centroids as weighted average
            for i in 0..<clusters.count {
                let pts = clusters[i].points
                if pts.isEmpty { continue }
                let totalW = pts.reduce(0.0) { $0 + $1.weight }
                guard totalW > 0 else { continue }
                let sumL = pts.reduce(0.0) { $0 + $1.l * $1.weight }
                let sumA = pts.reduce(0.0) { $0 + $1.a * $1.weight }
                let sumB = pts.reduce(0.0) { $0 + $1.b * $1.weight }
                let newCentroid = (l: sumL / totalW, a: sumA / totalW, b: sumB / totalW)
                if abs(newCentroid.l - clusters[i].centroid.l) > 0.0001 || abs(newCentroid.a - clusters[i].centroid.a) > 0.0001 || abs(newCentroid.b - clusters[i].centroid.b) > 0.0001 {
                    hasChanged = true
                    clusters[i].centroid = newCentroid
                }
            }
        }

        return clusters
    }

    private static func kMeansPlusPlusInitializationLAB(pixels: [(l: Double, a: Double, b: Double, weight: Double)], k: Int) -> [(l: Double, a: Double, b: Double)] {
        guard !pixels.isEmpty else { return [] }
        var centroids: [(l: Double, a: Double, b: Double)] = []

        // pick first centroid weighted by pixel weight
        let totalWeight = pixels.reduce(0.0) { $0 + $1.weight }
        var r = Double.random(in: 0..<totalWeight)
        for p in pixels {
            r -= p.weight
            if r <= 0 { centroids.append((l: p.l, a: p.a, b: p.b)); break }
        }
        if centroids.isEmpty { centroids.append((l: pixels[0].l, a: pixels[0].a, b: pixels[0].b)) }

        while centroids.count < min(k, pixels.count) {
            // compute distances to nearest centroid
            var distances: [Double] = []
            for p in pixels {
                let d = centroids.map { c -> Double in
                    let dx = p.l - c.l
                    let dy = p.a - c.a
                    let dz = p.b - c.b
                    return dx*dx + dy*dy + dz*dz
                }.min() ?? 0
                distances.append(d * p.weight)
            }
            let sum = distances.reduce(0, +)
            if sum == 0 {
                centroids.append((l: pixels.randomElement()!.l, a: pixels.randomElement()!.a, b: pixels.randomElement()!.b))
                continue
            }
            var pick = Double.random(in: 0..<sum)
            for (i, d) in distances.enumerated() {
                pick -= d
                if pick <= 0 { centroids.append((l: pixels[i].l, a: pixels[i].a, b: pixels[i].b)); break }
            }
        }

        return centroids
    }

    private static func colorDistance(_ color1: (r: Double, g: Double, b: Double),
                                    _ color2: (r: Double, g: Double, b: Double)) -> Double {
        // Deprecated for k-means: clustering operates in LAB directly.
        // Keep a perceptual fallback using CIEDE2000.
        let lab1 = rgbToLab(color1)
        let lab2 = rgbToLab(color2)
        return ciede2000Distance(lab1, lab2)
    }

    private static func calculateCentroid(of points: [(r: Double, g: Double, b: Double)]) -> (r: Double, g: Double, b: Double) {
        guard !points.isEmpty else { return (0, 0, 0) }

        let sum = points.reduce((r: 0.0, g: 0.0, b: 0.0)) { (result, point) in
            (r: result.r + point.r, g: result.g + point.g, b: result.b + point.b)
        }

        let count = Double(points.count)
        return (r: sum.r / count, g: sum.g / count, b: sum.b / count)
    }

    // Convert LAB back to sRGB (0..1). Returns (r,g,b).
    private static func labToRgb(_ lab: (l: Double, a: Double, b: Double)) -> (r: Double, g: Double, b: Double) {
        // Convert LAB to XYZ
        let y = (lab.l + 16.0) / 116.0
        let x = lab.a / 500.0 + y
        let z = y - lab.b / 200.0

        func pivot(_ n: Double) -> Double {
            let n3 = n * n * n
            return n3 > 0.008856 ? n3 : (n - 16.0/116.0) / 7.787
        }

        let xr = pivot(x)
        let yr = pivot(y)
        let zr = pivot(z)

        // Reference white D65
        let X = xr * 95.047
        let Y = yr * 100.0
        let Z = zr * 108.883

        // Convert XYZ to RGB
        var r =  X * 0.032406 + Y * -0.015372 + Z * -0.004986
        var g =  X * -0.009689 + Y * 0.018758 + Z * 0.000415
        var b =  X * 0.000557 + Y * -0.002040 + Z * 0.010570

        // The above matrix is from XYZ to linear RGB but scaled; instead use standard matrix
        // Convert XYZ to linear RGB using sRGB matrix
        let rl =  3.2406 * X/100.0 - 1.5372 * Y/100.0 - 0.4986 * Z/100.0
        let gl = -0.9689 * X/100.0 + 1.8758 * Y/100.0 + 0.0415 * Z/100.0
        let bl =  0.0557 * X/100.0 - 0.2040 * Y/100.0 + 1.0570 * Z/100.0

        func toSRGB(_ c: Double) -> Double {
            if c <= 0.0031308 { return 12.92 * c }
            return 1.055 * pow(c, 1.0/2.4) - 0.055
        }

        r = toSRGB(rl)
        g = toSRGB(gl)
        b = toSRGB(bl)

        return (r: min(max(r, 0.0), 1.0), g: min(max(g, 0.0), 1.0), b: min(max(b, 0.0), 1.0))
    }

    // MARK: - Color Space Conversions

    private static func rgbToLab(_ rgb: (r: Double, g: Double, b: Double)) -> (l: Double, a: Double, b: Double) {
        // Convert RGB to XYZ
        var r = rgb.r, g = rgb.g, b = rgb.b

        r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4) : r / 12.92
        g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4) : g / 12.92
        b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4) : b / 12.92

        r *= 100
        g *= 100
        b *= 100

        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505

        // Convert XYZ to LAB
        let xr = x / 95.047
        let yr = y / 100.0
        let zr = z / 108.883

        let fx = xr > 0.008856 ? pow(xr, 1.0/3.0) : (7.787 * xr + 16.0/116.0)
        let fy = yr > 0.008856 ? pow(yr, 1.0/3.0) : (7.787 * yr + 16.0/116.0)
        let fz = zr > 0.008856 ? pow(zr, 1.0/3.0) : (7.787 * zr + 16.0/116.0)

        let l = (116 * fy) - 16
        let a = 500 * (fx - fy)
        let b_lab = 200 * (fy - fz)

        return (l: l, a: a, b: b_lab)
    }

    private static func ciede2000Distance(_ lab1: (l: Double, a: Double, b: Double),
                                        _ lab2: (l: Double, a: Double, b: Double)) -> Double {
        // Simplified CIEDE2000 implementation
        // For full accuracy, this would include more complex calculations
        // but this provides much better perceptual distance than simple Euclidean

        let deltaL = lab2.l - lab1.l
        let deltaA = lab2.a - lab1.a
        let deltaB = lab2.b - lab1.b

        let c1 = sqrt(lab1.a * lab1.a + lab1.b * lab1.b)
        let c2 = sqrt(lab2.a * lab2.a + lab2.b * lab2.b)
        let deltaC = c2 - c1

        let deltaH = sqrt(deltaA * deltaA + deltaB * deltaB - deltaC * deltaC)

        // Weighting factors for CIEDE2000
        let kL = 1.0, kC = 1.0, kH = 1.0
        let sL = 1.0
        let sC = 1.0 + 0.045 * c1
        let sH = 1.0 + 0.015 * c1

        let rT = -2.0 * sqrt(pow(c1, 7.0) / (pow(c1, 7.0) + pow(25.0, 7.0))) *
                 sin(60.0 * .pi / 180.0 * exp(-pow((c1 - c2) / 2.0, 2.0)))

        let t = deltaH / (kH * sH)

        return sqrt(pow(deltaL / (kL * sL), 2.0) +
                   pow(deltaC / (kC * sC), 2.0) +
                   pow(t, 2.0) +
                   rT * (deltaC / (kC * sC)) * t)
    }
}