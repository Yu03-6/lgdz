import UIKit

/// Converts design-canvas units (base 780×1688) into runtime points.
///
/// Horizontal sizes scale by `layoutWidth / 780`. On iPad the layout width is
/// derived from the key window (not `UIScreen.main`, which can be wider than
/// the compatibility window and causes overlapping UI) and capped so content
/// stays phone-proportioned and centered.
enum DesignMetrics {
    static let baseWidth: CGFloat = 780
    static let baseHeight: CGFloat = 1688

    /// Max content column width on iPad (points). Keeps the 780 design readable
    /// without stretching edge-to-edge on large screens.
    static let padMaxContentWidth: CGFloat = 520

    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    /// Width used for `.dp` / scale conversion — matches the visible content column.
    static var layoutWidth: CGFloat {
        let windowWidth = activeWindowWidth ?? UIScreen.main.bounds.width
        if isPad {
            return min(windowWidth, padMaxContentWidth)
        }
        return windowWidth
    }

    static var screenWidth: CGFloat { layoutWidth }
    static var screenHeight: CGFloat { activeWindowHeight ?? UIScreen.main.bounds.height }

    /// Horizontal scale factor from design canvas to current layout width.
    static var scale: CGFloat { layoutWidth / baseWidth }

    /// Scale a design-space value (x, width, height, radius, spacing) to points.
    static func x(_ v: CGFloat) -> CGFloat { v * scale }

    /// Alias kept for readability at call sites that scale widths/sizes.
    static func w(_ v: CGFloat) -> CGFloat { v * scale }

    /// Scale a vertical design value to points using the width-based scale.
    static func y(_ v: CGFloat) -> CGFloat { v * scale }

    /// Scale a font size from the design canvas to points.
    static func font(_ v: CGFloat) -> CGFloat { (v * scale).rounded() }

    /// Wrap a root controller in a centered phone-width column on iPad.
    static func wrapForPadIfNeeded(_ controller: UIViewController) -> UIViewController {
        guard isPad else { return controller }
        return PhoneLayoutHostViewController(content: controller)
    }

    private static var activeWindowWidth: CGFloat? {
        activeWindowBounds?.width
    }

    private static var activeWindowHeight: CGFloat? {
        activeWindowBounds?.height
    }

    private static var activeWindowBounds: CGRect? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .bounds
    }
}

extension CGFloat {
    /// Sugar: `40.dp` converts a design-canvas value to points.
    var dp: CGFloat { DesignMetrics.x(self) }
}

extension Int {
    var dp: CGFloat { DesignMetrics.x(CGFloat(self)) }
}

extension Double {
    var dp: CGFloat { DesignMetrics.x(CGFloat(self)) }
}
