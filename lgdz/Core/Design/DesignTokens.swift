import UIKit

/// Color and typography tokens sampled from the design originals (780×1688).
enum DesignTokens {

    enum Color {
        /// App background cream — rgb(253,249,225)
        static let background = UIColor(hex: 0xFDF9E1)
        /// Lime accent used on primary buttons / highlights — rgb(191,223,63)
        static let accent = UIColor(hex: 0xBFDF3F)
        /// Brand yellow (Join button, Live card, liked heart) — rgb(246,188,0)
        static let accentYellow = UIColor(hex: 0xF6BC00)
        /// "Hot" badge orange-red
        static let hot = UIColor(hex: 0xF15A24)
        /// Destructive / report red — rgb(254,91,85)
        static let danger = UIColor(hex: 0xFE5B55)
        /// White card surface
        static let card = UIColor(hex: 0xFFFFFF)
        /// Secondary button / field fill — rgb(244,239,210)
        static let secondaryFill = UIColor(hex: 0xF4EFD2)
        /// Primary dark green text — rgb(61,79,5)
        static let textPrimary = UIColor(hex: 0x3D4F05)
        /// Muted/placeholder text
        static let textMuted = UIColor(hex: 0x9AA07F)
        /// Pure field fill (white-ish) used on input boxes
        static let fieldFill = UIColor(hex: 0xFFFFFF)
        /// Hairline / separators
        static let separator = UIColor(hex: 0xE6E1C5)
    }

    enum Font {
        static func bold(_ designSize: CGFloat) -> UIFont {
            .systemFont(ofSize: DesignMetrics.font(designSize), weight: .bold)
        }
        static func semibold(_ designSize: CGFloat) -> UIFont {
            .systemFont(ofSize: DesignMetrics.font(designSize), weight: .semibold)
        }
        static func medium(_ designSize: CGFloat) -> UIFont {
            .systemFont(ofSize: DesignMetrics.font(designSize), weight: .medium)
        }
        static func regular(_ designSize: CGFloat) -> UIFont {
            .systemFont(ofSize: DesignMetrics.font(designSize), weight: .regular)
        }
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
