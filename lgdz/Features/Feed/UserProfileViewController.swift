import UIKit

/// Screen 17 — User profile (个人主页). Full-bleed portrait header, overlapping
/// avatar with edit badge, name + bio, stats row, Follow + Chat actions.
final class UserProfileViewController: UIViewController {

    private let user: DemoContent.FeedUser
    private var name: String { user.name }
    private var avatar: String { user.avatar }
    private weak var followButton: PillButton?

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
        build()
        NotificationCenter.default.addObserver(
            self, selector: #selector(followStateChanged(_:)),
            name: .followStateDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        applyFollowState()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func followStateChanged(_ note: Notification) {
        guard let changedId = note.userInfo?[FollowUserInfoKey.userId] as? String,
              changedId == user.id else { return }
        applyFollowState(animated: true)
    }

    private func build() {
        let photo = UIImageView(image: UIImage(named: user.coverImage))
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photo)

        // gradient to keep bottom text legible
        let gradient = GradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradient)

        let back = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(44), weight: .semibold)
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

        let smallAvatar = CircleImageView(asset: user.avatar)
        smallAvatar.layer.borderWidth = 4
        smallAvatar.layer.borderColor = UIColor.white.cgColor
        smallAvatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(smallAvatar)

        let edit = UIImageView(image: UIImage(systemName: "pencil"))
        edit.tintColor = .white
        edit.contentMode = .center
        edit.backgroundColor = DesignTokens.Color.accentYellow
        edit.layer.cornerRadius = 26.dp
        edit.layer.masksToBounds = true
        edit.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(edit)

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = DesignTokens.Font.bold(48)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        let bio = UILabel()
        bio.text = user.bio
        bio.font = DesignTokens.Font.regular(32)
        bio.textColor = UIColor(white: 1, alpha: 0.9)
        bio.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bio)

        let stats = UIStackView(arrangedSubviews: [
            statBlock("\(user.friends)", "Friends"),
            statBlock("\(user.followed)", "Followed"),
            statBlock("\(user.fans)", "Fans"),
        ])
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stats)

        let follow = PillButton(style: .primary, title: " Follow")
        follow.designCornerRadius = 36
        let pcfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34), weight: .bold)
        follow.setImage(UIImage(systemName: "plus", withConfiguration: pcfg), for: .normal)
        follow.semanticContentAttribute = .forceLeftToRight
        follow.addTarget(self, action: #selector(tapFollow), for: .touchUpInside)
        follow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(follow)
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
        view.addSubview(chat)

        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: view.topAnchor),
            photo.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photo.bottomAnchor.constraint(equalTo: stats.bottomAnchor, constant: 40.dp),
            gradient.leadingAnchor.constraint(equalTo: photo.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: photo.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: photo.bottomAnchor),
            gradient.heightAnchor.constraint(equalToConstant: 700.dp),

            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.dp),
            more.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            more.centerYAnchor.constraint(equalTo: back.centerYAnchor),

            smallAvatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            smallAvatar.bottomAnchor.constraint(equalTo: stats.topAnchor, constant: -40.dp),
            smallAvatar.widthAnchor.constraint(equalToConstant: 150.dp),
            smallAvatar.heightAnchor.constraint(equalToConstant: 150.dp),
            edit.trailingAnchor.constraint(equalTo: smallAvatar.trailingAnchor),
            edit.bottomAnchor.constraint(equalTo: smallAvatar.bottomAnchor),
            edit.widthAnchor.constraint(equalToConstant: 52.dp),
            edit.heightAnchor.constraint(equalToConstant: 52.dp),

            nameLabel.leadingAnchor.constraint(equalTo: smallAvatar.trailingAnchor, constant: 30.dp),
            nameLabel.topAnchor.constraint(equalTo: smallAvatar.topAnchor, constant: 18.dp),
            bio.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bio.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 14.dp),

            stats.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            stats.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            stats.bottomAnchor.constraint(equalTo: follow.topAnchor, constant: -36.dp),

            follow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            follow.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -14.dp),
            follow.heightAnchor.constraint(equalToConstant: 116.dp),
            follow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24.dp),
            chat.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 14.dp),
            chat.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            chat.heightAnchor.constraint(equalToConstant: 116.dp),
            chat.centerYAnchor.constraint(equalTo: follow.centerYAnchor),
        ])
    }

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
        v.addSubview(num); v.addSubview(t)
        NSLayoutConstraint.activate([
            num.topAnchor.constraint(equalTo: v.topAnchor),
            num.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            t.topAnchor.constraint(equalTo: num.bottomAnchor, constant: 8.dp),
            t.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            t.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
    }

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

    // Screen 23 — FollowGate: must follow before chat; global popup_card UI when not followed.
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

    // Screen 24 — report / block sheet.
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
