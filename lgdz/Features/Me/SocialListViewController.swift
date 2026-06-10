import UIKit

/// Screen 25 — Friends / Followed / Fans. Segmented tabs + user cards with a
/// quick-chat button. (New accounts show the empty state per §3.)
final class SocialListViewController: UIViewController {

    private let tabs = ["Friends", "Followed", "Fans"]
    private var selectedTab: Int
    private let segment = UIStackView()
    private let scroll = UIScrollView()
    private let list = UIStackView()

    init(initialTab: Int) {
        self.selectedTab = min(max(initialTab, 0), 2)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupHeader()
        setupSegment()
        setupList()
        reload()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reload),
            name: .blockStateDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func setupHeader() {
        let header = NavHeader(title: nil) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),
        ])
    }

    private func setupSegment() {
        segment.axis = .horizontal
        segment.spacing = 24.dp
        segment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment)
        for (i, t) in tabs.enumerated() {
            let b = PillButton(style: .secondary, title: t)
            b.designCornerRadius = 36
            b.tag = i
            b.titleLabel?.font = DesignTokens.Font.semibold(30)
            b.addTarget(self, action: #selector(selectTab(_:)), for: .touchUpInside)
            segment.addArrangedSubview(b)
            b.heightAnchor.constraint(equalToConstant: 96.dp).isActive = true
        }
        applyTabStyles()
        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130.dp),
            segment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.dp),
        ])
    }

    private func applyTabStyles() {
        for case let b as PillButton in segment.arrangedSubviews {
            let on = b.tag == selectedTab
            b.backgroundColor = on ? DesignTokens.Color.accent : DesignTokens.Color.secondaryFill
            b.setTitleColor(on ? .white : DesignTokens.Color.textPrimary, for: .normal)
        }
    }

    @objc private func selectTab(_ sender: UIButton) {
        selectedTab = sender.tag
        applyTabStyles()
        reload()
    }

    private func setupList() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset.bottom = 40.dp
        view.addSubview(scroll)
        list.axis = .vertical
        list.spacing = 28.dp
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 250.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 32.dp),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -32.dp),
            list.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -64.dp),
        ])
    }

    private func currentUsers() -> [DemoContent.SocialUser] {
        switch selectedTab {
        case 0: return DemoContent.friends
        case 1: return DemoContent.followed
        default: return DemoContent.fans
        }
    }

    @objc private func reload() {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let users = currentUsers()
        if users.isEmpty {
            let empty = EmptyStateView(title: "Nobody here yet", subtitle: "Go make some dog-walking friends!")
            list.addArrangedSubview(empty)
            return
        }
        for u in users { list.addArrangedSubview(makeCard(u)) }
    }

    private func makeCard(_ u: DemoContent.SocialUser) -> UIView {
        let card = UIControl()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        card.heightAnchor.constraint(equalToConstant: 170.dp).isActive = true

        let avatar = CircleImageView(asset: u.avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatar)
        let name = UILabel()
        name.text = u.name
        name.font = DesignTokens.Font.bold(38)
        name.textColor = DesignTokens.Color.textPrimary
        name.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(name)
        let bio = UILabel()
        bio.text = u.bio
        bio.font = DesignTokens.Font.regular(30)
        bio.textColor = DesignTokens.Color.textMuted
        bio.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bio)
        let chat = UIButton(type: .system)
        chat.setImage(UIImage(named: "chat_bubble_btn"), for: .normal)
        chat.imageView?.contentMode = .scaleAspectFit
        chat.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chat)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 104.dp),
            avatar.heightAnchor.constraint(equalToConstant: 104.dp),
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 28.dp),
            name.topAnchor.constraint(equalTo: card.topAnchor, constant: 44.dp),
            bio.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            bio.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 12.dp),
            chat.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -36.dp),
            chat.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chat.widthAnchor.constraint(equalToConstant: 80.dp),
            chat.heightAnchor.constraint(equalToConstant: 80.dp),
        ])
        chat.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(
                FriendChatViewController(
                    peerName: u.name,
                    peerAvatar: u.avatar,
                    peerUserId: DemoContent.userId(forName: u.name)),
                animated: true)
        }, for: .touchUpInside)
        card.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(
                UserProfileViewController(name: u.name, avatar: u.avatar), animated: true)
        }, for: .touchUpInside)
        return card
    }
}
