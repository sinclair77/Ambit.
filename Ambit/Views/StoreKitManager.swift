import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    @Published var displayPrice: String?

    private init() {
        Task { await load() }
    }

    func load() async {
        // TODO: Replace with your real product IDs
        let ids = ["com.yourapp.pro"]
        do {
            let products = try await Product.products(for: ids)
            if let pro = products.first {
                displayPrice = pro.displayPrice
            }
        } catch {
            print("Store load error: \(error)")
        }
    }

    func purchasePro() async -> Bool {
        do {
            // TODO: Replace with your real product retrieval
            let products = try await Product.products(for: ["com.yourapp.pro"])
            guard let pro = products.first else { return false }
            let result = try await pro.purchase()
            switch result {
            case .success(let verification):
                _ = try verification.payloadValue
                UserDefaults.standard.set(true, forKey: "isPro")
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
