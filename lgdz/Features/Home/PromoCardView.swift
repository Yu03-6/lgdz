import UIKit

/// AI Chat / Live promo card: full-bleed cutout background (robot / TV + Hot
/// badge baked in) with title + subtitle overlaid bottom-left and a circular
/// arrow button bottom-right.
final class PromoCardView: UIControl {

    var onTap: (() -> Void)?

    init(bgAsset: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 36.dp
        clipsToBounds = true

        let bg = UIImageView(image: UIImage(named: bgAsset))
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.isUserInteractionEnabled = false
        addSubview(bg)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignTokens.Font.bold(42)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 2
        subtitleLabel.font = DesignTokens.Font.medium(28)
        subtitleLabel.textColor = DesignTokens.Color.textPrimary
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = DesignTokens.Color.textPrimary
        arrow.contentMode = .center
        arrow.backgroundColor = .white
        arrow.layer.cornerRadius = 30.dp
        arrow.layer.masksToBounds = true
        arrow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrow)

        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: topAnchor),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: trailingAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36.dp),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -44.dp),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrow.leadingAnchor, constant: -12.dp),

            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -16.dp),

            arrow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36.dp),
            arrow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36.dp),
            arrow.widthAnchor.constraint(equalToConstant: 60.dp),
            arrow.heightAnchor.constraint(equalToConstant: 60.dp),
        ])

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func tapped() { onTap?() }
}
