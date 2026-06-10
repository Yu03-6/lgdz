import UIKit

/// Rounded "pill" button used across login/forms.
/// Style mirrors the design cutouts: green primary, cream secondary.
final class PillButton: UIButton {

    enum Style {
        case primary       // lime accent fill, dark label
        case secondary     // cream fill, dark label
        case apple         // lime fill + apple glyph, dark label
    }

    private let style: Style

    init(style: Style, title: String) {
        self.style = style
        super.init(frame: .zero)
        configure(title: title)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure(title: String) {
        titleLabel?.font = DesignTokens.Font.bold(30)
        setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
        setTitle(title, for: .normal)

        switch style {
        case .primary, .apple:
            backgroundColor = DesignTokens.Color.accent
        case .secondary:
            backgroundColor = DesignTokens.Color.secondaryFill
        }

        if style == .apple {
            let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34), weight: .bold)
            setImage(UIImage(systemName: "applelogo", withConfiguration: cfg), for: .normal)
            tintColor = DesignTokens.Color.textPrimary
            // gap between glyph and label
            let gap: CGFloat = 14.dp
            configuration = nil
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -gap, bottom: 0, right: gap)
        }
    }

    /// Corner radius in design-canvas units (matches cutout ≈ 32).
    var designCornerRadius: CGFloat = 32

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = DesignMetrics.x(designCornerRadius)
        layer.masksToBounds = true
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.85 : 1.0 }
    }
}
