import Foundation

/// Per-account key-isolated storage backed by UserDefaults.
/// Keys are namespaced by the owning account id so multiple demo accounts in
/// one process never collide. UI-only persistence (no remote sync).
final class AccountScopedStorage {
    private let accountID: String
    private let defaults = UserDefaults.standard

    init(accountID: String) {
        self.accountID = accountID
    }

    private func scoped(_ key: String) -> String { "acct.\(accountID).\(key)" }

    func set(_ value: Any?, for key: String) {
        defaults.set(value, forKey: scoped(key))
    }

    func int(_ key: String, default def: Int = 0) -> Int {
        defaults.object(forKey: scoped(key)) == nil ? def : defaults.integer(forKey: scoped(key))
    }

    func bool(_ key: String, default def: Bool = false) -> Bool {
        defaults.object(forKey: scoped(key)) == nil ? def : defaults.bool(forKey: scoped(key))
    }

    func string(_ key: String) -> String? { defaults.string(forKey: scoped(key)) }

    func stringArray(_ key: String) -> [String]? { defaults.stringArray(forKey: scoped(key)) }

    func data(_ key: String) -> Data? { defaults.data(forKey: scoped(key)) }

    /// Removes all persisted keys for the given account id.
    static func wipe(accountID: String) {
        let prefix = "acct.\(accountID)."
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}
