//
//  ImageProcessor.swift
//  Ambit
//
//  Created by Assistant on 2024
//

import UIKit

enum ImageProcessor {
    static func loadImage(from data: Data) -> UIImage? { UIImage(data: data) }
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
    func color(at point: CGPoint) -> UIColor? {
        guard let cgImage = cgImage else { return nil }

        let x = Int(point.x.rounded())
        let y = Int(point.y.rounded())

        guard x >= 0, y >= 0, x < cgImage.width, y < cgImage.height else { return nil }
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let pixelData = CFDataGetBytePtr(data) else { return nil }

        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow
        let pixelIndex = y * bytesPerRow + x * bytesPerPixel

        let r = CGFloat(pixelData[pixelIndex]) / 255.0
        let g = CGFloat(pixelData[pixelIndex + 1]) / 255.0
        let b = CGFloat(pixelData[pixelIndex + 2]) / 255.0
        let a = CGFloat(pixelData[pixelIndex + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}