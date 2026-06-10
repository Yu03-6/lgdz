import UIKit

/// Feed/activity post card (used by Home "Dog lovers' activities" and the Feed
/// tab): poster row + text + image + like/comment stats.
final class ActivityCardView: UIView {

    var onAvatarTap: (() -> Void)?
    var onComment: (() -> Void)?
    var onReport: (() -> Void)?
    var onDelete: (() -> Void)?
    private let likeIcon = UIImageView()
    private let likeCount = UILabel()
    private let item: DemoContent.Activity
    private let userId: String
    private let postId: String
    private let isOwnPost: Bool
    private weak var followPill: TagPill?
    private weak var deleteButton: UIButton?

    init(item: DemoContent.Activity) {
        self.item = item
        self.userId = item.userId
        self.postId = item.id
        self.isOwnPost = DemoContent.isOwnPost(item)
        super.init(frame: .zero)
        backgroundColor = DesignTokens.Color.card
        layer.cornerRadius = 36.dp
        build()
        NotificationCenter.default.addObserver(
            self, selector: #selector(followStateChanged(_:)),
            name: .followStateDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(likeStateChanged(_:)),
            name: .likeStateDidChange, object: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func build() {
        let pad = 36.dp

        let avatar = CircleImageView(asset: item.avatar)
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatar)))
        avatar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatar)

        let name = UILabel()
        name.text = item.name
        name.font = DesignTokens.Font.bold(38)
        name.textColor = DesignTokens.Color.textPrimary
        name.lineBreakMode = .byTruncatingTail
        name.translatesAutoresizingMaskIntoConstraints = false
        addSubview(name)

        let time = UILabel()
        time.text = item.time
        time.font = DesignTokens.Font.regular(28)
        time.textColor = DesignTokens.Color.textMuted
        time.translatesAutoresizingMaskIntoConstraints = false
        addSubview(time)

        let trailingAction: UIView
        if isOwnPost {
            let delete = makeDeleteButton()
            deleteButton = delete
            trailingAction = delete
        } else {
            let follow = TagPill(kind: .follow, isOn: DemoContent.isFollowing(userId: userId))
            follow.onToggle = { [self] on in
                DemoContent.setFollowing(on, for: userId)
            }
            follow.setContentCompressionResistancePriority(.required, for: .horizontal)
            follow.setContentHuggingPriority(.required, for: .horizontal)
            followPill = follow
            trailingAction = follow
        }
        trailingAction.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trailingAction)

        let text = UILabel()
        text.text = item.text
        text.numberOfLines = 0
        text.font = DesignTokens.Font.medium(32)
        text.textColor = DesignTokens.Color.textPrimary
        text.translatesAutoresizingMaskIntoConstraints = false
        addSubview(text)

        let hasPhoto = !item.image.isEmpty && PostImageStore.resolveImage(named: item.image) != nil
        let photo = UIImageView()
        if hasPhoto {
            photo.image = PostImageStore.resolveImage(named: item.image)
        }
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.layer.cornerRadius = 24.dp
        photo.isHidden = !hasPhoto
        photo.isUserInteractionEnabled = hasPhoto
        photo.translatesAutoresizingMaskIntoConstraints = false
        addSubview(photo)

        // Top-right report/block trigger on the photo (社区卡片内图片右上角举报拉黑按钮).
        let report = UIButton(type: .custom)
        report.setImage(UIImage(named: "card_more_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        report.imageView?.contentMode = .scaleAspectFit
        report.isHidden = !hasPhoto || isOwnPost
        report.addTarget(self, action: #selector(tapReport), for: .touchUpInside)
        report.translatesAutoresizingMaskIntoConstraints = false
        photo.addSubview(report)

        // stats row
        likeIcon.contentMode = .scaleAspectFit
        likeCount.text = item.likes
        applyLikeState(animated: false)
        let comments = statLabel(asset: "icon_comment", value: item.comments)
        let likeGroup = makeStat(icon: likeIcon, label: likeCount)

        let statsRow = UIStackView(arrangedSubviews: [likeGroup, comments])
        statsRow.axis = .horizontal
        statsRow.distribution = .fillEqually
        statsRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statsRow)

        let likeTap = UITapGestureRecognizer(target: self, action: #selector(toggleLike))
        likeGroup.isUserInteractionEnabled = true
        likeGroup.addGestureRecognizer(likeTap)

        comments.isUserInteractionEnabled = true
        comments.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapComment)))

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            avatar.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            avatar.widthAnchor.constraint(equalToConstant: 96.dp),
            avatar.heightAnchor.constraint(equalToConstant: 96.dp),

            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 24.dp),
            name.topAnchor.constraint(equalTo: avatar.topAnchor, constant: 4.dp),
            name.trailingAnchor.constraint(lessThanOrEqualTo: trailingAction.leadingAnchor, constant: -16.dp),
            time.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            time.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10.dp),

            trailingAction.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            trailingAction.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            trailingAction.heightAnchor.constraint(equalToConstant: 78.dp),

            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            text.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            text.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 28.dp),

            statsRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            statsRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            statsRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),
            statsRow.heightAnchor.constraint(equalToConstant: 60.dp),
        ])

        if hasPhoto, !isOwnPost {
            NSLayoutConstraint.activate([
                photo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
                photo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
                photo.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 26.dp),
                photo.heightAnchor.constraint(equalTo: photo.widthAnchor, multiplier: 0.62),

                report.trailingAnchor.constraint(equalTo: photo.trailingAnchor, constant: -24.dp),
                report.topAnchor.constraint(equalTo: photo.topAnchor, constant: 24.dp),
                report.widthAnchor.constraint(equalToConstant: 56.dp),
                report.heightAnchor.constraint(equalToConstant: 56.dp),

                statsRow.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 28.dp),
            ])
        } else if hasPhoto {
            NSLayoutConstraint.activate([
                photo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
                photo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
                photo.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 26.dp),
                photo.heightAnchor.constraint(equalTo: photo.widthAnchor, multiplier: 0.62),
                statsRow.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 28.dp),
            ])
        } else {
            statsRow.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 28.dp).isActive = true
        }
    }

    @objc private func followStateChanged(_ note: Notification) {
        guard let changedId = note.userInfo?[FollowUserInfoKey.userId] as? String,
              changedId == userId,
              let following = note.userInfo?[FollowUserInfoKey.following] as? Bool else { return }
        followPill?.setOn(following, animated: true)
    }

    @objc private func likeStateChanged(_ note: Notification) {
        guard let changedId = note.userInfo?[LikePostInfoKey.postId] as? String,
              changedId == postId else { return }
        applyLikeState(animated: false)
    }

    private func applyLikeState(animated: Bool) {
        let liked = DemoContent.isLiked(postId: postId)
        let updates = {
            self.likeIcon.image = UIImage(systemName: liked ? "heart.fill" : "heart")
            self.likeIcon.tintColor = liked ? DesignTokens.Color.accentYellow : DesignTokens.Color.textMuted
        }
        if animated {
            InteractionAnimation.likeToggle(
                on: likeIcon, label: likeCount, liked: liked, updates: updates)
        } else {
            updates()
        }
    }

    private func makeStat(icon: UIImageView, label: UILabel) -> UIView {
        let container = UIView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignTokens.Font.medium(30)
        label.textColor = DesignTokens.Color.textMuted
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 46.dp),
            icon.heightAnchor.constraint(equalToConstant: 46.dp),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14.dp),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
        ])
        return container
    }

    private func statLabel(asset: String, value: String) -> UIView {
        let iv = UIImageView(image: UIImage(named: asset)?.withRenderingMode(.alwaysOriginal))
        iv.contentMode = .scaleAspectFit
        let l = UILabel()
        l.text = value
        return makeStat(icon: iv, label: l)
    }

    private func makeDeleteButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(" Delete", for: .normal)
        btn.titleLabel?.font = DesignTokens.Font.semibold(30)
        btn.setTitleColor(DesignTokens.Color.danger, for: .normal)
        btn.backgroundColor = DesignTokens.Color.secondaryFill
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 44.dp, bottom: 0, right: 44.dp)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(28), weight: .bold)
        btn.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        btn.tintColor = DesignTokens.Color.danger
        btn.setContentCompressionResistancePriority(.required, for: .horizontal)
        btn.setContentHuggingPriority(.required, for: .horizontal)
        btn.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        return btn
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let deleteButton {
            deleteButton.layer.cornerRadius = deleteButton.bounds.height / 2
            deleteButton.layer.masksToBounds = true
        }
    }

    @objc private func tapAvatar() { onAvatarTap?() }
    @objc private func tapComment() { onComment?() }
    @objc private func tapReport() { onReport?() }
    @objc private func tapDelete() { onDelete?() }

    @objc private func toggleLike() {
        let next = !DemoContent.isLiked(postId: postId)
        DemoContent.setLiked(next, for: postId)
        applyLikeState(animated: true)
    }
}

extension UIViewController {
    /// Wire avatar / comment / report handlers for a feed activity card.
    func wireActivityCard(_ card: ActivityCardView, item: DemoContent.Activity) {
        card.onAvatarTap = { [weak self] in
            guard let user = DemoContent.feedUser(for: item) else { return }
            self?.navigationController?.pushViewController(UserProfileViewController(user: user), animated: true)
        }
        card.onComment = { [weak self] in
            self?.navigationController?.pushViewController(CommentDetailViewController(item: item), animated: true)
        }
        card.onReport = { [weak self] in
            self?.present(ReportBlockSheet(targetName: item.name), animated: true)
        }
        if DemoContent.isOwnPost(item) {
            card.onDelete = { [weak self] in
                let popup = ReminderPopupController(
                    title: "Delete post?",
                    bodyParts: [("This post will be removed from your profile and the community feed.", false)],
                    buttonTitle: "Delete",
                    secondaryTitle: "Cancel",
                    onConfirm: { DemoContent.deleteUserPost(postId: item.id) })
                self?.present(popup, animated: true)
            }
        }
    }
}
