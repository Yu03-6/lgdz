import UIKit

/// Screen 13 — Community Feed (Tab). Segmented header (Recommend / Followed) +
/// a scrolling list of activity cards, and a floating "+" compose FAB.
final class FeedViewController: UIViewController {

    private let tabs = ["Recommend", "Followed"]
    private var selectedTab = 0
    private let segment = UIStackView()
    private let scroll = UIScrollView()
    private let list = UIStackView()
    private let fab = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupHeader()
        setupList()
        setupFAB()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadFeed),
            name: .userPostDidPublish, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadFeed),
            name: .userPostDidDelete, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadFeed),
            name: .followStateDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadFeed),
            name: .blockStateDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        reloadFeed()
    }

    private func setupHeader() {
        segment.axis = .horizontal
        segment.spacing = 20.dp
        segment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment)
        for (i, t) in tabs.enumerated() {
            let b = PillButton(style: .secondary, title: t)
            b.designCornerRadius = 36
            b.tag = i
            b.titleLabel?.font = DesignTokens.Font.bold(32)
            b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 44.dp, bottom: 0, right: 44.dp)
            b.addTarget(self, action: #selector(selectTab(_:)), for: .touchUpInside)
            segment.addArrangedSubview(b)
            b.heightAnchor.constraint(equalToConstant: 92.dp).isActive = true
        }
        applyTabStyles()

        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.dp),
            segment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.dp),
        ])
    }

    private func applyTabStyles() {
        for case let b as PillButton in segment.arrangedSubviews {
            let on = b.tag == selectedTab
            b.backgroundColor = on ? DesignTokens.Color.textPrimary : DesignTokens.Color.secondaryFill
            b.setTitleColor(on ? .white : DesignTokens.Color.textPrimary, for: .normal)
        }
    }

    @objc private func selectTab(_ sender: UIButton) {
        selectedTab = sender.tag
        applyTabStyles()
        reloadFeed()
    }

    private func setupList() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset.bottom = MainTabBarController.contentBottomInset
        view.addSubview(scroll)
        list.axis = .vertical
        list.spacing = 28.dp
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 32.dp),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -32.dp),
        ])
    }

    @objc private func reloadFeed() {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts = selectedTab == 0
            ? DemoContent.feedPostsForFeedTab
            : DemoContent.followedFeedPosts
        if posts.isEmpty, selectedTab == 1 {
            let empty = EmptyStateView(
                title: "No followed posts yet",
                subtitle: "Follow someone in Recommend\nto see their updates here.")
            list.addArrangedSubview(empty)
            return
        }
        for a in posts {
            let card = ActivityCardView(item: a)
            wireActivityCard(card, item: a)
            list.addArrangedSubview(card)
        }
    }

    private func setupFAB() {
        fab.backgroundColor = DesignTokens.Color.accent
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(48), weight: .bold)
        fab.setImage(UIImage(systemName: "plus", withConfiguration: cfg), for: .normal)
        fab.tintColor = DesignTokens.Color.textPrimary
        fab.layer.cornerRadius = 70.dp
        fab.layer.shadowColor = UIColor.black.cgColor
        fab.layer.shadowOpacity = 0.15
        fab.layer.shadowRadius = 10
        fab.layer.shadowOffset = CGSize(width: 0, height: 4)
        fab.addTarget(self, action: #selector(tapCompose), for: .touchUpInside)
        fab.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fab)
        NSLayoutConstraint.activate([
            fab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44.dp),
            fab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(MainTabBarController.contentBottomInset)),
            fab.widthAnchor.constraint(equalToConstant: 140.dp),
            fab.heightAnchor.constraint(equalToConstant: 140.dp),
        ])
    }

    @objc private func tapCompose() {
        navigationController?.pushViewController(PublishViewController(), animated: true)
    }
}
