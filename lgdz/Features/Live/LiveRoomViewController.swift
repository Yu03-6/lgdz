import AVFoundation
import UIKit

/// Screen 11 — Hot live room. Full-screen video with host bar, scrolling chat
/// overlay and an input + heart bar.
final class LiveRoomViewController: UIViewController {

    private let room: DemoContent.LiveRoom
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var loopObserver: NSObjectProtocol?

    private let commentOverlay = LiveCommentOverlayView()
    private let heartBurstView = LiveHeartBurstView()
    private let inputBar = UIView()
    private let inputField = UITextField()
    private var inputBottom: NSLayoutConstraint!
    private var keyboardAvoidance: KeyboardBottomBarAvoidance?
    private weak var heartButton: UIButton?
    private weak var followButton: TagPill?

    init(room: DemoContent.LiveRoom) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        hideSystemNavBar()
        setupVideo()
        setupTopBar()
        setupCommentOverlay()
        setupHeartBurstLayer()
        setupInputBar()
        configureComments()
        keyboardAvoidance = KeyboardBottomBarAvoidance()
        keyboardAvoidance?.start(hostView: view, bottomConstraint: inputBottom, restingConstant: -16.dp)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        player?.play()
        commentOverlay.startAutoFeed()
        syncFollowButton()
    }

    private func syncFollowButton() {
        followButton?.setOn(DemoContent.isFollowingLive(roomId: room.id), animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        commentOverlay.stopAutoFeed()
    }

    deinit {
        if let loopObserver {
            NotificationCenter.default.removeObserver(loopObserver)
        }
        player?.pause()
        commentOverlay.stopAutoFeed()
    }

    private func configureComments() {
        let pool = DemoContent.liveCommentPool(forRoomId: room.id).map {
            LiveCommentOverlayView.Message(
                avatar: $0.avatar, name: $0.name, text: $0.text, isSelf: false)
        }
        commentOverlay.configure(pool: pool)
    }

    private var userAvatarAsset: String {
        AppSession.shared.current?.avatarAsset ?? "avatar_user"
    }

    private func setupVideo() {
        let fallback = UIImageView(image: UIImage(named: room.cover))
        fallback.contentMode = .scaleAspectFill
        fallback.clipsToBounds = true
        fallback.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fallback)
        NSLayoutConstraint.activate([
            fallback.topAnchor.constraint(equalTo: view.topAnchor),
            fallback.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallback.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fallback.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        guard let url = Bundle.main.url(forResource: room.videoAsset, withExtension: "mp4") else { return }
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.isMuted = false
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, above: fallback.layer)
        playerLayer = layer

        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        player.play()
    }

    private func setupTopBar() {
        let back = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(44), weight: .semibold)
        back.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let avatar = CircleImageView(asset: room.hostAvatar)
        avatar.layer.borderWidth = 3
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)

        let name = UILabel()
        name.text = room.title
        name.font = DesignTokens.Font.bold(36)
        name.textColor = .white
        name.numberOfLines = 2
        name.lineBreakMode = .byTruncatingTail
        name.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(name)

        let viewers = UILabel()
        viewers.text = "👁 \(room.viewers)"
        viewers.font = DesignTokens.Font.semibold(24)
        viewers.textColor = .white
        viewers.backgroundColor = UIColor(white: 0, alpha: 0.35)
        viewers.textAlignment = .center
        viewers.layer.cornerRadius = 22.dp
        viewers.layer.masksToBounds = true
        viewers.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewers)

        let follow = TagPill(
            kind: .follow,
            isOn: DemoContent.isFollowingLive(roomId: room.id),
            followStyle: .live)
        follow.translatesAutoresizingMaskIntoConstraints = false
        follow.setContentCompressionResistancePriority(.required, for: .horizontal)
        follow.setContentHuggingPriority(.required, for: .horizontal)
        follow.onToggle = { [weak self] on in
            guard let self else { return }
            DemoContent.setFollowingLive(on, for: self.room.id)
        }
        view.addSubview(follow)
        followButton = follow

        name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.dp),

            avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            avatar.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 30.dp),
            avatar.widthAnchor.constraint(equalToConstant: 96.dp),
            avatar.heightAnchor.constraint(equalToConstant: 96.dp),

            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 24.dp),
            name.topAnchor.constraint(equalTo: avatar.topAnchor, constant: 4.dp),
            name.trailingAnchor.constraint(lessThanOrEqualTo: follow.leadingAnchor, constant: -16.dp),

            viewers.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            viewers.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 12.dp),
            viewers.widthAnchor.constraint(equalToConstant: 120.dp),
            viewers.heightAnchor.constraint(equalToConstant: 44.dp),

            follow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            follow.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            follow.heightAnchor.constraint(equalToConstant: 80.dp),
            follow.widthAnchor.constraint(equalToConstant: 248.dp),
        ])
    }

    private func setupCommentOverlay() {
        commentOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(commentOverlay)
        NSLayoutConstraint.activate([
            commentOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            commentOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -200.dp),
            commentOverlay.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140.dp),
            commentOverlay.heightAnchor.constraint(equalToConstant: 320.dp),
        ])
    }

    private func setupHeartBurstLayer() {
        heartBurstView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heartBurstView)
        NSLayoutConstraint.activate([
            heartBurstView.topAnchor.constraint(equalTo: view.topAnchor),
            heartBurstView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heartBurstView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heartBurstView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupInputBar() {
        inputBar.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        inputBar.layer.cornerRadius = 44.dp
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)

        inputField.font = DesignTokens.Font.regular(30)
        inputField.textColor = .white
        inputField.tintColor = DesignTokens.Color.accentYellow
        inputField.returnKeyType = .send
        inputField.delegate = self
        inputField.autocapitalizationType = .sentences
        inputField.autocorrectionType = .default
        inputField.attributedPlaceholder = NSAttributedString(
            string: "Type a message...",
            attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(inputField)

        let heart = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(44))
        heart.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .normal)
        heart.tintColor = UIColor(hex: 0xFF4D6D)
        heart.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        heart.layer.cornerRadius = 44.dp
        heart.translatesAutoresizingMaskIntoConstraints = false
        heart.addTarget(self, action: #selector(tapHeart), for: .touchUpInside)
        view.addSubview(heart)
        heartButton = heart

        inputBottom = inputBar.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.dp)

        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            inputBottom,
            inputBar.heightAnchor.constraint(equalToConstant: 88.dp),
            inputBar.trailingAnchor.constraint(equalTo: heart.leadingAnchor, constant: -24.dp),
            inputField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 36.dp),
            inputField.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -20.dp),
            inputField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            heart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            heart.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            heart.widthAnchor.constraint(equalToConstant: 88.dp),
            heart.heightAnchor.constraint(equalToConstant: 88.dp),
        ])
    }

    private func sendComment() {
        let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        commentOverlay.appendUserComment(text: text, avatar: userAvatarAsset)
        inputField.text = nil
        inputField.resignFirstResponder()
    }

    @objc private func tapHeart() {
        guard let heartButton, let anchor = heartButton.superview else { return }
        InteractionAnimation.bounce(heartButton, peakScale: 1.14)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let point = heartBurstView.convert(heartButton.center, from: anchor)
        heartBurstView.burst(from: point)
    }

    @objc private func goBack() { navigationController?.popViewController(animated: true) }
}

extension LiveRoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return false
    }
}
