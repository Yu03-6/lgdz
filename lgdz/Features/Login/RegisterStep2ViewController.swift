import UIKit

/// Screen 5 — Complete the data (注册2). Optional profile; fields can be left
/// blank (可跳过). Tapping "Create account" registers locally and enters the app.
final class RegisterStep2ViewController: UIViewController {

    private let email: String
    private let password: String

    private let scroll = UIScrollView()
    private let content = UIView()
    private var keyboardAvoidance: KeyboardFormAvoidance?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let avatarRing = AvatarPickerView()
    private let avatarTitle = UILabel()
    private let avatarHint = UILabel()
    private let nickField = InputField(title: "Nick name", placeholder: "Your nickname")
    private let descLabel = UILabel()
    private let descBox = UIView()
    private let descView = UITextView()
    private let descPlaceholder = UILabel()
    private let createButton = PillButton(style: .primary, title: "Create account")

    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func layout() {
        let margin = 60.dp
        let header = NavHeader(title: nil) { [weak self] in
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

        titleLabel.text = "Complete the data"
        titleLabel.font = DesignTokens.Font.bold(50)
        titleLabel.textColor = DesignTokens.Color.textPrimary

        subtitleLabel.text = "Let everyone get to\nknow you and your dog better~"
        subtitleLabel.numberOfLines = 2
        subtitleLabel.font = DesignTokens.Font.semibold(30)
        subtitleLabel.textColor = DesignTokens.Color.textPrimary

        avatarTitle.text = "Avatar"
        avatarTitle.font = DesignTokens.Font.bold(40)
        avatarTitle.textColor = DesignTokens.Color.textPrimary

        avatarHint.text = "Real photo gets more attention."
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

        createButton.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)

        [titleLabel, subtitleLabel, avatarRing, avatarTitle, avatarHint,
         nickField, descLabel, descBox, createButton].forEach {
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

            titleLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 30.dp),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.dp),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            avatarRing.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50.dp),
            avatarRing.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            avatarRing.widthAnchor.constraint(equalToConstant: 150.dp),
            avatarRing.heightAnchor.constraint(equalToConstant: 150.dp),

            avatarTitle.leadingAnchor.constraint(equalTo: avatarRing.trailingAnchor, constant: 36.dp),
            avatarTitle.topAnchor.constraint(equalTo: avatarRing.topAnchor, constant: 36.dp),
            avatarHint.leadingAnchor.constraint(equalTo: avatarTitle.leadingAnchor),
            avatarHint.topAnchor.constraint(equalTo: avatarTitle.bottomAnchor, constant: 14.dp),

            nickField.topAnchor.constraint(equalTo: avatarRing.bottomAnchor, constant: 50.dp),
            nickField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nickField.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),

            descLabel.topAnchor.constraint(equalTo: nickField.bottomAnchor, constant: 44.dp),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            descBox.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 28.dp),
            descBox.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descBox.trailingAnchor.constraint(equalTo: nickField.trailingAnchor),
            descBox.heightAnchor.constraint(equalToConstant: 300.dp),

            descView.topAnchor.constraint(equalTo: descBox.topAnchor),
            descView.leadingAnchor.constraint(equalTo: descBox.leadingAnchor),
            descView.trailingAnchor.constraint(equalTo: descBox.trailingAnchor),
            descView.bottomAnchor.constraint(equalTo: descBox.bottomAnchor),
            descPlaceholder.topAnchor.constraint(equalTo: descBox.topAnchor, constant: 26.dp),
            descPlaceholder.leadingAnchor.constraint(equalTo: descBox.leadingAnchor, constant: 36.dp),

            createButton.topAnchor.constraint(equalTo: descBox.bottomAnchor, constant: 60.dp),
            createButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: nickField.trailingAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 120.dp),
            createButton.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -100.dp),
        ])

        keyboardAvoidance = KeyboardFormAvoidance()
        keyboardAvoidance?.attach(scrollView: scroll, hostView: view, baseBottomInset: 32.dp)
    }

    @objc private func tapCreate() {
        view.endEditing(true)
        let nick = nickField.text.trimmingCharacters(in: .whitespaces)
        let displayName = nick.isEmpty ? String(email.prefix(while: { $0 != "@" })) : nick
        let bio = descView.text.trimmingCharacters(in: .whitespaces)
        do {
            let acct = try AppSession.shared.register(email: email, password: password,
                                                      displayName: displayName,
                                                      bio: bio.isEmpty ? nil : bio)
            AppSession.shared.activate(acct)
            AppRouter.shared.enterMainApp()
        } catch AppSession.AuthError.emailTaken {
            Toast.show("Email already registered", in: view)
        } catch {
            Toast.show("Registration failed", in: view)
        }
    }
}

extension RegisterStep2ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}

/// Dashed-ring avatar placeholder with a green camera glyph.
final class AvatarPickerView: UIView {
    private let ring = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = DesignTokens.Color.accent.cgColor
        ring.lineWidth = 3
        ring.lineDashPattern = [6, 5]
        layer.addSublayer(ring)

        let plate = UIView()
        plate.backgroundColor = .white
        plate.layer.cornerRadius = 22.dp
        plate.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plate)
        let cam = UIImageView(image: UIImage(systemName: "camera.fill"))
        cam.tintColor = DesignTokens.Color.accent
        cam.contentMode = .scaleAspectFit
        cam.translatesAutoresizingMaskIntoConstraints = false
        plate.addSubview(cam)
        NSLayoutConstraint.activate([
            plate.centerXAnchor.constraint(equalTo: centerXAnchor),
            plate.centerYAnchor.constraint(equalTo: centerYAnchor),
            plate.widthAnchor.constraint(equalToConstant: 70.dp),
            plate.heightAnchor.constraint(equalToConstant: 70.dp),
            cam.centerXAnchor.constraint(equalTo: plate.centerXAnchor),
            cam.centerYAnchor.constraint(equalTo: plate.centerYAnchor),
            cam.widthAnchor.constraint(equalToConstant: 40.dp),
            cam.heightAnchor.constraint(equalToConstant: 40.dp),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        ring.frame = bounds
        ring.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 1.5, dy: 1.5)).cgPath
    }
}
