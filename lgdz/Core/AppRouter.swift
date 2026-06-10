import UIKit

/// Owns the window root and switches between the login flow and the main tab
/// bar. Cold start always begins at login (see AppSession).
final class AppRouter {
    static let shared = AppRouter()
    weak var window: UIWindow?

    func makeRoot() -> UIViewController {
        // Cold start → login flow (§6: 冷启动必回登录页).
        let nav = UINavigationController(rootViewController: LoginSelectionViewController())
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    func enterMainApp() {
        let tab = MainTabBarController()
        transition(to: tab)
    }

    func logout() {
        AppSession.shared.signOut()
        let nav = UINavigationController(rootViewController: LoginSelectionViewController())
        nav.setNavigationBarHidden(true, animated: false)
        transition(to: nav)
    }

    private func transition(to root: UIViewController) {
        guard let window = window else { return }
        window.rootViewController = root
        UIView.transition(with: window, duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {}, completion: nil)
    }
}
