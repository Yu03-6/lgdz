import UIKit

/// Circular image view that loads an asset and clips to a circle.
final class CircleImageView: UIImageView {
    init(asset: String?) {
        super.init(frame: .zero)
        if let asset { image = UIImage(named: asset) }
        contentMode = .scaleAspectFill
        clipsToBounds = true
        backgroundColor = DesignTokens.Color.secondaryFill
    }

    /// Applies a bundled asset or initials placeholder when no asset is set.
    func applyAccountAvatar(asset: String?, displayName: String) {
        if let asset, UIImage(named: asset) != nil {
            image = UIImage(named: asset)
        } else {
            image = AvatarHelper.initialsImage(for: displayName)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}

/// Generates a circular initials avatar (Apple Sign In does not provide profile photos).
enum AvatarHelper {
    static func initialsImage(for name: String, diameter: CGFloat = 170) -> UIImage {
        let initials = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
        let text = initials.isEmpty ? "?" : initials
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            DesignTokens.Color.accent.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: diameter * 0.36, weight: .bold),
                .foregroundColor: UIColor.white,
            ]
            let measured = (text as NSString).size(withAttributes: attrs)
            let origin = CGPoint(
                x: (size.width - measured.width) / 2,
                y: (size.height - measured.height) / 2)
            (text as NSString).draw(at: origin, withAttributes: attrs)
        }
    }
}

/// Section header: bold title on the left, optional "More >" on the right.
final class SectionHeader: UIView {
    var onMore: (() -> Void)?
    private let titleLabel = UILabel()
    private weak var moreButton: UIButton?

    init(title: String, showMore: Bool = true, titleSize: CGFloat = 46) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = DesignTokens.Font.bold(titleSize)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        if showMore {
            let more = UIButton(type: .system)
            more.setTitle(L10n.more, for: .normal)
            more.setTitleColor(DesignTokens.Color.textMuted, for: .normal)
            more.titleLabel?.font = DesignTokens.Font.medium(28)
            let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(24), weight: .semibold)
            more.setImage(UIImage(systemName: "chevron.right", withConfiguration: cfg), for: .normal)
            more.tintColor = DesignTokens.Color.textMuted
            more.semanticContentAttribute = .forceRightToLeft
            more.addTarget(self, action: #selector(tapMore), for: .touchUpInside)
            more.translatesAutoresizingMaskIntoConstraints = false
            addSubview(more)
            moreButton = more
            NSLayoutConstraint.activate([
                more.trailingAnchor.constraint(equalTo: trailingAnchor),
                more.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            ])
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func refreshMoreTitle() {
        moreButton?.setTitle(L10n.more, for: .normal)
    }

    @objc private func tapMore() { onMore?() }
}

/// Overlapping avatar row + "+N" trailing chip.
final class AvatarStackView: UIView {
    init(avatars: [String], extra: Int, diameter: CGFloat = 56, overlap: CGFloat = 18) {
        super.init(frame: .zero)
        let d = diameter.dp
        let ov = overlap.dp
        var x: CGFloat = 0
        for asset in avatars {
            let av = CircleImageView(asset: asset)
            av.layer.borderWidth = 2
            av.layer.borderColor = UIColor.white.cgColor
            av.frame = CGRect(x: x, y: 0, width: d, height: d)
            addSubview(av)
            x += d - ov
        }
        if extra > 0 {
            let chip = UILabel()
            chip.text = "+\(extra)"
            chip.font = DesignTokens.Font.semibold(24)
            chip.textColor = DesignTokens.Color.textPrimary
            chip.textAlignment = .center
            chip.backgroundColor = UIColor(hex: 0xEDEDED)
            chip.layer.cornerRadius = d / 2
            chip.layer.masksToBounds = true
            chip.layer.borderWidth = 2
            chip.layer.borderColor = UIColor.white.cgColor
            chip.frame = CGRect(x: x, y: 0, width: d, height: d)
            addSubview(chip)
            x += d
        }
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: x).isActive = true
        heightAnchor.constraint(equalToConstant: d).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Small pill (Join / Joined / Following / Follow) with togglable state.
final class TagPill: UIButton {
    enum Kind { case join, follow }
    /// Live room: text-only Follow/Following, yellow vs cream, centered label.
    enum FollowStyle { case standard, live }

    private let kind: Kind
    private let followStyle: FollowStyle
    private(set) var isOn: Bool = false
    var onToggle: ((Bool) -> Void)?

    init(kind: Kind, isOn: Bool, followStyle: FollowStyle = .standard) {
        self.kind = kind
        self.followStyle = followStyle
        self.isOn = isOn
        super.init(frame: .zero)
        titleLabel?.font = DesignTokens.Font.semibold(30)
        if kind == .follow, followStyle == .live {
            titleLabel?.textAlignment = .center
            contentHorizontalAlignment = .center
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 36.dp, bottom: 0, right: 36.dp)
        } else {
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 44.dp, bottom: 0, right: 44.dp)
        }
        addTarget(self, action: #selector(tap), for: .touchUpInside)
        applyState(animated: false)
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange),
            name: .languageDidChange, object: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func languageDidChange() {
        applyState(animated: false)
    }

    func setOn(_ on: Bool, animated: Bool) {
        guard isOn != on else { return }
        isOn = on
        applyState(animated: animated)
    }

    private func applyState(animated: Bool) {
        let updates = { self.updateAppearance() }
        if animated {
            InteractionAnimation.pillToggle(on: self, updates: updates)
        } else {
            updates()
        }
    }

    private func updateAppearance() {
        switch kind {
        case .join:
            if isOn {
                setTitle(L10n.joined, for: .normal)
                backgroundColor = DesignTokens.Color.secondaryFill
                setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
            } else {
                setTitle(L10n.join, for: .normal)
                backgroundColor = DesignTokens.Color.accentYellow
                setTitleColor(.white, for: .normal)
            }
        case .follow:
            if isOn {
                setTitle(L10n.following, for: .normal)
                backgroundColor = DesignTokens.Color.secondaryFill
                setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
                setImage(nil, for: .normal)
            } else if followStyle == .live {
                setTitle(L10n.follow.trimmingCharacters(in: .whitespaces), for: .normal)
                backgroundColor = DesignTokens.Color.accentYellow
                setTitleColor(.white, for: .normal)
                setImage(nil, for: .normal)
            } else {
                setTitle(L10n.follow, for: .normal)
                backgroundColor = DesignTokens.Color.textPrimary
                setTitleColor(.white, for: .normal)
                let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(28), weight: .bold)
                setImage(UIImage(systemName: "plus", withConfiguration: cfg), for: .normal)
                tintColor = .white
            }
        }
    }

    @objc private func tap() {
        let next = !isOn
        setOn(next, animated: true)
        onToggle?(next)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}
