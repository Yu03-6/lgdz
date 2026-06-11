import Foundation

/// Consumable coin packages shown on the recharge screen.
/// Product ids must match App Store Connect entries (`LT-vixz.txt`).
enum IAPProductCatalog {

    struct Product: Equatable {
        let id: String
        let coins: Int
        let fallbackPrice: String
    }

    static let products: [Product] = [
        Product(id: "jorgghlowkrhcycu", coins: 400, fallbackPrice: "$0.99"),
        Product(id: "igxfhfziolnhshha", coins: 800, fallbackPrice: "$1.99"),
        Product(id: "kmqtyxkpoadhabuc", coins: 2450, fallbackPrice: "$4.99"),
        Product(id: "poaqosgjjycbcnfo", coins: 5150, fallbackPrice: "$9.99"),
        Product(id: "tycsxblqihbhagmj", coins: 10800, fallbackPrice: "$19.99"),
        Product(id: "fvjzjqbbflwfdwqh", coins: 29400, fallbackPrice: "$49.99"),
        Product(id: "syjpazmbluoepbcz", coins: 63700, fallbackPrice: "$99.99"),
    ]

    /// Recharge grid rows: 3 + 3 + 1 tiles (`LT-vixz.txt` price tiers).
    static let rechargeGridRows: [[String]] = [
        ["jorgghlowkrhcycu", "igxfhfziolnhshha", "kmqtyxkpoadhabuc"],
        ["poaqosgjjycbcnfo", "tycsxblqihbhagmj", "fvjzjqbbflwfdwqh"],
        ["syjpazmbluoepbcz"],
    ]

    static var allProductIDs: [String] { products.map(\.id) }

    static var rechargeGridProducts: [Product] {
        rechargeGridRows.flatMap { row in row.compactMap { product(forID: $0) } }
    }

    static func product(forID id: String) -> Product? {
        products.first { $0.id == id }
    }

    static func product(forCoins coins: Int) -> Product? {
        products.first { $0.coins == coins }
    }

    static func coins(forProductID id: String) -> Int? {
        product(forID: id)?.coins
    }
}
