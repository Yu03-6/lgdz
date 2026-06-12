import UIKit

/// Screen 1 — Choose sign-in method.
/// Layout base 780×1688. Background = `login_bg` cutout (Welcome + hero baked
/// in). Buttons drawn in code at design coordinates.
final class LoginSelectionViewController: UIViewController {

    private let bg = UIImageView()
    private let appleButton = PillButton(style: .apple, title: "Continue with Apple")
    private let signInButton = PillButton(style: .secondary, title: "Sign in")
    private let createButton = PillButton(style: .secondary, title: "Create account")
    private let footer = UITextView()
    private let appleCoordinator = AppleSignInCoordinator()

    private enum FooterLink {
        static let userAgreement = URL(string: "vivi://user-agreement")!
        static let privacyAgreement = URL(string: "vivi://privacy-agreement")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupBackground()
        setupFooter()
        setupButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func setupBackground() {
        bg.image = UIImage(named: "login_bg")
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupButtons() {
        let margin = 60.dp
        let height = 112.dp
        let spacing = 40.dp

        [appleButton, signInButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        appleButton.addTarget(self, action: #selector(tapApple), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)

        // Apple button top at design y=952; compress upward on shorter viewports
        // (e.g. iPad iPhone-compatibility window) so buttons stay above the footer.
        let designAppleTop = appleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 952.dp)
        designAppleTop.priority = UILayoutPriority(750)

        NSLayoutConstraint.activate([
            designAppleTop,
            appleButton.topAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.dp),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            appleButton.heightAnchor.constraint(equalToConstant: height),

            signInButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: spacing),
            signInButton.leadingAnchor.constraint(equalTo: appleButton.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: appleButton.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: height),

            createButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: spacing),
            createButton.leadingAnchor.constraint(equalTo: appleButton.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: appleButton.trailingAnchor),
            createButton.heightAnchor.constraint(equalToConstant: height),
            createButton.bottomAnchor.constraint(
                lessThanOrEqualTo: footer.topAnchor, constant: -spacing),
        ])
    }

    private func setupFooter() {
        footer.backgroundColor = .clear
        footer.isEditable = false
        footer.isScrollEnabled = false
        footer.isSelectable = true
        footer.delegate = self
        footer.textContainerInset = .zero
        footer.textContainer.lineFragmentPadding = 0
        footer.linkTextAttributes = [
            .foregroundColor: DesignTokens.Color.textPrimary,
            .font: DesignTokens.Font.semibold(24),
        ]

        var normal: [NSAttributedString.Key: Any] = [
            .font: DesignTokens.Font.medium(24),
            .foregroundColor: DesignTokens.Color.textMuted,
        ]
        var userLink: [NSAttributedString.Key: Any] = [
            .font: DesignTokens.Font.semibold(24),
            .foregroundColor: DesignTokens.Color.textPrimary,
            .link: FooterLink.userAgreement,
        ]
        var privacyLink: [NSAttributedString.Key: Any] = [
            .font: DesignTokens.Font.semibold(24),
            .foregroundColor: DesignTokens.Color.textPrimary,
            .link: FooterLink.privacyAgreement,
        ]
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        para.lineSpacing = 4.dp
        normal[.paragraphStyle] = para
        userLink[.paragraphStyle] = para
        privacyLink[.paragraphStyle] = para

        let s = NSMutableAttributedString(string: "By signing up, you agree to the ", attributes: normal)
        s.append(NSAttributedString(string: "User Agreement", attributes: userLink))
        s.append(NSAttributedString(string: " & ", attributes: normal))
        s.append(NSAttributedString(string: "Privacy Agreement", attributes: privacyLink))
        footer.attributedText = s
        footer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footer)
        NSLayoutConstraint.activate([
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70.dp),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70.dp),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24.dp),
            footer.heightAnchor.constraint(greaterThanOrEqualToConstant: 48.dp),
        ])
    }

    private func openLegalPage(title: String, url: URL) {
        navigationController?.pushViewController(
            LegalWebViewController(title: title, url: url),
            animated: true)
    }

    @objc private func tapApple() {
        appleCoordinator.start(from: self) { [weak self] outcome in
            guard let self else { return }
            switch outcome {
            case .success(let acct):
                AppSession.shared.activate(acct)
                AppRouter.shared.enterMainApp()
            case .cancelled:
                break
            case .failed(let message):
                Toast.show(message, in: self.view)
            }
        }
    }

    @objc private func tapSignIn() {
        navigationController?.pushViewController(EmailLoginViewController(), animated: true)
    }

    @objc private func tapCreate() {
        navigationController?.pushViewController(RegisterStep1ViewController(), animated: true)
    }
}

extension LoginSelectionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        switch URL {
        case FooterLink.userAgreement:
            openLegalPage(title: "User Agreement", url: LegalURLs.userAgreement)
        case FooterLink.privacyAgreement:
            openLegalPage(title: "Privacy Agreement", url: LegalURLs.privacyAgreement)
        default:
            break
        }
        return false
    }
}
