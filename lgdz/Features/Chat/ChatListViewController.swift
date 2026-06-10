import UIKit

/// Screen 18 — Information / chat list (Tab). Header + friend requests +
/// conversation cards (System / AI Assistant / contacts) with time + unread badge.
final class ChatListViewController: UIViewController {

    private let scroll = UIScrollView()
    private let list = UIStackView()
    private weak var emptyView: EmptyStateView?

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupHeader()
        setupList()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadConversations),
            name: .accountDidActivate, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadConversations),
            name: .aiChatDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadConversations),
            name: .blockStateDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadConversations),
            name: .chatUnreadDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        reloadConversations()
    }

    private func setupHeader() {
        let header = NavHeader(title: "Information", onBack: nil)
        header.hideBack()
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        // Friend requests entry (person icon with badge dot).
        let requests = UIButton(type: .system)
        requests.setImage(UIImage(named: "friend_request_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        requests.imageView?.contentMode = .scaleAspectFit
        requests.addTarget(self, action: #selector(openRequests), for: .touchUpInside)
        requests.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(requests)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),
            requests.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            requests.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            requests.widthAnchor.constraint(equalToConstant: 60.dp),
            requests.heightAnchor.constraint(equalToConstant: 60.dp),
        ])
    }

    @objc private func openRequests() {
        navigationController?.pushViewController(FriendRequestViewController(), animated: true)
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

        let empty = EmptyStateView(
            title: "No messages yet",
            subtitle: "Start chatting with dog-walking\nbuddies from the community!")
        empty.isHidden = true
        empty.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(empty)
        emptyView = empty
        NSLayoutConstraint.activate([
            empty.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 80.dp),
            empty.centerXAnchor.constraint(equalTo: scroll.frameLayoutGuide.centerXAnchor),
            empty.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -64.dp),
        ])
        reloadConversations()
    }

    @objc private func reloadConversations() {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let items = DemoContent.conversations
        emptyView?.isHidden = !items.isEmpty
        for c in items {
            list.addArrangedSubview(makeCard(c))
        }
    }

    private func makeCard(_ c: DemoContent.Conversation) -> UIView {
        let card = UIControl()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        card.heightAnchor.constraint(equalToConstant: 180.dp).isActive = true

        let avatarContainer = UIView()
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatarContainer)
        switch c.kind {
        case .system:
            let v = UIView()
            v.backgroundColor = DesignTokens.Color.accentYellow
            v.layer.cornerRadius = 56.dp
            v.translatesAutoresizingMaskIntoConstraints = false
            let grid = UIImageView(image: UIImage(systemName: "square.grid.2x2.fill"))
            grid.tintColor = .white
            grid.contentMode = .scaleAspectFit
            grid.translatesAutoresizingMaskIntoConstraints = false
            v.addSubview(grid)
            avatarContainer.addSubview(v)
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
                v.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
                v.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
                grid.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                grid.centerYAnchor.constraint(equalTo: v.centerYAnchor),
                grid.widthAnchor.constraint(equalToConstant: 56.dp),
                grid.heightAnchor.constraint(equalToConstant: 56.dp),
            ])
        default:
            let av = CircleImageView(asset: c.avatar)
            if c.kind == .ai { av.backgroundColor = UIColor(hex: 0xEDEDED) }
            av.translatesAutoresizingMaskIntoConstraints = false
            avatarContainer.addSubview(av)
            NSLayoutConstraint.activate([
                av.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
                av.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
                av.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
                av.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            ])
        }

        let name = UILabel()
        name.text = c.name
        name.font = DesignTokens.Font.bold(38)
        name.textColor = DesignTokens.Color.textPrimary
        name.lineBreakMode = .byTruncatingTail
        name.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(name)

        let last = UILabel()
        last.text = c.last
        last.font = DesignTokens.Font.regular(30)
        last.textColor = DesignTokens.Color.textMuted
        last.lineBreakMode = .byTruncatingTail
        last.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(last)

        let time = UILabel()
        time.text = c.time
        time.font = DesignTokens.Font.regular(26)
        time.textColor = DesignTokens.Color.textMuted
        time.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(time)

        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            avatarContainer.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 112.dp),
            avatarContainer.heightAnchor.constraint(equalToConstant: 112.dp),

            time.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -32.dp),
            time.topAnchor.constraint(equalTo: card.topAnchor, constant: 40.dp),

            name.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 28.dp),
            name.topAnchor.constraint(equalTo: card.topAnchor, constant: 40.dp),
            name.trailingAnchor.constraint(lessThanOrEqualTo: time.leadingAnchor, constant: -16.dp),

            last.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            last.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 14.dp),
            last.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -120.dp),
        ])

        if c.unread > 0 {
            let badge = UILabel()
            badge.text = "\(c.unread)"
            badge.font = DesignTokens.Font.bold(24)
            badge.textColor = .white
            badge.backgroundColor = DesignTokens.Color.hot
            badge.textAlignment = .center
            badge.layer.cornerRadius = 24.dp
            badge.layer.masksToBounds = true
            badge.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(badge)
            NSLayoutConstraint.activate([
                badge.centerYAnchor.constraint(equalTo: last.centerYAnchor),
                badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -32.dp),
                badge.widthAnchor.constraint(equalToConstant: 48.dp),
                badge.heightAnchor.constraint(equalToConstant: 48.dp),
            ])
        }

        card.addAction(UIAction { [weak self] _ in self?.open(c) }, for: .touchUpInside)
        return card
    }

    private func open(_ c: DemoContent.Conversation) {
        switch c.kind {
        case .ai:
            navigationController?.pushViewController(AIChatViewController(), animated: true)
        default:
            let userId = c.kind == .user ? DemoContent.userId(forName: c.name) : nil
            navigationController?.pushViewController(
                FriendChatViewController(
                    peerName: c.name,
                    peerAvatar: c.kind == .system ? "content_dog1" : c.avatar,
                    peerUserId: userId),
                animated: true)
        }
    }
}
