import UIKit

/// Converts design-canvas units (base 780×1688) into runtime points.
///
/// The design canvas width is 780. Horizontal sizes/positions scale by
/// `screenWidth / 780`. Vertical positions generally reuse the same scale so
/// proportions are preserved across devices; callers that need to honor the
/// safe area use the dedicated helpers below.
enum DesignMetrics {
    static let baseWidth: CGFloat = 780
    static let baseHeight: CGFloat = 1688

    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }

    /// Horizontal scale factor from design canvas to current screen width.
    static var scale: CGFloat { screenWidth / baseWidth }

    /// Scale a design-space value (x, width, height, radius, spacing) to points.
    static func x(_ v: CGFloat) -> CGFloat { v * scale }

    /// Alias kept for readability at call sites that scale widths/sizes.
    static func w(_ v: CGFloat) -> CGFloat { v * scale }

    /// Scale a vertical design value to points using the width-based scale.
    static func y(_ v: CGFloat) -> CGFloat { v * scale }

    /// Scale a font size from the design canvas to points.
    static func font(_ v: CGFloat) -> CGFloat { (v * scale).rounded() }
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
