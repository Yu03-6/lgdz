import UIKit

/// 评论详情 — Comment details. The post card on top, a Comment list, and an
/// input bar pinned above the keyboard. Comments are local demo data (§6).
final class CommentDetailViewController: UIViewController {

    private let item: DemoContent.Activity
    private let scroll = UIScrollView()
    private let content = UIStackView()
    private let inputField = UITextField()
    private var inputBottom: NSLayoutConstraint!

    private var comments: [DemoContent.PostComment]

    init(item: DemoContent.Activity) {
        self.item = item
        self.comments = DemoContent.comments(for: item.id)
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
        reload()
        NotificationCenter.default.addObserver(
            self, selector: #selector(postDeleted(_:)),
            name: .userPostDidDelete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func postDeleted(_ note: Notification) {
        guard let deletedId = note.object as? String, deletedId == item.id else { return }
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        syncCommentsFromStore()
    }

    private func syncCommentsFromStore() {
        comments = DemoContent.comments(for: item.id)
        reload()
        view.layoutIfNeeded()
        let bottom = max(0, scroll.contentSize.height - scroll.bounds.height)
        if scroll.contentSize.height > scroll.bounds.height {
            scroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
        }
    }

    private func setupHeader() {
        let header = NavHeader(title: "Comment details") { [weak self] in
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
        headerBottom = header.bottomAnchor
    }
    private var headerBottom: NSLayoutYAxisAnchor!

    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset.bottom = 40.dp
        view.addSubview(scroll)
        content.axis = .vertical
        content.spacing = 24.dp
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: headerBottom, constant: 16.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: inputBarTopGuide),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 32.dp),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -32.dp),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -64.dp),
        ])
    }

    private let inputBar = UIView()
    private var inputBarTopGuide: NSLayoutYAxisAnchor { inputBar.topAnchor }

    private func setupInputBar() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        let field = UIView()
        field.backgroundColor = .white
        field.layer.cornerRadius = 50.dp
        field.layer.borderWidth = 1
        field.layer.borderColor = DesignTokens.Color.separator.cgColor
        field.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(field)
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
        inputBar.addSubview(send)

        inputBottom = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.dp)
        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.dp),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.dp),
            inputBottom,
            inputBar.heightAnchor.constraint(equalToConstant: 110.dp),
            field.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor),
            field.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: 10.dp),
            field.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor, constant: -10.dp),
            field.trailingAnchor.constraint(equalTo: send.leadingAnchor, constant: -20.dp),
            inputField.leadingAnchor.constraint(equalTo: field.leadingAnchor, constant: 40.dp),
            inputField.trailingAnchor.constraint(equalTo: field.trailingAnchor, constant: -20.dp),
            inputField.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor),
            send.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            send.widthAnchor.constraint(equalToConstant: 100.dp),
            send.heightAnchor.constraint(equalToConstant: 100.dp),
        ])
    }

    private func reload() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let post = ActivityCardView(item: item)
        wireActivityCard(post, item: item)
        content.addArrangedSubview(post)
        content.setCustomSpacing(36.dp, after: post)

        let title = SectionHeader(title: "Comment", showMore: false)
        content.addArrangedSubview(title)
        content.setCustomSpacing(20.dp, after: title)

        for (i, c) in comments.enumerated() { content.addArrangedSubview(makeCommentRow(c, index: i)) }
    }

    private func makeCommentRow(_ c: DemoContent.PostComment, index: Int) -> UIView {
        let row = UIView()
        let avatar = CircleImageView(asset: c.avatar)
        avatar.isUserInteractionEnabled = true
        avatar.tag = index
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCommentAvatar(_:))))
        avatar.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(avatar)
        let name = UILabel()
        name.text = c.name
        name.font = DesignTokens.Font.bold(32)
        name.textColor = DesignTokens.Color.textPrimary
        name.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(name)
        let text = UILabel()
        text.text = c.text
        text.numberOfLines = 0
        text.font = DesignTokens.Font.regular(30)
        text.textColor = DesignTokens.Color.textMuted
        text.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(text)
        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            avatar.topAnchor.constraint(equalTo: row.topAnchor, constant: 4.dp),
            avatar.widthAnchor.constraint(equalToConstant: 80.dp),
            avatar.heightAnchor.constraint(equalToConstant: 80.dp),
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 24.dp),
            name.topAnchor.constraint(equalTo: row.topAnchor),
            name.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
            text.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            text.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10.dp),
            text.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            text.bottomAnchor.constraint(equalTo: row.bottomAnchor),
        ])
        return row
    }

    @objc private func tapCommentAvatar(_ gr: UITapGestureRecognizer) {
        guard let avatar = gr.view, comments.indices.contains(avatar.tag),
              let user = DemoContent.user(id: comments[avatar.tag].userId) else { return }
        navigationController?.pushViewController(UserProfileViewController(user: user), animated: true)
    }

    @objc private func tapSend() {
        let t = (inputField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        inputField.text = ""
        inputField.resignFirstResponder()
        let me = AppSession.shared.current?.displayName ?? "Me"
        let avatar = AppSession.shared.current?.avatarAsset ?? "content_dog1"
        DemoContent.appendComment(
            DemoContent.PostComment(userId: DemoContent.currentUserId, avatar: avatar, name: me, text: t),
            for: item.id)
        syncCommentsFromStore()
    }

    @objc private func keyboardChange(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = max(0, view.bounds.height - frame.origin.y)
        inputBottom.constant = overlap > 0 ? -(overlap + 10.dp - view.safeAreaInsets.bottom) : -10.dp
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}
