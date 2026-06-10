import UIKit

/// Custom top bar: back chevron at left, optional centered title.
/// System nav bar is hidden per 架构需求.md §5.
final class NavHeader: UIView {

    let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private var onBack: (() -> Void)?

    /// Standard header height in design units (below status bar).
    static let designHeight: CGFloat = 110

    init(title: String?, onBack: (() -> Void)?) {
        super.init(frame: .zero)
        self.onBack = onBack
        backgroundColor = .clear

        if let back = UIImage(named: "icon_back") {
            backButton.setImage(back.withRenderingMode(.alwaysOriginal), for: .normal)
            backButton.imageView?.contentMode = .scaleAspectFit
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(40), weight: .semibold)
            backButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
            backButton.tintColor = DesignTokens.Color.textPrimary
        }
        backButton.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)

        titleLabel.text = title
        titleLabel.font = DesignTokens.Font.bold(34)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.dp),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 60.dp),
            backButton.heightAnchor.constraint(equalToConstant: 60.dp),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8.dp),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func hideBack() { backButton.isHidden = true }

    @objc private func tapBack() { onBack?() }
}
