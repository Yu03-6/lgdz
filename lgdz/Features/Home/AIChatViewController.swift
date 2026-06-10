import UIKit

/// Screen 8 — AI Dog Assistant chat. Background cutout (`ai_chat_bg`) bakes in
/// the header + robot. Messages overlay; input bar pinned above the keyboard.
/// Pricing (screen 9): each user message costs 1 coin (§3 #8).
final class AIChatViewController: UIViewController {

    private let pageContainer = UIView()
    private let bottomFillView = UIView()
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let inputBar = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var pageBottom: NSLayoutConstraint!
    private var inputBottom: NSLayoutConstraint!
    private var keyboardObserver: NSObjectProtocol?

    private let coinCost = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.Color.card
        hideSystemNavBar()
        setupBottomFill()
        setupPageContainer()
        setupBackground()
        setupHeaderButtons()
        setupScroll()
        setupInputBar()
        setupKeyboardAvoidance()
        reload()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scroll.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pageBottom.constant == 0 {
            inputBottom.constant = -(10.dp + view.safeAreaInsets.bottom)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        DemoContent.markConversationRead(name: "AI Assistant")
        reload()
    }

    deinit {
        if let keyboardObserver { NotificationCenter.default.removeObserver(keyboardObserver) }
    }

    private func setupBottomFill() {
        bottomFillView.backgroundColor = DesignTokens.Color.card
        bottomFillView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomFillView)
        NSLayoutConstraint.activate([
            bottomFillView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomFillView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFillView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFillView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupPageContainer() {
        pageContainer.translatesAutoresizingMaskIntoConstraints = false
        pageContainer.clipsToBounds = true
        view.addSubview(pageContainer)
        pageBottom = pageContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            pageContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainer.heightAnchor.constraint(equalTo: view.heightAnchor),
            pageBottom,
        ])
    }

    private func setupBackground() {
        let bg = UIImageView(image: UIImage(named: "ai_chat_bg"))
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.translatesAutoresizingMaskIntoConstraints = false
        pageContainer.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: pageContainer.topAnchor),
            bg.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor),
        ])
    }

    private func setupHeaderButtons() {
        let back = NavHeader(title: nil) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            back.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            back.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),
        ])
    }

    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        pageContainer.addSubview(scroll)
        stack.axis = .vertical
        stack.spacing = 16.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: pageContainer.topAnchor, constant: 720.dp),
            scroll.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 36.dp),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -36.dp),
        ])
    }

    private func setupInputBar() {
        inputBar.backgroundColor = .clear
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        pageContainer.addSubview(inputBar)

        let field = UIView()
        field.backgroundColor = UIColor(hex: 0xEFEFEF)
        field.layer.cornerRadius = 50.dp
        field.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(field)

        inputField.placeholder = "Type a message..."
        inputField.font = DesignTokens.Font.regular(30)
        inputField.textColor = DesignTokens.Color.textPrimary
        inputField.returnKeyType = .send
        inputField.delegate = self
        inputField.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(inputField)

        sendButton.backgroundColor = DesignTokens.Color.accent
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(36), weight: .bold)
        sendButton.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg), for: .normal)
        sendButton.tintColor = DesignTokens.Color.textPrimary
        sendButton.layer.cornerRadius = 50.dp
        sendButton.addTarget(self, action: #selector(tapSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(sendButton)

        inputBottom = inputBar.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor, constant: -10.dp)
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor, constant: 36.dp),
            inputBar.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor, constant: -36.dp),
            inputBottom,
            inputBar.heightAnchor.constraint(equalToConstant: 100.dp),

            field.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor),
            field.topAnchor.constraint(equalTo: inputBar.topAnchor),
            field.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor),
            field.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -20.dp),

            inputField.leadingAnchor.constraint(equalTo: field.leadingAnchor, constant: 40.dp),
            inputField.trailingAnchor.constraint(equalTo: field.trailingAnchor, constant: -20.dp),
            inputField.centerYAnchor.constraint(equalTo: field.centerYAnchor),

            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 100.dp),
            sendButton.heightAnchor.constraint(equalToConstant: 100.dp),

            scroll.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -12.dp),
        ])
    }

    private func setupKeyboardAvoidance() {
        keyboardObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
    }

    private func handleKeyboard(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = max(0, view.bounds.height - frame.origin.y)
        let keyboardVisible = overlap > 0
        pageBottom.constant = keyboardVisible ? -overlap : 0
        inputBottom.constant = keyboardVisible
            ? -10.dp
            : -(10.dp + view.safeAreaInsets.bottom)
        animateLayout(note)
        scrollToBottom()
    }

    private func animateLayout(_ note: Notification) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let curve = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 7
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) {
            self.view.layoutIfNeeded()
        }
    }

    private func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for m in DemoContent.aiChatMessagesList() {
            stack.addArrangedSubview(makeBubble(m))
        }
        view.layoutIfNeeded()
        scrollToBottom()
    }

    private func scrollToBottom() {
        let bottom = max(0, scroll.contentSize.height - scroll.bounds.height + scroll.contentInset.bottom)
        if scroll.contentSize.height > scroll.bounds.height {
            scroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
        }
    }

    private func makeBubble(_ m: DemoContent.ChatMessage) -> UIView {
        let row = UIView()

        let bubble = UILabel()
        bubble.text = m.text
        bubble.numberOfLines = 0
        bubble.font = DesignTokens.Font.medium(30)
        bubble.textColor = m.fromUser ? .white : DesignTokens.Color.textPrimary
        let bg = PaddedContainer(label: bubble,
                                 inset: UIEdgeInsets(top: 26.dp, left: 32.dp, bottom: 26.dp, right: 32.dp))
        bg.backgroundColor = m.fromUser ? DesignTokens.Color.textPrimary : DesignTokens.Color.accent
        bg.layer.cornerRadius = 28.dp
        bg.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(bg)

        let userAvatar = AppSession.shared.current?.avatarAsset ?? "avatar_user"
        let avatar = CircleImageView(asset: m.fromUser ? userAvatar : "ai_robot")
        avatar.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(avatar)

        let time = UILabel()
        time.text = m.time
        time.font = DesignTokens.Font.regular(24)
        time.textColor = DesignTokens.Color.textMuted
        time.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(time)

        let avatarSize = 84.dp
        if m.fromUser {
            NSLayoutConstraint.activate([
                avatar.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                avatar.topAnchor.constraint(equalTo: row.topAnchor),
                avatar.widthAnchor.constraint(equalToConstant: avatarSize),
                avatar.heightAnchor.constraint(equalToConstant: avatarSize),
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
                avatar.widthAnchor.constraint(equalToConstant: avatarSize),
                avatar.heightAnchor.constraint(equalToConstant: avatarSize),
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

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func tapSend() {
        let text = (inputField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        if AppSession.shared.spend(coinCost) {
            commitSend(text)
        } else {
            showInsufficient()
        }
    }

    private func showInsufficient() {
        let popup = ReminderPopupController(
            title: "Friendly Reminder",
            bodyParts: [("Not enough coins. Each message costs ", false),
                        ("\(coinCost)", true), (" coins. Please top up.", false)],
            buttonTitle: "Recharge") { [weak self] in
                self?.navigationController?.pushViewController(RechargeViewController(), animated: true)
            }
        popup.present(over: self)
    }

    private func commitSend(_ text: String) {
        inputField.text = ""
        inputField.resignFirstResponder()
        DemoContent.appendAIChatMessage(
            DemoContent.ChatMessage(text: text, fromUser: true, time: currentTime()))
        reload()
        let reply = AIReplyEngine.reply(to: text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            DemoContent.appendAIChatMessage(
                DemoContent.ChatMessage(text: reply, fromUser: false, time: self.currentTime()))
            self.reload()
        }
    }
}

extension AIChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tapSend()
        return false
    }
}

/// A view that wraps a single label with padding (for chat bubbles).
final class PaddedContainer: UIView {
    init(label: UILabel, inset: UIEdgeInsets) {
        super.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset.top),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset.right),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
