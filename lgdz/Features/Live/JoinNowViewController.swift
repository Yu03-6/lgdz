import UIKit

/// Screen 12 — Join Now / event detail (立即参与). Hero image with title
/// overlay, white info sheet (Introduction, Time, Address, description) and a
/// Join Now button.
final class JoinNowViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIView()
    private let joinButton = PillButton(style: .primary, title: "Join Now")
    private var hasJoined = false

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func buildLayout() {
        let hero = UIImageView(image: UIImage(named: "joinnow_hero"))
        hero.contentMode = .scaleAspectFill
        hero.clipsToBounds = true
        hero.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hero)

        let back = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(44), weight: .semibold)
        back.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let heroTitle = UILabel()
        heroTitle.text = "Spring Leash & Meet"
        heroTitle.font = .systemFont(ofSize: DesignMetrics.font(46), weight: .black)
        heroTitle.textColor = .white
        heroTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heroTitle)

        let heroSub = UILabel()
        heroSub.text = "Come join us!"
        heroSub.font = DesignTokens.Font.bold(34)
        heroSub.textColor = .white
        heroSub.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heroSub)

        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        let sheet = UIView()
        sheet.backgroundColor = DesignTokens.Color.card
        sheet.layer.cornerRadius = 44.dp
        sheet.layer.shadowColor = UIColor.black.cgColor
        sheet.layer.shadowOpacity = 0.06
        sheet.layer.shadowRadius = 16.dp
        sheet.layer.shadowOffset = CGSize(width: 0, height: 4.dp)
        sheet.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(sheet)

        let intro = makeTag("Introduction")
        let time = makeInfoRow(asset: "joinnow_time", fallbackIcon: "clock.fill",
                               title: "Time:", value: "6.15 - 7.15")
        let address = makeInfoRow(asset: "joinnow_address", fallbackIcon: "mappin.circle.fill",
                                  title: "Address:", value: "Bear Creek Dog Park")

        let desc = UILabel()
        desc.numberOfLines = 0
        desc.font = DesignTokens.Font.regular(32)
        desc.textColor = DesignTokens.Color.textPrimary
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 8.dp
        desc.attributedText = NSAttributedString(
            string: """
            Spring is here! Bring your dog and join us for a walk! The "Spring Dog Walking Social" is an event where you can relax, stroll, and meet new friends.

            Walk on your leash, naturally interact with other pet owners along the way, share pet stories, and easily build genuine friendships.
            """,
            attributes: [.paragraphStyle: para])
        desc.translatesAutoresizingMaskIntoConstraints = false

        joinButton.designCornerRadius = 36
        joinButton.addTarget(self, action: #selector(tapJoin), for: .touchUpInside)
        joinButton.translatesAutoresizingMaskIntoConstraints = false

        [intro, time, address, desc, joinButton].forEach { sheet.addSubview($0) }

        let sheetTopOverlap: CGFloat = 60.dp
        let heroHeight: CGFloat = 780.dp

        NSLayoutConstraint.activate([
            hero.topAnchor.constraint(equalTo: view.topAnchor),
            hero.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hero.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hero.heightAnchor.constraint(equalToConstant: heroHeight),

            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.dp),

            heroTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            heroTitle.bottomAnchor.constraint(equalTo: heroSub.topAnchor, constant: -12.dp),
            heroSub.leadingAnchor.constraint(equalTo: heroTitle.leadingAnchor),
            heroSub.bottomAnchor.constraint(equalTo: scroll.topAnchor, constant: -48.dp),

            scroll.topAnchor.constraint(equalTo: view.topAnchor, constant: heroHeight - sheetTopOverlap),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),

            sheet.topAnchor.constraint(equalTo: content.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 32.dp),
            sheet.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -32.dp),
            sheet.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -40.dp),

            intro.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 44.dp),
            intro.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 40.dp),
            intro.heightAnchor.constraint(equalToConstant: 84.dp),

            time.topAnchor.constraint(equalTo: intro.bottomAnchor, constant: 40.dp),
            time.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 40.dp),
            time.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -40.dp),

            address.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 28.dp),
            address.leadingAnchor.constraint(equalTo: time.leadingAnchor),
            address.trailingAnchor.constraint(equalTo: time.trailingAnchor),

            desc.topAnchor.constraint(equalTo: address.bottomAnchor, constant: 36.dp),
            desc.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 40.dp),
            desc.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -40.dp),

            joinButton.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 48.dp),
            joinButton.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 40.dp),
            joinButton.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -40.dp),
            joinButton.heightAnchor.constraint(equalToConstant: 120.dp),
            joinButton.bottomAnchor.constraint(equalTo: sheet.bottomAnchor, constant: -44.dp),
        ])
    }

    private func makeTag(_ text: String) -> UIView {
        let l = PaddingTag()
        l.text = text
        l.font = DesignTokens.Font.bold(32)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = DesignTokens.Color.accentYellow
        l.layer.cornerRadius = 42.dp
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeInfoRow(asset: String, fallbackIcon: String, title: String, value: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIImageView()
        if let img = UIImage(named: asset) {
            dot.image = img.withRenderingMode(.alwaysOriginal)
        } else {
            dot.image = UIImage(systemName: fallbackIcon)
            dot.tintColor = DesignTokens.Color.accent
        }
        dot.contentMode = .scaleAspectFit
        dot.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(dot)

        let t = UILabel()
        t.font = DesignTokens.Font.bold(34)
        t.textColor = DesignTokens.Color.textPrimary
        t.text = title
        t.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(t)

        let v = UILabel()
        v.font = DesignTokens.Font.regular(34)
        v.textColor = DesignTokens.Color.textPrimary
        v.text = value
        v.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(v)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 56.dp),
            dot.heightAnchor.constraint(equalToConstant: 56.dp),
            row.heightAnchor.constraint(equalToConstant: 56.dp),
            t.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 18.dp),
            t.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.leadingAnchor.constraint(equalTo: t.trailingAnchor, constant: 8.dp),
            v.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            v.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
        ])
        return row
    }

    @objc private func tapJoin() {
        guard !hasJoined else { return }
        hasJoined = true
        applyJoinedButtonStyle()

        let popup = ReminderPopupController(
            title: "Joined!",
            bodyParts: [("See you at the park 🐶", false)],
            buttonTitle: "OK")
        popup.present(over: self)
    }

    private func applyJoinedButtonStyle() {
        joinButton.isEnabled = false
        joinButton.backgroundColor = DesignTokens.Color.separator
        joinButton.setTitleColor(DesignTokens.Color.textMuted, for: .normal)
        joinButton.setTitleColor(DesignTokens.Color.textMuted, for: .disabled)
    }

    @objc private func goBack() { navigationController?.popViewController(animated: true) }
}

/// A label with symmetric horizontal padding (for tag pills).
final class PaddingTag: UILabel {
    private var horizontalInset: CGFloat { 32.dp }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + horizontalInset * 2, height: s.height)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 0, left: horizontalInset,
                                                       bottom: 0, right: horizontalInset)))
    }
}
