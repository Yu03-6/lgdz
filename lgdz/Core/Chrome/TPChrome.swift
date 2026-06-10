import UIKit

/// Shared chrome helpers: app background and custom navigation bar.
enum TPChrome {

    /// Add the global cream background to a view controller's view.
    /// Background is solid color (sampled rgb(253,249,225)); drawn in code to
    /// avoid importing a flat-color original into runtime assets.
    @discardableResult
    static func addBackground(to view: UIView) -> UIView {
        view.backgroundColor = DesignTokens.Color.background
        return view
    }

    /// A custom back button (uses `icon_back` cutout when available, else a
    /// code-drawn chevron). Returns a configured UIButton.
    static func backButton(target: Any?, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        if let img = UIImage(named: "icon_back") {
            b.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
            b.tintColor = DesignTokens.Color.textPrimary
        }
        b.addTarget(target, action: action, for: .touchUpInside)
        return b
    }
}

extension UIViewController {
    /// Hide the system navigation bar; screens render a custom top bar.
    func hideSystemNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
