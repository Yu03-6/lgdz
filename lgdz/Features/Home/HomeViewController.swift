import UIKit

/// Screen 7 — Home (Tab). Vertical scroll: Spring banner + Join Now, walk diary /
/// dog buddy match, AI Chat / Live promo cards, Popular list, activities feed.
final class HomeViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()
    private weak var walkDiaryCard: UIView?
    private weak var dogMatchCard: UIView?

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
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshWalkDiaryCard),
            name: .walkDiaryDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshDogMatchCard),
            name: .dogProfileDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(rebuildSections),
            name: .languageDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        refreshWalkDiaryCard()
        refreshDogMatchCard()
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

        let diaryHeader = SectionHeader(title: L10n.homeWalkDiary)
        diaryHeader.onMore = { [weak self] in
            self?.navigationController?.pushViewController(WalkDiaryViewController(), animated: true)
        }
        content.addArrangedSubview(diaryHeader)
        content.setCustomSpacing(28.dp, after: diaryHeader)
        let diaryCard = makeWalkDiaryCard()
        walkDiaryCard = diaryCard
        content.addArrangedSubview(diaryCard)
        content.setCustomSpacing(56.dp, after: diaryCard)

        let matchHeader = SectionHeader(title: L10n.homeDogMatch)
        matchHeader.onMore = { [weak self] in
            self?.navigationController?.pushViewController(DogMatchViewController(), animated: true)
        }
        content.addArrangedSubview(matchHeader)
        content.setCustomSpacing(28.dp, after: matchHeader)
        let matchCard = makeDogMatchCard()
        dogMatchCard = matchCard
        content.addArrangedSubview(matchCard)
        content.setCustomSpacing(56.dp, after: matchCard)

        let popHeader = SectionHeader(title: L10n.homePopular)
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

        let actHeader = SectionHeader(title: L10n.homeActivities, titleSize: 42)
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
            string: L10n.homeBannerTitle,
            attributes: [
                .font: UIFont.systemFont(ofSize: DesignMetrics.font(50), weight: .black),
                .foregroundColor: DesignTokens.Color.textPrimary,
                .paragraphStyle: titleStyle,
            ])
        title.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(title)

        let subtitle = UILabel()
        subtitle.text = L10n.homeBannerSubtitle
        subtitle.font = DesignTokens.Font.bold(34)
        subtitle.textColor = DesignTokens.Color.textMuted
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitle)

        let join = PillButton(style: .primary, title: L10n.homeJoinNow)
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

    // MARK: - Walk Diary (home preview)

    @objc private func refreshWalkDiaryCard() {
        guard let card = walkDiaryCard else { return }
        updateWalkDiaryCard(card)
    }

    private func makeWalkDiaryCard() -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        updateWalkDiaryCard(card)
        return card
    }

    private func updateWalkDiaryCard(_ card: UIView) {
        card.subviews.forEach { $0.removeFromSuperview() }

        let streak = DogWalkingStore.currentStreak()
        let checkedToday = DogWalkingStore.hasCheckedInToday()
        let recent = Array(DogWalkingStore.walkDiaryEntries().prefix(2))

        let streakLabel = UILabel()
        streakLabel.text = "\(streak)-day streak"
        streakLabel.font = DesignTokens.Font.bold(36)
        streakLabel.textColor = DesignTokens.Color.textPrimary

        let todayLabel = UILabel()
        todayLabel.text = checkedToday ? "Checked in today ✓" : "Not checked in yet today"
        todayLabel.font = DesignTokens.Font.medium(28)
        todayLabel.textColor = checkedToday ? DesignTokens.Color.accentYellow : DesignTokens.Color.textMuted

        let recentLabel = UILabel()
        if recent.isEmpty {
            recentLabel.text = "Log your first walk to start a streak."
        } else {
            recentLabel.text = recent.map {
                "\(DogWalkingStore.relativeDay($0.date)) · \($0.durationMinutes) min"
            }.joined(separator: "\n")
        }
        recentLabel.font = DesignTokens.Font.regular(26)
        recentLabel.textColor = DesignTokens.Color.textPrimary
        recentLabel.numberOfLines = 0

        let checkIn = PillButton(
            style: checkedToday ? .secondary : .primary,
            title: checkedToday ? "Log Another Walk" : "Check In")
        checkIn.designCornerRadius = 28
        checkIn.addTarget(self, action: #selector(tapHomeCheckIn), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [streakLabel, todayLabel, recentLabel, checkIn])
        stack.axis = .vertical
        stack.spacing = 16.dp
        stack.setCustomSpacing(24.dp, after: recentLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            checkIn.heightAnchor.constraint(equalToConstant: 92.dp),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28.dp),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28.dp),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28.dp),
        ])
    }

    @objc private func tapHomeCheckIn() {
        let sheet = WalkCheckInSheetController { note, minutes in
            DogWalkingStore.addCheckIn(note: note, durationMinutes: minutes)
        }
        present(sheet, animated: true)
    }

    // MARK: - Dog Match (home preview)

    @objc private func refreshDogMatchCard() {
        guard let card = dogMatchCard else { return }
        updateDogMatchCard(card)
    }

    private func makeDogMatchCard() -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        updateDogMatchCard(card)
        return card
    }

    private func updateDogMatchCard(_ card: UIView) {
        card.subviews.forEach { $0.removeFromSuperview() }

        let profile = DogWalkingStore.currentUserDogProfile()
        let matches: [DogMatchResult]
        if let profile {
            matches = Array(DogWalkingStore.matchBuddies(query: profile, limit: 3))
        } else {
            matches = []
        }

        let summary = UILabel()
        if let profile {
            summary.text = "Your pup: \(profile.dogName.isEmpty ? "My Dog" : profile.dogName) · \(profile.breed) · \(profile.size.rawValue)\n\(profile.personality.joined(separator: " · "))"
        } else {
            summary.text = "Set breed, size & personality tags to find walkers with similar dogs."
        }
        summary.font = DesignTokens.Font.regular(26)
        summary.textColor = DesignTokens.Color.textPrimary
        summary.numberOfLines = 0

        let matchStack = UIStackView()
        matchStack.axis = .vertical
        matchStack.spacing = 12.dp

        if matches.isEmpty {
            let hint = UILabel()
            hint.text = profile == nil ? "Tap Match Now to get started." : "No close matches — try broader tags."
            hint.font = DesignTokens.Font.medium(24)
            hint.textColor = DesignTokens.Color.textMuted
            hint.numberOfLines = 0
            matchStack.addArrangedSubview(hint)
        } else {
            for result in matches {
                let row = UILabel()
                row.text = "\(result.userName) & \(result.dog.dogName) — \(result.matchPercent)% match"
                row.font = DesignTokens.Font.semibold(26)
                row.textColor = DesignTokens.Color.textPrimary
                row.numberOfLines = 0
                matchStack.addArrangedSubview(row)
            }
        }

        let matchBtn = PillButton(style: .primary, title: profile == nil ? "Set Tags & Match" : "Match Now")
        matchBtn.designCornerRadius = 28
        matchBtn.addTarget(self, action: #selector(tapDogMatch), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [summary, matchStack, matchBtn])
        stack.axis = .vertical
        stack.spacing = 20.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            matchBtn.heightAnchor.constraint(equalToConstant: 92.dp),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28.dp),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28.dp),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28.dp),
        ])
    }

    @objc private func tapDogMatch() {
        navigationController?.pushViewController(DogMatchViewController(), animated: true)
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
