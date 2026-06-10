import UIKit

/// Screen 19 — Friend chat. Header (name + video + menu), message bubbles
/// (user = dark green right, peer = lime left), input bar above keyboard.
/// Local template messages only (§6: chat 仅 UI).
final class FriendChatViewController: UIViewController {

    private let peerName: String
    private let peerAvatar: String
    private let peerUserId: String?

    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let inputBar = UIView()
    private let inputField = UITextField()
    private var inputBottom: NSLayoutConstraint!
    private var keyboardAvoidance: KeyboardBottomBarAvoidance?

    private var messages: [DemoContent.ChatMessage] = []

    private weak var videoButton: UIButton?
    private weak var reportButton: UIButton?

    private var isSystemChat: Bool { peerName == "System" }

    private var chatStorageId: String {
        DemoContent.chatPeerId(peerName: peerName, userId: peerUserId)
    }

    init(peerName: String, peerAvatar: String, peerUserId: String? = nil) {
        self.peerName = peerName
        self.peerAvatar = peerAvatar
        self.peerUserId = peerUserId ?? DemoContent.userId(forName: peerName)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupHeader()
        setupInputBar()
        setupScroll()
        if let videoButton { view.bringSubviewToFront(videoButton) }
        if let reportButton { view.bringSubviewToFront(reportButton) }
        syncMessagesFromStore()
        keyboardAvoidance = KeyboardBottomBarAvoidance()
        keyboardAvoidance?.start(hostView: view, bottomConstraint: inputBottom, restingConstant: -10.dp)
        keyboardAvoidance?.onChange = { [weak self] in self?.scrollToBottom() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        DemoContent.markConversationRead(name: peerName)
        syncMessagesFromStore()
    }

    private func syncMessagesFromStore() {
        messages = DemoContent.chatMessages(peerName: peerName, userId: peerUserId)
        reload()
    }

    private func setupHeader() {
        let header = NavHeader(title: peerName) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        var constraints: [NSLayoutConstraint] = [
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),
        ]

        if !isSystemChat {
            let report = UIButton(type: .custom)
            report.setImage(UIImage(named: "chat_report_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
            report.imageView?.contentMode = .scaleAspectFit
            report.addTarget(self, action: #selector(tapReportBlock), for: .touchUpInside)
            report.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(report)
            reportButton = report

            let video = UIButton(type: .custom)
            video.setImage(UIImage(named: "chat_video_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
            video.imageView?.contentMode = .scaleAspectFit
            video.addTarget(self, action: #selector(tapVideo), for: .touchUpInside)
            video.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(video)
            videoButton = video

            let btnSize = 60.dp
            constraints += [
                report.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
                report.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                report.widthAnchor.constraint(equalToConstant: btnSize),
                report.heightAnchor.constraint(equalToConstant: btnSize),
                video.trailingAnchor.constraint(equalTo: report.leadingAnchor, constant: -24.dp),
                video.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                video.widthAnchor.constraint(equalToConstant: btnSize),
                video.heightAnchor.constraint(equalToConstant: btnSize),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)
        stack.axis = .vertical
        stack.spacing = 20.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: NavHeader.designHeight.dp + 20.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -12.dp),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 36.dp),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -36.dp),
        ])
    }

    private func setupInputBar() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        let bar = inputBar
        let field = UIView()
        field.backgroundColor = .white
        field.layer.cornerRadius = 50.dp
        field.layer.borderWidth = 1
        field.layer.borderColor = DesignTokens.Color.separator.cgColor
        field.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(field)
        inputField.placeholder = "Type a message..."
        inputField.font = DesignTokens.Font.regular(30)
        inputField.textColor = DesignTokens.Color.textPrimary
        inputField.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(inputField)
        let send = UIButton(type: .system)
        send.backgroundColor = DesignTokens.Color.accent
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(36), weight: .bold)
        send.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg), for: .normal)
        send.tintColor = DesignTokens.Color.textPrimary
        send.layer.cornerRadius = 50.dp
        send.addTarget(self, action: #selector(tapSend), for: .touchUpInside)
        send.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(send)

        inputBottom = bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.dp)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36.dp),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36.dp),
            inputBottom,
            bar.heightAnchor.constraint(equalToConstant: 100.dp),
            field.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            field.topAnchor.constraint(equalTo: bar.topAnchor),
            field.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -20.dp),
            inputField.leadingAnchor.constraint(equalTo: field.leadingAnchor, constant: 40.dp),
            inputField.trailingAnchor.constraint(equalTo: field.trailingAnchor, constant: -20.dp),
            inputField.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            send.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            send.widthAnchor.constraint(equalToConstant: 100.dp),
            send.heightAnchor.constraint(equalToConstant: 100.dp),
        ])
    }

    private func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for m in messages { stack.addArrangedSubview(makeBubble(m)) }
        scrollToBottom()
    }

    private func scrollToBottom() {
        view.layoutIfNeeded()
        let bottom = max(0, scroll.contentSize.height - scroll.bounds.height)
        if scroll.contentSize.height > scroll.bounds.height {
            scroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
        }
    }

    private func makeBubble(_ m: DemoContent.ChatMessage) -> UIView {
        let row = UIView()
        let label = UILabel()
        label.text = m.text
        label.numberOfLines = 0
        label.font = DesignTokens.Font.medium(30)
        label.textColor = m.fromUser ? .white : DesignTokens.Color.textPrimary
        let bg = PaddedContainer(label: label,
                                 inset: UIEdgeInsets(top: 26.dp, left: 32.dp, bottom: 26.dp, right: 32.dp))
        bg.backgroundColor = m.fromUser ? DesignTokens.Color.textPrimary : DesignTokens.Color.accent
        bg.layer.cornerRadius = 28.dp
        bg.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(bg)
        let avatar = CircleImageView(asset: m.fromUser ? "content_dog1" : peerAvatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(avatar)
        let time = UILabel()
        time.text = m.time
        time.font = DesignTokens.Font.regular(24)
        time.textColor = DesignTokens.Color.textMuted
        time.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(time)
        let aSize = 84.dp
        if m.fromUser {
            NSLayoutConstraint.activate([
                avatar.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                avatar.topAnchor.constraint(equalTo: row.topAnchor),
                avatar.widthAnchor.constraint(equalToConstant: aSize),
                avatar.heightAnchor.constraint(equalToConstant: aSize),
                bg.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -20.dp),
                bg.topAnchor.constraint(equalTo: row.topAnchor),
                bg.leadingAnchor.constraint(greaterThanOrEqualTo: row.leadingAnchor, constant: 80.dp),
                time.trailingAnchor.constraint(equalTo: bg.trailingAnchor),
                time.topAnchor.constraint(equalTo: bg.bottomAnchor, constant: 12.dp),
                time.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                avatar.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                avatar.topAnchor.constraint(equalTo: row.topAnchor),
                avatar.widthAnchor.constraint(equalToConstant: aSize),
                avatar.heightAnchor.constraint(equalToConstant: aSize),
                bg.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 20.dp),
                bg.topAnchor.constraint(equalTo: row.topAnchor),
                bg.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -80.dp),
                time.leadingAnchor.constraint(equalTo: bg.leadingAnchor),
                time.topAnchor.constraint(equalTo: bg.bottomAnchor, constant: 12.dp),
                time.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            ])
        }
        return row
    }

    private func currentTime() -> String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; f.amSymbol = "am"; f.pmSymbol = "pm"
        return f.string(from: Date()).lowercased()
    }

    @objc private func tapSend() {
        let text = (inputField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputField.text = ""
        let outgoing = DemoContent.ChatMessage(text: text, fromUser: true, time: currentTime())
        DemoContent.appendChatMessage(outgoing, forUserId: chatStorageId)
        syncMessagesFromStore()
    }

    @objc private func tapVideo() {
        navigationController?.pushViewController(
            VideoChatViewController(peerName: peerName, peerAvatar: peerAvatar),
            animated: true
        )
    }

    @objc private func tapReportBlock() {
        let sheet = ReportBlockSheet(targetName: peerName) { [weak self] in
            guard let self else { return }
            DemoContent.blockUser(named: self.peerName)
            self.navigationController?.popViewController(animated: true)
        }
        present(sheet, animated: true)
    }

}
