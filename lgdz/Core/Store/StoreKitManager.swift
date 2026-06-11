import Foundation
import StoreKit

/// Real App Store consumable IAP via StoreKit 2 (debug/release share the same flow).
@MainActor
final class StoreKitManager {

    static let shared = StoreKitManager()

    enum PurchaseError: LocalizedError {
        case productUnavailable
        case userCancelled
        case pending
        case unverified
        case unknown

        var errorDescription: String? {
            switch self {
            case .productUnavailable: return "This package is unavailable in the App Store."
            case .userCancelled: return nil
            case .pending: return "Purchase is pending approval."
            case .unverified: return "Purchase could not be verified."
            case .unknown: return "Purchase failed. Please try again."
            }
        }
    }

    private(set) var storeProducts: [String: Product] = [:]
    private var updatesTask: Task<Void, Never>?

    private init() {}

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
        Task { await loadProducts() }
    }

    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: IAPProductCatalog.allProductIDs)
            var map: [String: Product] = [:]
            for product in loaded {
                map[product.id] = product
            }
            storeProducts = map
        } catch {
            storeProducts = [:]
        }
    }

    func displayPrice(forProductID id: String) -> String {
        guard let catalog = IAPProductCatalog.product(forID: id),
              let product = storeProducts[catalog.id] else {
            return IAPProductCatalog.product(forID: id)?.fallbackPrice ?? ""
        }
        return product.displayPrice
    }

    func displayPrice(forCoins coins: Int) -> String {
        guard let catalog = IAPProductCatalog.product(forCoins: coins) else { return "" }
        return displayPrice(forProductID: catalog.id)
    }

    func purchase(productID: String) async throws -> Int {
        if storeProducts[productID] == nil {
            await loadProducts()
        }
        guard let product = storeProducts[productID],
              let coins = IAPProductCatalog.coins(forProductID: productID) else {
            throw PurchaseError.productUnavailable
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            defer { Task { await transaction.finish() } }
            _ = AppSession.shared.creditPurchase(coins: coins, transactionID: transaction.id)
            return coins
        case .userCancelled:
            throw PurchaseError.userCancelled
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            guard let transaction = try? checkVerified(update),
                  let coins = IAPProductCatalog.coins(forProductID: transaction.productID) else {
                continue
            }
            if AppSession.shared.creditPurchase(coins: coins, transactionID: transaction.id) {
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.unverified
        case .verified(let safe):
            return safe
        }
    }
}
