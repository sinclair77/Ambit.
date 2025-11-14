import Foundation
import SwiftUI

import UIKit
import SwiftData

@MainActor
class GradientViewModel: ObservableObject {
    @Published var gradients: [SavedGradient] = []
    private var context: ModelContext?

    init(context: ModelContext? = nil) {
        self.context = context
        loadGradients()
    }

    func setContext(_ context: ModelContext) {
        self.context = context
        loadGradients()
    }

    func loadGradients() {
        guard let context = context else { return }
        let descriptor = FetchDescriptor<SavedGradient>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        gradients = (try? context.fetch(descriptor)) ?? []
    }

    func addGradient(name: String, colors: [UIColor], locations: [CGFloat], startPoint: UnitPoint, endPoint: UnitPoint, style: String = "linear", angle: Double = 0) {
        guard let context = context else { return }
        let gradient = SavedGradient(name: name, colors: colors, locations: locations, startPoint: startPoint, endPoint: endPoint, style: style, angle: angle)
        context.insert(gradient)
        loadGradients()
    }

    func deleteGradient(_ gradient: SavedGradient) {
        guard let context = context else { return }
        context.delete(gradient)
        loadGradients()
    }

    func generateRandomGradient() {
        let colors: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue]
        let selected = Array(colors.shuffled().prefix(3))
        addGradient(name: "Sample Gradient", colors: selected, locations: [0, 0.5, 1], startPoint: .leading, endPoint: .trailing)
    }
}
