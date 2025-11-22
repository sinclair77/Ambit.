import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    @Published var displayPrice: String?
    @Published var products: [Product] = []

    // Mapping of product id -> localized price string for convenience
    func displayPrice(for productId: String) -> String? {
        products.first(where: { $0.id == productId })?.displayPrice
    }

    private init() {
        Task { await load() }
    }

    func load() async {
        // Replace with your product identifiers from App Store Connect
        let ids = ["com.yourapp.weekly", "com.yourapp.monthly"]
        do {
            let fetched = try await Product.products(for: ids)
            self.products = fetched
            // also populate a simple default displayPrice from the first available product
            if let first = fetched.first {
                displayPrice = first.displayPrice
            }
        } catch {
            print("Store load error: \(error)")
        }
    }

    /// Purchase a product by its product identifier. Returns true on success.
    func purchase(productId: String) async -> Bool {
        do {
            // Ensure we have the product loaded
            if products.isEmpty { await load() }
            guard let product = products.first(where: { $0.id == productId }) else { return false }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                _ = try verification.payloadValue
                UserDefaults.standard.set(true, forKey: "hasUnlockedPro")
                return true
            default:
                return false
            }
        } catch {
            print("Purchase error: \(error)")
            return false
        }
    }
}
