import UIKit

/// Screen 21 — Me (Tab). Nature header + avatar/name/bio + stats + balance card
/// + Post section (empty state for new users per §3).
final class MeViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIView()
    private let postsStack = UIStackView()
    private weak var balanceLabel: UILabel?
    private weak var balanceCaptionLabel: UILabel?
    private weak var rechargeButton: PillButton?
    private weak var emptyPostsView: EmptyStateView?
    private weak var avatarView: CircleImageView?
    private weak var nameLabel: UILabel?
    private weak var bioLabel: UILabel?
    private weak var languageSwitcher: LanguageSwitcherView?
    private var languageMenuDismissInstaller: LanguageMenuDismissInstaller?
    private weak var postHeader: SectionHeader?
    private var statValueLabels: [UILabel] = []
    private var statTitleLabels: [UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupPageBackground()
        build()
        languageSwitcher?.overlayHost = view
        if let languageSwitcher {
            languageMenuDismissInstaller = LanguageMenuDismissInstaller()
            languageMenuDismissInstaller?.install(on: view, switcher: languageSwitcher)
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshBalance),
            name: .walletBalanceDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadPosts),
            name: .userPostDidPublish, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadPosts),
            name: .userPostDidDelete, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshProfile),
            name: .blockStateDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadPosts),
            name: .blockStateDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshProfile),
            name: .accountDidActivate, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshLocalizedUI),
            name: .languageDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupPageBackground() {
        let bg = UIImageView(image: UIImage(named: "me_bg"))
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        languageSwitcher?.dismissMenu()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        refreshBalance()
        refreshProfile()
        refreshLocalizedUI()
        reloadPosts()
    }

    @objc private func refreshProfile() {
        let acct = AppSession.shared.current
        nameLabel?.text = acct?.displayName ?? "Me"
        bioLabel?.text = acct?.bio?.isEmpty == false ? acct?.bio : L10n.meNoIntro
        avatarView?.applyAccountAvatar(asset: acct?.avatarAsset, displayName: acct?.displayName ?? "Me")
        let counts = [
            "\(DemoContent.friendsCount)",
            "\(DemoContent.followedCount)",
            "\(DemoContent.fansCount)",
        ]
        for (i, label) in statValueLabels.enumerated() where i < counts.count {
            label.text = counts[i]
        }
    }

    @objc private func refreshBalance() {
        balanceLabel?.text = "\(AppSession.shared.coins)"
    }

    @objc private func refreshLocalizedUI() {
        languageSwitcher?.refreshSelection()
        let statTitles = [L10n.meFriends, L10n.meFollowed, L10n.meFans]
        for (i, label) in statTitleLabels.enumerated() where i < statTitles.count {
            label.text = statTitles[i]
        }
        balanceCaptionLabel?.text = L10n.meBalance
        rechargeButton?.setTitle(L10n.meRecharge, for: .normal)
        postHeader?.setTitle(L10n.mePost)
        postHeader?.refreshMoreTitle()
        emptyPostsView?.update(title: L10n.meNoPosts, subtitle: L10n.meNoPostsSubtitle)
        if (AppSession.shared.current?.bio ?? "").isEmpty {
            bioLabel?.text = L10n.meNoIntro
        }
        reloadPosts()
    }

    private func build() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.backgroundColor = .clear
        scroll.contentInset.bottom = MainTabBarController.contentBottomInset
        view.addSubview(scroll)
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
        ])

        let topBar = makeTopBar()
        content.addSubview(topBar)

        let avatar = CircleImageView(asset: nil)
        avatar.applyAccountAvatar(
            asset: AppSession.shared.current?.avatarAsset,
            displayName: AppSession.shared.current?.displayName ?? "Me")
        avatarView = avatar
        avatar.layer.borderWidth = 4
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(avatar)

        let edit = UIButton(type: .custom)
        let editIcon = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(28), weight: .semibold)
        edit.setImage(UIImage(systemName: "pencil", withConfiguration: editIcon), for: .normal)
        edit.tintColor = .white
        edit.backgroundColor = DesignTokens.Color.accentYellow
        edit.layer.cornerRadius = 26.dp
        edit.layer.masksToBounds = true
        edit.addTarget(self, action: #selector(openProfileEdit), for: .touchUpInside)
        edit.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(edit)

        let name = UILabel()
        name.text = AppSession.shared.current?.displayName ?? "Me"
        name.font = DesignTokens.Font.bold(48)
        name.textColor = DesignTokens.Color.textPrimary
        name.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(name)
        nameLabel = name

        let bio = UILabel()
        bio.text = AppSession.shared.current?.bio ?? L10n.meNoIntro
        bio.font = DesignTokens.Font.regular(32)
        bio.textColor = DesignTokens.Color.textPrimary
        bio.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(bio)
        bioLabel = bio

        let stats = UIStackView(arrangedSubviews: [
            statBlock("\(DemoContent.friendsCount)", L10n.meFriends, 0),
            statBlock("\(DemoContent.followedCount)", L10n.meFollowed, 1),
            statBlock("\(DemoContent.fansCount)", L10n.meFans, 2),
        ])
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stats)

        let balance = makeBalanceCard()
        content.addSubview(balance)

        let postHeader = SectionHeader(title: L10n.mePost, showMore: false)
        postHeader.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(postHeader)
        self.postHeader = postHeader

        postsStack.axis = .vertical
        postsStack.spacing = 28.dp
        postsStack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(postsStack)

        let empty = EmptyStateView(title: L10n.meNoPosts, subtitle: L10n.meNoPostsSubtitle)
        empty.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(empty)
        emptyPostsView = empty

        let margin = 32.dp
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: content.topAnchor, constant: 20.dp),
            topBar.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            topBar.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            topBar.heightAnchor.constraint(equalToConstant: 60.dp),

            avatar.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            avatar.topAnchor.constraint(equalTo: content.topAnchor, constant: 230.dp),
            avatar.widthAnchor.constraint(equalToConstant: 170.dp),
            avatar.heightAnchor.constraint(equalToConstant: 170.dp),
            edit.trailingAnchor.constraint(equalTo: avatar.trailingAnchor),
            edit.bottomAnchor.constraint(equalTo: avatar.bottomAnchor),
            edit.widthAnchor.constraint(equalToConstant: 52.dp),
            edit.heightAnchor.constraint(equalToConstant: 52.dp),

            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 32.dp),
            name.topAnchor.constraint(equalTo: avatar.topAnchor, constant: 24.dp),
            bio.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            bio.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 16.dp),

            stats.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            stats.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            stats.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 40.dp),

            balance.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            balance.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            balance.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 50.dp),
            balance.heightAnchor.constraint(equalToConstant: 180.dp),

            postHeader.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            postHeader.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            postHeader.topAnchor.constraint(equalTo: balance.bottomAnchor, constant: 44.dp),

            postsStack.topAnchor.constraint(equalTo: postHeader.bottomAnchor, constant: 28.dp),
            postsStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            postsStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            postsStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -160.dp),

            empty.topAnchor.constraint(equalTo: postHeader.bottomAnchor, constant: 120.dp),
            empty.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            empty.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -160.dp),
        ])
        content.bringSubviewToFront(edit)
    }

    private func makeTopBar() -> UIView {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false

        let language = LanguageSwitcherView()
        language.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(language)
        languageSwitcher = language

        let settings = UIButton(type: .custom)
        settings.setImage(
            UIImage(named: "me_settings_btn")?.withRenderingMode(.alwaysOriginal),
            for: .normal)
        settings.imageView?.contentMode = .scaleAspectFit
        settings.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        settings.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(settings)

        NSLayoutConstraint.activate([
            language.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            language.topAnchor.constraint(equalTo: bar.topAnchor),
            language.bottomAnchor.constraint(equalTo: bar.bottomAnchor),

            settings.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            settings.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            settings.widthAnchor.constraint(equalToConstant: 60.dp),
            settings.heightAnchor.constraint(equalToConstant: 60.dp),
        ])
        return bar
    }

    @objc private func reloadPosts() {
        postsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts = DemoContent.currentUserPosts
        let hasPosts = !posts.isEmpty
        emptyPostsView?.isHidden = hasPosts
        postsStack.isHidden = !hasPosts
        for item in posts {
            let card = ActivityCardView(item: item)
            wireActivityCard(card, item: item)
            postsStack.addArrangedSubview(card)
        }
    }

    private func makeBalanceCard() -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.textPrimary
        card.layer.cornerRadius = 36.dp
        card.translatesAutoresizingMaskIntoConstraints = false

        let coin = UIImageView(image: UIImage(named: "coin"))
        coin.contentMode = .scaleAspectFit
        coin.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(coin)

        let amount = UILabel()
        amount.text = "\(AppSession.shared.coins)"
        amount.font = DesignTokens.Font.bold(46)
        amount.textColor = .white
        amount.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(amount)
        balanceLabel = amount

        let label = UILabel()
        label.text = L10n.meBalance
        label.font = DesignTokens.Font.medium(32)
        label.textColor = UIColor(white: 1, alpha: 0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        balanceCaptionLabel = label

        let recharge = PillButton(style: .primary, title: L10n.meRecharge)
        recharge.backgroundColor = DesignTokens.Color.accentYellow
        recharge.setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
        recharge.titleLabel?.font = DesignTokens.Font.semibold(30)
        recharge.designCornerRadius = 36
        recharge.addTarget(self, action: #selector(openRecharge), for: .touchUpInside)
        recharge.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(recharge)
        rechargeButton = recharge

        NSLayoutConstraint.activate([
            coin.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 40.dp),
            coin.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            coin.widthAnchor.constraint(equalToConstant: 90.dp),
            coin.heightAnchor.constraint(equalToConstant: 90.dp),
            amount.leadingAnchor.constraint(equalTo: coin.trailingAnchor, constant: 28.dp),
            amount.topAnchor.constraint(equalTo: card.topAnchor, constant: 40.dp),
            label.leadingAnchor.constraint(equalTo: amount.leadingAnchor),
            label.topAnchor.constraint(equalTo: amount.bottomAnchor, constant: 6.dp),
            recharge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -40.dp),
            recharge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            recharge.widthAnchor.constraint(equalToConstant: 230.dp),
            recharge.heightAnchor.constraint(equalToConstant: 88.dp),
        ])
        return card
    }

    private func statBlock(_ value: String, _ title: String, _ index: Int) -> UIView {
        let v = UIControl()
        let num = UILabel()
        num.text = value
        num.font = DesignTokens.Font.bold(44)
        num.textColor = DesignTokens.Color.textPrimary
        num.textAlignment = .center
        num.translatesAutoresizingMaskIntoConstraints = false
        statValueLabels.append(num)
        let t = UILabel()
        t.text = title
        t.font = DesignTokens.Font.regular(30)
        t.textColor = DesignTokens.Color.textPrimary
        t.textAlignment = .center
        t.translatesAutoresizingMaskIntoConstraints = false
        statTitleLabels.append(t)
        v.addSubview(num); v.addSubview(t)
        NSLayoutConstraint.activate([
            num.topAnchor.constraint(equalTo: v.topAnchor),
            num.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            t.topAnchor.constraint(equalTo: num.bottomAnchor, constant: 8.dp),
            t.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            t.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        v.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(SocialListViewController(initialTab: index), animated: true)
        }, for: .touchUpInside)
        return v
    }

    @objc private func openRecharge() {
        navigationController?.pushViewController(RechargeViewController(), animated: true)
    }

    @objc private func openSettings() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }

    @objc private func openProfileEdit() {
        navigationController?.pushViewController(ProfileEditViewController(), animated: true)
    }
}
