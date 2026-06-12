import UIKit

/// Screen 2 — Email + password sign in.
/// Demo account: lgdz@qq.com / lgdz12345 (seeded in AppSession).
final class EmailLoginViewController: UIViewController {

    private let bg = UIImageView()
    private let scroll = UIScrollView()
    private let content = UIView()
    private let emailField = InputField(title: "Email", placeholder: "Your email address")
    private let passwordField = InputField(title: "Password", placeholder: "Your password", secure: true)
    private let signInButton = PillButton(style: .primary, title: "Sign in")
    private let footer = UILabel()
    private var keyboardAvoidance: KeyboardFormAvoidance?

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupBackground()
        setupScroll()
        setupFields()
        setupFooter()
        emailField.textField.keyboardType = .emailAddress
        keyboardAvoidance = KeyboardFormAvoidance()
        keyboardAvoidance?.attach(scrollView: scroll, hostView: view, baseBottomInset: 32.dp)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Disable scrolling when the form fits — keeps Sign in visible without swiping.
        let fits = scroll.contentSize.height <= scroll.bounds.height + 1
        scroll.isScrollEnabled = !fits
        if fits {
            scroll.contentOffset = .zero
        }
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

    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor),
        ])
    }

    private func setupFields() {
        let margin = 60.dp
        let fieldSpacing = 55.dp
        // Design gap from password bottom (y≈1249) to sign-in top (y=1358).
        let signInGap = 109.dp

        [emailField, passwordField, signInButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }
        signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)

        // Email group top ≈ design y 830; allow upward shift on shorter viewports (iPad).
        let designEmailTop = emailField.topAnchor.constraint(equalTo: content.topAnchor, constant: 830.dp)
        designEmailTop.priority = UILayoutPriority(750)

        let designSignInGap = signInButton.topAnchor.constraint(
            equalTo: passwordField.bottomAnchor, constant: signInGap)
        designSignInGap.priority = UILayoutPriority(750)

        NSLayoutConstraint.activate([
            designEmailTop,
            emailField.topAnchor.constraint(greaterThanOrEqualTo: content.topAnchor, constant: 12.dp),
            emailField.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            emailField.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: fieldSpacing),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            designSignInGap,
            signInButton.topAnchor.constraint(
                greaterThanOrEqualTo: passwordField.bottomAnchor, constant: 32.dp),
            signInButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 120.dp),
        ])
    }

    private func setupFooter() {
        let normal: [NSAttributedString.Key: Any] = [
            .font: DesignTokens.Font.medium(26),
            .foregroundColor: DesignTokens.Color.textMuted,
        ]
        let link: [NSAttributedString.Key: Any] = [
            .font: DesignTokens.Font.bold(26),
            .foregroundColor: DesignTokens.Color.textPrimary,
        ]
        let s = NSMutableAttributedString(string: "Don't have an account yet ? ", attributes: normal)
        s.append(NSAttributedString(string: "Create Account", attributes: link))
        footer.attributedText = s
        footer.textAlignment = .center
        footer.isUserInteractionEnabled = true
        footer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCreate)))
        footer.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(footer)
        NSLayoutConstraint.activate([
            footer.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            footer.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 36.dp),
            footer.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -40.dp),
        ])
    }

    @objc private func tapSignIn() {
        view.endEditing(true)
        let email = emailField.text.trimmingCharacters(in: .whitespaces)
        let pwd = passwordField.text
        guard !email.isEmpty, !pwd.isEmpty else {
            Toast.show("Please enter email and password", in: view); return
        }
        do {
            let acct = try AppSession.shared.signIn(email: email, password: pwd)
            AppSession.shared.activate(acct)
            AppRouter.shared.enterMainApp()
        } catch AppSession.AuthError.notFound {
            Toast.show("Account not found", in: view)
        } catch AppSession.AuthError.wrongPassword {
            Toast.show("Incorrect password", in: view)
        } catch {
            Toast.show("Sign in failed", in: view)
        }
    }

    @objc private func tapCreate() {
        navigationController?.pushViewController(RegisterStep1ViewController(), animated: true)
    }
}
