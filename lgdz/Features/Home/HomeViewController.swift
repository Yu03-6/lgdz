import UIKit

/// Screen 7 — Home (Tab). Vertical scroll: Spring banner + Join Now, AI Chat /
/// Live promo cards, Popular list, "Dog lovers' activities" feed.
final class HomeViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupScroll()
        buildSections()
        NotificationCenter.default.addObserver(
            self, selector: #selector(rebuildSections),
            name: .accountDidActivate, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(rebuildSections),
            name: .blockStateDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset.bottom = MainTabBarController.contentBottomInset
        view.addSubview(scroll)

        content.axis = .vertical
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 32.dp),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -32.dp),
        ])
    }

    @objc private func rebuildSections() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buildSections()
    }

    private func buildSections() {
        content.addArrangedSubview(makeBanner())
        content.setCustomSpacing(40.dp, after: content.arrangedSubviews.last!)

        content.addArrangedSubview(makePromoRow())
        content.setCustomSpacing(56.dp, after: content.arrangedSubviews.last!)

        let popHeader = SectionHeader(title: "Popular")
        popHeader.onMore = { [weak self] in
            self?.navigationController?.pushViewController(
                ActivityListViewController(title: "Activity"), animated: true)
        }
        content.addArrangedSubview(popHeader)
        content.setCustomSpacing(28.dp, after: popHeader)
        for (i, p) in DemoContent.popular.enumerated() {
            let card = PopularCardView(item: p)
            card.heightAnchor.constraint(equalToConstant: 248.dp).isActive = true
            content.addArrangedSubview(card)
            content.setCustomSpacing(i == DemoContent.popular.count - 1 ? 56.dp : 32.dp, after: card)
        }

        let actHeader = SectionHeader(title: "Dog lovers' activities", titleSize: 42)
        actHeader.onMore = { [weak self] in
            (self?.tabBarController as? MainTabBarController)?.selectTab(at: 1)
        }
        content.addArrangedSubview(actHeader)
        content.setCustomSpacing(28.dp, after: actHeader)
        for a in DemoContent.activities {
            let card = ActivityCardView(item: a)
            wireCard(card, item: a)
            content.addArrangedSubview(card)
            content.setCustomSpacing(28.dp, after: card)
        }
    }

    private func wireCard(_ card: ActivityCardView, item: DemoContent.Activity) {
        card.onAvatarTap = { [weak self] in
            guard let user = DemoContent.user(id: item.userId) else { return }
            self?.navigationController?.pushViewController(UserProfileViewController(user: user), animated: true)
        }
        card.onComment = { [weak self] in
            self?.navigationController?.pushViewController(CommentDetailViewController(item: item), animated: true)
        }
        card.onReport = { [weak self] in
            self?.present(ReportBlockSheet(targetName: item.name), animated: true)
        }
    }

    private func makeBanner() -> UIView {
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 360.dp).isActive = true

        let banner = UIImageView(image: UIImage(named: "home_banner"))
        banner.contentMode = .scaleAspectFill
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(banner)

        let title = UILabel()
        title.numberOfLines = 2
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = 14.dp
        title.attributedText = NSAttributedString(
            string: "Spring\nLeash & Meet",
            attributes: [
                .font: UIFont.systemFont(ofSize: DesignMetrics.font(50), weight: .black),
                .foregroundColor: DesignTokens.Color.textPrimary,
                .paragraphStyle: titleStyle,
            ])
        title.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(title)

        let subtitle = UILabel()
        subtitle.text = "Come join us!"
        subtitle.font = DesignTokens.Font.bold(34)
        subtitle.textColor = DesignTokens.Color.textMuted
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitle)

        let join = PillButton(style: .primary, title: "Join Now ")
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(30), weight: .bold)
        join.setImage(UIImage(systemName: "arrow.right", withConfiguration: cfg), for: .normal)
        join.tintColor = DesignTokens.Color.textPrimary
        join.semanticContentAttribute = .forceRightToLeft
        join.designCornerRadius = 30
        join.addTarget(self, action: #selector(tapJoinNow), for: .touchUpInside)
        join.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(join)

        NSLayoutConstraint.activate([
            banner.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 32.dp),
            banner.topAnchor.constraint(equalTo: container.topAnchor),
            banner.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            banner.widthAnchor.constraint(equalTo: banner.heightAnchor, multiplier: 780.0 / 366.0),

            title.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            title.topAnchor.constraint(equalTo: container.topAnchor),

            subtitle.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 21.dp),

            join.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            join.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 27.dp),
            join.heightAnchor.constraint(equalToConstant: 108.dp),
            join.widthAnchor.constraint(equalToConstant: 288.dp),
        ])
        return container
    }

    @objc private func tapJoinNow() {
        navigationController?.pushViewController(JoinNowViewController(), animated: true)
    }

    private func makePromoRow() -> UIView {
        let aiCard = PromoCardView(bgAsset: "card_ai", title: "AI Chat", subtitle: "Chat with\nAI about dogs")
        aiCard.onTap = { [weak self] in
            self?.navigationController?.pushViewController(AIChatViewController(), animated: true)
        }
        let liveCard = PromoCardView(bgAsset: "card_live", title: "Live", subtitle: "Pet hacks\nfrom walkers")
        liveCard.onTap = { [weak self] in
            self?.navigationController?.pushViewController(LiveHallViewController(), animated: true)
        }
        let row = UIStackView(arrangedSubviews: [aiCard, liveCard])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 24.dp
        row.heightAnchor.constraint(equalToConstant: 250.dp).isActive = true
        return row
    }
}
