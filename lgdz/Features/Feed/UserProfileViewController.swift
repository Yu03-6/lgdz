import UIKit

/// Screen 17 — User profile (个人主页). Fixed top cover photo; profile info and
/// the user's feed posts scroll beneath it (no pull-down gap above the header).
final class UserProfileViewController: UIViewController {

    private let user: DemoContent.FeedUser
    private var name: String { user.name }
    private var avatar: String { user.avatar }
    private weak var followButton: PillButton?

    private let headerPhoto = UIImageView()
    private let headerGradient = GradientView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let postsStack = UIStackView()

    private var headerHeight: CGFloat { 560.dp }
    private var isFollowing: Bool { DemoContent.isFollowing(userId: user.id) }

    init(user: DemoContent.FeedUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(name: String, avatar: String) {
        let resolved = DemoContent.user(named: name)
            ?? DemoContent.FeedUser(
                id: "u_\(name.lowercased())", avatar: avatar, name: name, bio: "No introduction yet~",
                coverImage: avatar, friends: 23, followed: 128, fans: 56)
        self.init(user: resolved)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.Color.background
        hideSystemNavBar()
        setupFixedHeader()
        setupScroll()
        setupNavButtons()
        reloadPosts()
        registerNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        applyFollowState()
        reloadPosts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(followStateChanged(_:)),
                           name: .followStateDidChange, object: nil)
        center.addObserver(self, selector: #selector(reloadPosts),
                           name: .userPostDidPublish, object: nil)
        center.addObserver(self, selector: #selector(reloadPosts),
                           name: .userPostDidDelete, object: nil)
        center.addObserver(self, selector: #selector(reloadPosts),
                           name: .likeStateDidChange, object: nil)
    }

    @objc private func followStateChanged(_ note: Notification) {
        guard let changedId = note.userInfo?[FollowUserInfoKey.userId] as? String,
              changedId == user.id else { return }
        applyFollowState(animated: true)
    }

    // MARK: - Layout

    private func setupFixedHeader() {
        headerPhoto.image = UIImage(named: user.coverImage)
        headerPhoto.contentMode = .scaleAspectFill
        headerPhoto.clipsToBounds = true
        headerPhoto.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerPhoto)

        headerGradient.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerGradient)

        NSLayoutConstraint.activate([
            headerPhoto.topAnchor.constraint(equalTo: view.topAnchor),
            headerPhoto.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerPhoto.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerPhoto.heightAnchor.constraint(equalToConstant: headerHeight),

            headerGradient.leadingAnchor.constraint(equalTo: headerPhoto.leadingAnchor),
            headerGradient.trailingAnchor.constraint(equalTo: headerPhoto.trailingAnchor),
            headerGradient.bottomAnchor.constraint(equalTo: headerPhoto.bottomAnchor),
            headerGradient.heightAnchor.constraint(equalToConstant: 420.dp),
        ])
    }

    private func setupNavButtons() {
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(44), weight: .semibold)

        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let more = UIButton(type: .system)
        more.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        more.tintColor = .white
        more.addTarget(self, action: #selector(openMore), for: .touchUpInside)
        more.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(more)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.dp),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),
        ])
    }

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(makeProfileSection())
        contentStack.addArrangedSubview(makePostsSection())

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    private func makeProfileSection() -> UIView {
        let section = UIView()
        section.backgroundColor = .clear
        section.translatesAutoresizingMaskIntoConstraints = false
        section.heightAnchor.constraint(equalToConstant: headerHeight + 200.dp).isActive = true

        let smallAvatar = CircleImageView(asset: user.avatar)
        smallAvatar.layer.borderWidth = 4
        smallAvatar.layer.borderColor = UIColor.white.cgColor
        smallAvatar.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(smallAvatar)

        let edit = UIImageView(image: UIImage(systemName: "pencil"))
        edit.tintColor = .white
        edit.contentMode = .center
        edit.backgroundColor = DesignTokens.Color.accentYellow
        edit.layer.cornerRadius = 26.dp
        edit.layer.masksToBounds = true
        edit.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(edit)

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = DesignTokens.Font.bold(48)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(nameLabel)

        let bio = UILabel()
        bio.text = user.bio
        bio.font = DesignTokens.Font.regular(32)
        bio.textColor = UIColor(white: 1, alpha: 0.9)
        bio.numberOfLines = 0
        bio.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(bio)

        var anchorBelowBio: NSLayoutYAxisAnchor = bio.bottomAnchor

        if let dog = DogWalkingStore.dog(for: user) {
            let dogSection = makeDogTagsSection(dog)
            section.addSubview(dogSection)
            NSLayoutConstraint.activate([
                dogSection.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                dogSection.trailingAnchor.constraint(lessThanOrEqualTo: section.trailingAnchor, constant: -40.dp),
                dogSection.topAnchor.constraint(equalTo: bio.bottomAnchor, constant: 16.dp),
            ])
            anchorBelowBio = dogSection.bottomAnchor
        }

        let stats = UIStackView(arrangedSubviews: [
            statBlock("\(user.friends)", "Friends"),
            statBlock("\(user.followed)", "Followed"),
            statBlock("\(user.fans)", "Fans"),
        ])
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(stats)

        let follow = PillButton(style: .primary, title: " Follow")
        follow.designCornerRadius = 36
        let pcfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34), weight: .bold)
        follow.setImage(UIImage(systemName: "plus", withConfiguration: pcfg), for: .normal)
        follow.semanticContentAttribute = .forceLeftToRight
        follow.addTarget(self, action: #selector(tapFollow), for: .touchUpInside)
        follow.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(follow)
        self.followButton = follow
        applyFollowState()

        let chat = PillButton(style: .secondary, title: " Chat")
        chat.designCornerRadius = 36
        chat.backgroundColor = .white
        let ccfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34))
        chat.setImage(UIImage(systemName: "ellipsis.bubble", withConfiguration: ccfg), for: .normal)
        chat.tintColor = DesignTokens.Color.textPrimary
        chat.semanticContentAttribute = .forceLeftToRight
        chat.addTarget(self, action: #selector(tapChat), for: .touchUpInside)
        chat.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(chat)

        NSLayoutConstraint.activate([
            smallAvatar.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 40.dp),
            smallAvatar.topAnchor.constraint(equalTo: section.topAnchor, constant: headerHeight - 200.dp),
            smallAvatar.widthAnchor.constraint(equalToConstant: 150.dp),
            smallAvatar.heightAnchor.constraint(equalToConstant: 150.dp),

            edit.trailingAnchor.constraint(equalTo: smallAvatar.trailingAnchor),
            edit.bottomAnchor.constraint(equalTo: smallAvatar.bottomAnchor),
            edit.widthAnchor.constraint(equalToConstant: 52.dp),
            edit.heightAnchor.constraint(equalToConstant: 52.dp),

            nameLabel.leadingAnchor.constraint(equalTo: smallAvatar.trailingAnchor, constant: 30.dp),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: section.trailingAnchor, constant: -40.dp),
            nameLabel.topAnchor.constraint(equalTo: smallAvatar.topAnchor, constant: 18.dp),

            bio.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bio.trailingAnchor.constraint(equalTo: section.trailingAnchor, constant: -40.dp),
            bio.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 14.dp),

            stats.topAnchor.constraint(equalTo: anchorBelowBio, constant: 28.dp),
            stats.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 40.dp),
            stats.trailingAnchor.constraint(equalTo: section.trailingAnchor, constant: -40.dp),

            follow.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 40.dp),
            follow.trailingAnchor.constraint(equalTo: section.centerXAnchor, constant: -14.dp),
            follow.heightAnchor.constraint(equalToConstant: 116.dp),
            follow.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 36.dp),

            chat.leadingAnchor.constraint(equalTo: section.centerXAnchor, constant: 14.dp),
            chat.trailingAnchor.constraint(equalTo: section.trailingAnchor, constant: -40.dp),
            chat.heightAnchor.constraint(equalToConstant: 116.dp),
            chat.centerYAnchor.constraint(equalTo: follow.centerYAnchor),
        ])

        return section
    }

    private func makePostsSection() -> UIView {
        let wrapper = UIView()
        wrapper.backgroundColor = DesignTokens.Color.background
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        let title = SectionHeader(title: "Posts", showMore: false)
        title.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(title)

        postsStack.axis = .vertical
        postsStack.spacing = 28.dp
        postsStack.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(postsStack)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8.dp),
            title.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32.dp),
            title.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32.dp),

            postsStack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 24.dp),
            postsStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32.dp),
            postsStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32.dp),
            postsStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -48.dp),
        ])

        return wrapper
    }

    @objc private func reloadPosts() {
        postsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts = DemoContent.posts(for: user.id)
        if posts.isEmpty {
            let empty = EmptyStateView(
                title: "No posts yet",
                subtitle: "This walker hasn't shared\nany updates.")
            postsStack.addArrangedSubview(empty)
        } else {
            for post in posts {
                let card = ActivityCardView(item: post)
                wireProfilePostCard(card, item: post)
                postsStack.addArrangedSubview(card)
            }
        }
    }

    private func wireProfilePostCard(_ card: ActivityCardView, item: DemoContent.Activity) {
        wireActivityCard(card, item: item)
        card.onAvatarTap = nil
    }

    // MARK: - Profile helpers

    private func statBlock(_ value: String, _ title: String) -> UIView {
        let v = UIView()
        let num = UILabel()
        num.text = value
        num.font = DesignTokens.Font.bold(40)
        num.textColor = .white
        num.textAlignment = .center
        num.translatesAutoresizingMaskIntoConstraints = false
        let t = UILabel()
        t.text = title
        t.font = DesignTokens.Font.regular(28)
        t.textColor = UIColor(white: 1, alpha: 0.85)
        t.textAlignment = .center
        t.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(num)
        v.addSubview(t)
        NSLayoutConstraint.activate([
            num.topAnchor.constraint(equalTo: v.topAnchor),
            num.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            t.topAnchor.constraint(equalTo: num.bottomAnchor, constant: 8.dp),
            t.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            t.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
    }

    private func makeDogTagsSection(_ dog: DogProfile) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let heading = UILabel()
        heading.text = "Dog"
        heading.font = DesignTokens.Font.semibold(24)
        heading.textColor = UIColor(white: 1, alpha: 0.75)

        let summary = UILabel()
        summary.text = DogWalkingStore.profileSummary(for: dog)
        summary.font = DesignTokens.Font.bold(28)
        summary.textColor = .white
        summary.numberOfLines = 0

        let tagRow = UIStackView()
        tagRow.axis = .horizontal
        tagRow.spacing = 10.dp
        tagRow.alignment = .leading
        for trait in dog.personality {
            tagRow.addArrangedSubview(makeDogTagPill(trait))
        }

        let stack = UIStackView(arrangedSubviews: [heading, summary, tagRow])
        stack.axis = .vertical
        stack.spacing = 8.dp
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        return container
    }

    private func makeDogTagPill(_ text: String) -> UIView {
        let pill = UIView()
        pill.backgroundColor = DesignTokens.Color.accent
        pill.layer.cornerRadius = 18.dp
        pill.layer.masksToBounds = true

        let label = UILabel()
        label.text = text
        label.font = DesignTokens.Font.semibold(22)
        label.textColor = DesignTokens.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 6.dp),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -6.dp),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 16.dp),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -16.dp),
        ])
        return pill
    }

    // MARK: - Actions

    @objc private func tapFollow() {
        DemoContent.setFollowing(!isFollowing, for: user.id)
        applyFollowState(animated: true)
    }

    private func applyFollowState(animated: Bool = false) {
        guard let followButton else { return }
        let following = isFollowing
        let updates = {
            followButton.setTitle(following ? " Following" : " Follow", for: .normal)
            if following {
                followButton.setImage(nil, for: .normal)
                followButton.backgroundColor = DesignTokens.Color.secondaryFill
            } else {
                let pcfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34), weight: .bold)
                followButton.setImage(UIImage(systemName: "plus", withConfiguration: pcfg), for: .normal)
                followButton.backgroundColor = DesignTokens.Color.accent
            }
        }
        if animated {
            InteractionAnimation.pillToggle(on: followButton, updates: updates)
        } else {
            updates()
        }
    }

    @objc private func tapChat() {
        guard isFollowing else {
            let gate = ReminderPopupController(
                title: "Follow Required",
                bodyParts: [
                    ("Please follow ", false),
                    (name, true),
                    (" before you can start a chat.", false),
                ],
                buttonTitle: "Follow & Chat",
                secondaryTitle: "Cancel",
                onSecondary: nil,
                onConfirm: { [weak self] in
                    guard let self else { return }
                    DemoContent.setFollowing(true, for: self.user.id)
                    self.applyFollowState(animated: true)
                    self.openChat()
                })
            gate.present(over: self)
            return
        }
        openChat()
    }

    private func openChat() {
        navigationController?.pushViewController(
            FriendChatViewController(peerName: name, peerAvatar: avatar, peerUserId: user.id),
            animated: true)
    }

    @objc private func openMore() {
        let sheet = ReportBlockSheet(targetName: name) { [weak self] in
            guard let self else { return }
            DemoContent.blockUser(named: self.name)
            self.navigationController?.popViewController(animated: true)
        }
        present(sheet, animated: true)
    }

    @objc private func goBack() { navigationController?.popViewController(animated: true) }
}

// MARK: - Scroll clamp (no pull-down gap above header)

extension UserProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

/// Bottom-anchored dark gradient overlay for legibility over photos.
final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let g = layer as! CAGradientLayer
        g.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.55).cgColor]
        g.locations = [0, 1]
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
