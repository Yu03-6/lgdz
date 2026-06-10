import Foundation

extension Notification.Name {
    /// Posted when wallet balance changes. `userInfo`: `WalletInfoKey.coins`.
    static let walletBalanceDidChange = Notification.Name("wallet.balanceDidChange")
    /// Posted when a new account is activated for the current process session.
    static let accountDidActivate = Notification.Name("session.accountDidActivate")
}

enum WalletInfoKey {
    static let coins = "coins"
}

/// Represents a locally-registered or signed-in account.
struct Account: Codable, Equatable {
    var id: String
    var email: String
    var password: String
    var displayName: String
    var bio: String?
    var isApple: Bool
    /// Stable Sign in with Apple user identifier.
    var appleUserId: String?
    /// Bundled asset name for avatar; nil → initials placeholder in UI.
    var avatarAsset: String?

    init(id: String = UUID().uuidString,
         email: String,
         password: String,
         displayName: String,
         bio: String? = nil,
         isApple: Bool = false,
         appleUserId: String? = nil,
         avatarAsset: String? = nil) {
        self.id = id
        self.email = email
        self.password = password
        self.displayName = displayName
        self.bio = bio
        self.isApple = isApple
        self.appleUserId = appleUserId
        self.avatarAsset = avatarAsset
    }
}

/// Process-scoped session.
///
/// Per 架构需求.md §6: login is real (local). A cold start always returns to the
/// login page (the current account lives only in-process), while the registered
/// account list persists so demo / created accounts can sign back in.
final class AppSession {
    static let shared = AppSession()

    /// Built-in test account with rich demo interactions (§6).
    static let testAccountEmail = "lgdz@qq.com"
    static let testAccountDisplayName = "Harper"
    /// Legacy demo default before 2026-06-10 balance adjustment.
    private static let legacyTestWalletDefault = 609
    static let testAccountWalletDefault = 50

    private let accountsKey = "registered.accounts"
    private let defaults = UserDefaults.standard

    /// Current signed-in account; nil at cold start (forces login).
    private(set) var current: Account?

    /// Coin balance for the current account (in-process demo wallet).
    private(set) var coins: Int = 0

    private(set) var storage: AccountScopedStorage?

    /// True for the seeded lgdz@qq.com test account (rich chat/social/post data).
    var isTestAccount: Bool {
        current?.email.lowercased() == Self.testAccountEmail
    }

    /// Newly registered or Apple-signed-in accounts (empty social/chat state).
    var isNewUserAccount: Bool { current != nil && !isTestAccount }

    private init() {
        seedDemoAccountIfNeeded()
    }

    // MARK: Registered accounts (persisted)

    private func loadAccounts() -> [Account] {
        guard let data = defaults.data(forKey: accountsKey),
              let list = try? JSONDecoder().decode([Account].self, from: data) else { return [] }
        return list
    }

    private func saveAccounts(_ list: [Account]) {
        if let data = try? JSONEncoder().encode(list) {
            defaults.set(data, forKey: accountsKey)
        }
    }

    private func seedDemoAccountIfNeeded() {
        var list = loadAccounts()
        // Migrate legacy demo email from earlier builds.
        if let idx = list.firstIndex(where: { $0.email.lowercased() == "lgdz@gmail.com" }) {
            var acct = list[idx]
            acct.email = Self.testAccountEmail
            list[idx] = acct
            saveAccounts(list)
        }
        if !list.contains(where: { $0.email.lowercased() == Self.testAccountEmail }) {
            list.append(Account(
                email: Self.testAccountEmail,
                password: "lgdz12345",
                displayName: Self.testAccountDisplayName,
                bio: "Dog walking lover · weekend park regular",
                avatarAsset: "content_dog1"))
            saveAccounts(list)
        } else if let idx = list.firstIndex(where: { $0.email.lowercased() == Self.testAccountEmail }),
                  ["Lgdz", "Vivi"].contains(list[idx].displayName) {
            list[idx].displayName = Self.testAccountDisplayName
            saveAccounts(list)
        }
    }

    // MARK: Auth

    enum AuthError: Error { case notFound, wrongPassword, emailTaken }
    enum DeleteAccountError: Error { case testAccountProtected, notSignedIn }

    func register(email: String, password: String, displayName: String, bio: String?) throws -> Account {
        var list = loadAccounts()
        if list.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            throw AuthError.emailTaken
        }
        let acct = Account(email: email, password: password, displayName: displayName, bio: bio)
        list.append(acct)
        saveAccounts(list)
        return acct
    }

    func signIn(email: String, password: String) throws -> Account {
        let list = loadAccounts()
        guard let acct = list.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            throw AuthError.notFound
        }
        guard acct.password == password else { throw AuthError.wrongPassword }
        return acct
    }

    /// Real Sign in with Apple — keyed by Apple user id; name/email only on first authorization.
    func signInWithApple(appleUserId: String, email: String?, fullName: PersonNameComponents?) -> Account {
        var list = loadAccounts()
        if let idx = list.firstIndex(where: { $0.appleUserId == appleUserId }) {
            var acct = list[idx]
            applyAppleProfile(to: &acct, email: email, fullName: fullName)
            list[idx] = acct
            saveAccounts(list)
            return acct
        }
        let resolvedEmail = email ?? "apple_\(appleUserId.prefix(8))@privaterelay.appleid.com"
        let displayName = formattedAppleName(from: fullName)
        let acct = Account(
            email: resolvedEmail,
            password: "",
            displayName: displayName,
            bio: nil,
            isApple: true,
            appleUserId: appleUserId)
        list.append(acct)
        saveAccounts(list)
        return acct
    }

    private func applyAppleProfile(to account: inout Account, email: String?, fullName: PersonNameComponents?) {
        if let email, !email.isEmpty { account.email = email }
        if let fullName {
            let name = formattedAppleName(from: fullName)
            if !name.isEmpty, name != "Apple User" { account.displayName = name }
        }
    }

    private func formattedAppleName(from components: PersonNameComponents?) -> String {
        guard let components else { return "Apple User" }
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        let formatted = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
        return formatted.isEmpty ? "Apple User" : formatted
    }

    /// Activate an account for the current process session.
    func activate(_ account: Account) {
        current = account
        storage = AccountScopedStorage(accountID: account.id)
        let isTest = account.email.lowercased() == Self.testAccountEmail
        let walletDefault = isTest ? Self.testAccountWalletDefault : 0
        coins = storage?.int("wallet.coins", default: walletDefault) ?? walletDefault
        if isTest && coins == Self.legacyTestWalletDefault {
            coins = walletDefault
            storage?.set(coins, for: "wallet.coins")
        }
        blockedNames = storage?.stringArray("blocked.names") ?? []
        DemoContent.loadUserContentForCurrentAccount()
        NotificationCenter.default.post(name: .accountDidActivate, object: nil)
    }

    func signOut() {
        current = nil
        storage = nil
        coins = 0
        blockedNames = []
        DemoContent.clearSessionContent()
    }

    /// Permanently removes the signed-in account and its local data.
    /// The built-in test account cannot be deleted.
    func deleteCurrentAccount() throws {
        guard let account = current else { throw DeleteAccountError.notSignedIn }
        guard !isTestAccount else { throw DeleteAccountError.testAccountProtected }

        var list = loadAccounts()
        list.removeAll { $0.id == account.id }
        saveAccounts(list)

        AccountScopedStorage.wipe(accountID: account.id)
        PostImageStore.deleteAll(accountID: account.id)
        signOut()
    }

    func updateCurrentAccount(_ account: Account) {
        current = account
        var list = loadAccounts()
        if let idx = list.firstIndex(where: { $0.id == account.id }) {
            list[idx] = account
            saveAccounts(list)
        }
    }

    // MARK: Blacklist (per-account, demo)

    private(set) var blockedNames: [String] = []

    func block(_ name: String) {
        guard !blockedNames.contains(name) else { return }
        blockedNames.append(name)
        storage?.set(blockedNames, for: "blocked.names")
    }

    func unblock(_ name: String) {
        blockedNames.removeAll { $0 == name }
        storage?.set(blockedNames, for: "blocked.names")
    }

    // MARK: Wallet

    /// Attempt to spend coins. Returns false if balance is insufficient.
    @discardableResult
    func spend(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        storage?.set(coins, for: "wallet.coins")
        notifyBalanceChanged()
        return true
    }

    func topUp(_ amount: Int) {
        coins += amount
        storage?.set(coins, for: "wallet.coins")
        notifyBalanceChanged()
    }

    private func notifyBalanceChanged() {
        NotificationCenter.default.post(
            name: .walletBalanceDidChange,
            object: nil,
            userInfo: [WalletInfoKey.coins: coins])
    }

    func canAfford(_ amount: Int) -> Bool { coins >= amount }
}
