import UIKit

/// Reusable empty state (设计原稿 缺省页): green/white chat-bubble icon,
/// bold title, muted subtitle. Centered in its container.
final class EmptyStateView: UIView {

    init(title: String = "Empty here",
         subtitle: String = "Go explore more interesting\ncontent!") {
        super.init(frame: .zero)

        let icon = UIImageView(image: UIImage(named: "empty_icon"))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignTokens.Font.bold(40)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = DesignTokens.Font.regular(26)
        subtitleLabel.textColor = DesignTokens.Color.textMuted
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: topAnchor),
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 220.dp),
            icon.heightAnchor.constraint(equalToConstant: 180.dp),

            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 40.dp),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.dp),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
