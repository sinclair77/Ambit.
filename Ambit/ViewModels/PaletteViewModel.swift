import UIKit
import SwiftData

@MainActor
class PaletteViewModel: ObservableObject {
    @Published var palettes: [SavedPalette] = []
    private var context: ModelContext?

    init(context: ModelContext? = nil) {
        self.context = context
        loadPalettes()
    }

    func setContext(_ context: ModelContext) {
        self.context = context
        loadPalettes()
    }

    func loadPalettes() {
        guard let context = context else { return }
        let descriptor = FetchDescriptor<SavedPalette>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        palettes = (try? context.fetch(descriptor)) ?? []
    }

    func addPaletteFromImage(_ image: UIImage) {
        // Use ColorExtractor to get prominent colors from image
        let palette = ColorPaletteGenerator.generatePalette(from: image, style: .adaptive, count: 5)
        self.addPalette(name: "From Image", colors: palette.colors, image: image)
    }

    func addPalette(name: String, colors: [UIColor], image: UIImage? = nil) {
        guard let context = context else { return }
        let palette = SavedPalette(name: name, image: image, colors: colors)
        context.insert(palette)
        loadPalettes()
    }

    func deletePalette(_ palette: SavedPalette) {
        guard let context = context else { return }
        context.delete(palette)
        loadPalettes()
    }

    func generateRandomPalette() {
        let randomImage = UIImage(color: .systemBlue, size: CGSize(width: 100, height: 100))
        let palette = ColorPaletteGenerator.generatePalette(from: randomImage, style: .adaptive, count: 5)
        addPalette(name: palette.name, colors: palette.colors)
    }
}

// Helper to create a solid color UIImage
extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}
