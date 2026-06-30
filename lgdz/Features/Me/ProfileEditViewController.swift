import UIKit

/// Edit current account nickname, bio, and avatar (local demo persistence).
final class ProfileEditViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIView()
    private var keyboardAvoidance: KeyboardFormAvoidance?

    private let avatarView = CircleImageView(asset: nil)
    private let nickField = InputField(title: "Nick name", placeholder: "Your nickname")
    private let descLabel = UILabel()
    private let descBox = UIView()
    private let descView = UITextView()
    private let descPlaceholder = UILabel()
    private let saveButton = PillButton(style: .primary, title: "Save")

    private let avatarOptions = [
        "content_dog1", "content_dog2", "content_dog3",
        "avatar_user", "avatar_a", "avatar_b", "avatar_c",
    ]
    private var selectedAvatarIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        layout()
        loadCurrentProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func layout() {
        let margin = 60.dp
        let header = NavHeader(title: "Edit Profile") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        avatarView.layer.borderWidth = 4
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(cycleAvatar)))

        let avatarTitle = UILabel()
        avatarTitle.text = "Avatar"
        avatarTitle.font = DesignTokens.Font.bold(40)
        avatarTitle.textColor = DesignTokens.Color.textPrimary

        let avatarHint = UILabel()
        avatarHint.text = "Tap to change your photo."
        avatarHint.font = DesignTokens.Font.regular(24)
        avatarHint.textColor = DesignTokens.Color.textMuted

        descLabel.text = "Personal description"
        descLabel.font = DesignTokens.Font.bold(30)
        descLabel.textColor = DesignTokens.Color.textPrimary

        descBox.backgroundColor = DesignTokens.Color.fieldFill
        descBox.layer.cornerRadius = 28.dp
        descView.backgroundColor = .clear
        descView.font = DesignTokens.Font.regular(30)
        descView.textColor = DesignTokens.Color.textPrimary
        descView.textContainerInset = UIEdgeInsets(top: 24.dp, left: 32.dp, bottom: 24.dp, right: 32.dp)
        descView.delegate = self
        descPlaceholder.text = "Introduce yourself in one\nsentence..."
        descPlaceholder.numberOfLines = 2
        descPlaceholder.font = DesignTokens.Font.regular(30)
        descPlaceholder.textColor = DesignTokens.Color.textMuted

        saveButton.addTarget(self, action: #selector(tapSave), for: .touchUpInside)

        [avatarView, avatarTitle, avatarHint, nickField, descLabel, descBox, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }
        descBox.addSubview(descView)
        descBox.addSubview(descPlaceholder)
        descView.translatesAutoresizingMaskIntoConstraints = false
        descPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            scroll.topAnchor.constraint(equalTo: header.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor),

            avatarView.topAnchor.constraint(equalTo: content.topAnchor, constant: 40.dp),
            avatarView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            avatarView.widthAnchor.constraint(equalToConstant: 150.dp),
            avatarView.heightAnchor.constraint(equalToConstant: 150.dp),

            avatarTitle.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 36.dp),
            avatarTitle.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 36.dp),
            avatarHint.leadingAnchor.constraint(equalTo: avatarTitle.leadingAnchor),
            avatarHint.topAnchor.constraint(equalTo: avatarTitle.bottomAnchor, constant: 14.dp),

            nickField.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 50.dp),
            nickField.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            nickField.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),

            descLabel.topAnchor.constraint(equalTo: nickField.bottomAnchor, constant: 44.dp),
            descLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),

            descBox.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 28.dp),
            descBox.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            descBox.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            descBox.heightAnchor.constraint(equalToConstant: 300.dp),

            descView.topAnchor.constraint(equalTo: descBox.topAnchor),
            descView.leadingAnchor.constraint(equalTo: descBox.leadingAnchor),
            descView.trailingAnchor.constraint(equalTo: descBox.trailingAnchor),
            descView.bottomAnchor.constraint(equalTo: descBox.bottomAnchor),
            descPlaceholder.topAnchor.constraint(equalTo: descBox.topAnchor, constant: 26.dp),
            descPlaceholder.leadingAnchor.constraint(equalTo: descBox.leadingAnchor, constant: 36.dp),

            saveButton.topAnchor.constraint(equalTo: descBox.bottomAnchor, constant: 60.dp),
            saveButton.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            saveButton.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),
            saveButton.heightAnchor.constraint(equalToConstant: 120.dp),
            saveButton.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -100.dp),
        ])

        keyboardAvoidance = KeyboardFormAvoidance()
        keyboardAvoidance?.attach(
            scrollView: scroll, hostView: view, baseBottomInset: 48.dp,
            actionButtons: [saveButton])
    }

    private func loadCurrentProfile() {
        guard let acct = AppSession.shared.current else { return }
        nickField.textField.text = acct.displayName
        descView.text = acct.bio ?? ""
        descPlaceholder.isHidden = !(acct.bio ?? "").isEmpty
        if let asset = acct.avatarAsset,
           let index = avatarOptions.firstIndex(of: asset) {
            selectedAvatarIndex = index
        }
        applyAvatar()
    }

    private func applyAvatar() {
        let asset = avatarOptions[selectedAvatarIndex]
        avatarView.applyAccountAvatar(
            asset: asset,
            displayName: nickField.text.trimmingCharacters(in: .whitespaces))
    }

    @objc private func cycleAvatar() {
        selectedAvatarIndex = (selectedAvatarIndex + 1) % avatarOptions.count
        applyAvatar()
    }

    @objc private func tapSave() {
        view.endEditing(true)
        guard var acct = AppSession.shared.current else { return }
        let nick = nickField.text.trimmingCharacters(in: .whitespaces)
        guard !nick.isEmpty else {
            Toast.show("Please enter a nickname", in: view)
            return
        }
        let bio = descView.text.trimmingCharacters(in: .whitespaces)
        acct.displayName = nick
        acct.bio = bio.isEmpty ? nil : bio
        acct.avatarAsset = avatarOptions[selectedAvatarIndex]
        AppSession.shared.updateCurrentAccount(acct)
        NotificationCenter.default.post(name: .accountDidActivate, object: nil)
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}
