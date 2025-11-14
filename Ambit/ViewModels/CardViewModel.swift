import Foundation
import SwiftUI

import UIKit
import SwiftData

@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [SavedCard] = []
    private var context: ModelContext?

    init(context: ModelContext? = nil) {
        self.context = context
        loadCards()
    }

    func setContext(_ context: ModelContext) {
        self.context = context
        loadCards()
    }

    func loadCards() {
        guard let context = context else { return }
        let descriptor = FetchDescriptor<SavedCard>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        cards = (try? context.fetch(descriptor)) ?? []
    }

    func addCard(image: UIImage) {
        guard let context = context, let data = image.jpegData(compressionQuality: 0.8) else { return }
        let card = SavedCard(imageData: data)
        context.insert(card)
        loadCards()
    }

    func deleteCard(_ card: SavedCard) {
        guard let context = context else { return }
        context.delete(card)
        loadCards()
    }

    func duplicateCard(_ card: SavedCard) {
        guard let context = context else { return }
        let copy = SavedCard(imageData: card.imageData,
                             timestamp: Date(),
                             isFavorite: card.isFavorite)
        context.insert(copy)
        loadCards()
    }

    func generateRandomCard() {
        let colors: [UIColor] = [.systemPink, .systemTeal, .systemIndigo]
        let image = UIImage(color: colors.randomElement() ?? .systemGray, size: CGSize(width: 100, height: 60))
        addCard(image: image)
    }
}
