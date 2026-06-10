import UIKit

/// Persists user-picked post photos under the account cache directory.
/// Activity.image uses keys prefixed with `local:` for these files.
enum PostImageStore {
    static let localPrefix = "local:"

    static func isLocalKey(_ key: String) -> Bool {
        key.hasPrefix(localPrefix)
    }

    @discardableResult
    static func save(_ image: UIImage, accountID: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let id = UUID().uuidString
        let url = fileURL(for: id, accountID: accountID)
        do {
            try FileManager.default.createDirectory(
                at: directory(for: accountID),
                withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
            return localPrefix + id
        } catch {
            return nil
        }
    }

    static func resolveImage(named key: String) -> UIImage? {
        guard !key.isEmpty else { return nil }
        if isLocalKey(key) {
            guard let accountID = AppSession.shared.current?.id else { return nil }
            let id = String(key.dropFirst(localPrefix.count))
            let url = fileURL(for: id, accountID: accountID)
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(named: key)
    }

    static func deleteImage(named key: String, accountID: String) {
        guard isLocalKey(key) else { return }
        let id = String(key.dropFirst(localPrefix.count))
        let url = fileURL(for: id, accountID: accountID)
        try? FileManager.default.removeItem(at: url)
    }

    static func deleteAll(accountID: String) {
        let dir = directory(for: accountID)
        try? FileManager.default.removeItem(at: dir)
    }

    private static func directory(for accountID: String) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("post-images/\(accountID)", isDirectory: true)
    }

    private static func fileURL(for id: String, accountID: String) -> URL {
        directory(for: accountID).appendingPathComponent("\(id).jpg")
    }
}
