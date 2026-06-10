import UIKit

/// One row in the Home "Popular" list: thumbnail + title/meta + avatar stack +
/// Join/Joined pill. White rounded card.
final class PopularCardView: UIView {

    init(item: DemoContent.Popular) {
        super.init(frame: .zero)
        backgroundColor = DesignTokens.Color.card
        layer.cornerRadius = 36.dp

        let thumb = UIImageView(image: UIImage(named: item.image))
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 28.dp
        thumb.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumb)

        let title = UILabel()
        title.text = item.title
        title.font = DesignTokens.Font.bold(38)
        title.textColor = DesignTokens.Color.textPrimary
        title.lineBreakMode = .byTruncatingTail
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        let meta = UILabel()
        meta.text = item.meta
        meta.font = DesignTokens.Font.regular(28)
        meta.textColor = DesignTokens.Color.textMuted
        meta.translatesAutoresizingMaskIntoConstraints = false
        addSubview(meta)

        let stack = AvatarStackView(avatars: item.avatars, extra: item.extra)
        addSubview(stack)

        let join = TagPill(kind: .join, isOn: item.joined)
        join.translatesAutoresizingMaskIntoConstraints = false
        addSubview(join)

        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.dp),
            thumb.topAnchor.constraint(equalTo: topAnchor, constant: 32.dp),
            thumb.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32.dp),
            thumb.widthAnchor.constraint(equalTo: thumb.heightAnchor),

            title.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 28.dp),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.dp),
            title.topAnchor.constraint(equalTo: thumb.topAnchor, constant: 8.dp),

            meta.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            meta.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20.dp),
            meta.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32.dp),

            stack.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: thumb.bottomAnchor),

            join.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.dp),
            join.centerYAnchor.constraint(equalTo: stack.centerYAnchor),
            join.heightAnchor.constraint(equalToConstant: 84.dp),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
