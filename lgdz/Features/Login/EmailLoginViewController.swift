import UIKit

/// Screen 2 — Email + password sign in.
/// Demo account: lgdz@qq.com / lgdz12345 (seeded in AppSession).
final class EmailLoginViewController: UIViewController {

    private let bg = UIImageView()
    private let formContent = UIView()
    private let emailField = InputField(title: "Email", placeholder: "Your email address")
    private let passwordField = InputField(title: "Password", placeholder: "Your password", secure: true)
    private let signInButton = PillButton(style: .primary, title: "Sign in")
    private let footer = UILabel()
    private var keyboardAvoidance: KeyboardShiftAvoidance?
    private var footerKeyboardAvoidance: KeyboardBottomBarAvoidance?

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupBackground()
        setupFooter()
        setupFields()
        emailField.textField.keyboardType = .emailAddress
        KeyboardDismiss.installTapToDismiss(on: view, target: self, action: #selector(dismissKeyboard))
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

    private func setupFields() {
        let margin = 60.dp
        let fieldSpacing = 55.dp
        let signInGap = 109.dp
        let minGap: CGFloat = 24.dp

        let formArea = LoginPinnedFooterLayout.installFixedForm(
            in: view,
            below: view.safeAreaLayoutGuide.topAnchor,
            footerView: footer,
            gapAboveFooter: 16.dp)

        formContent.translatesAutoresizingMaskIntoConstraints = false
        formArea.addSubview(formContent)

        [emailField, passwordField, signInButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            formContent.addSubview($0)
        }
        signInButton.addTarget(self, action: #selector(tapSignIn), for: .touchUpInside)

        let spacer = LoginPinnedFooterLayout.makeVerticalSpacer()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        formContent.addSubview(spacer)

        let designFieldGap = passwordField.topAnchor.constraint(
            equalTo: emailField.bottomAnchor, constant: fieldSpacing)
        designFieldGap.priority = UILayoutPriority(750)

        let designSignInGap = signInButton.topAnchor.constraint(
            equalTo: passwordField.bottomAnchor, constant: signInGap)
        designSignInGap.priority = UILayoutPriority(750)

        NSLayoutConstraint.activate([
            formContent.topAnchor.constraint(equalTo: formArea.topAnchor),
            formContent.leadingAnchor.constraint(equalTo: formArea.leadingAnchor),
            formContent.trailingAnchor.constraint(equalTo: formArea.trailingAnchor),
            formContent.bottomAnchor.constraint(equalTo: formArea.bottomAnchor),

            signInButton.leadingAnchor.constraint(equalTo: formContent.leadingAnchor, constant: margin),
            signInButton.trailingAnchor.constraint(equalTo: formContent.trailingAnchor, constant: -margin),
            signInButton.heightAnchor.constraint(equalToConstant: 120.dp),
            signInButton.bottomAnchor.constraint(equalTo: formContent.bottomAnchor, constant: -8.dp),

            designSignInGap,
            signInButton.topAnchor.constraint(
                greaterThanOrEqualTo: passwordField.bottomAnchor, constant: minGap),

            passwordField.leadingAnchor.constraint(equalTo: signInButton.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor),

            designFieldGap,
            passwordField.topAnchor.constraint(
                greaterThanOrEqualTo: emailField.bottomAnchor, constant: minGap),

            emailField.leadingAnchor.constraint(equalTo: signInButton.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor),
            emailField.topAnchor.constraint(equalTo: spacer.bottomAnchor),

            spacer.topAnchor.constraint(equalTo: formContent.topAnchor),
            spacer.leadingAnchor.constraint(equalTo: formContent.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: formContent.trailingAnchor),
            spacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
        ])

        keyboardAvoidance = KeyboardShiftAvoidance()
        keyboardAvoidance?.attach(
            hostView: view,
            contentView: formContent,
            actionButtons: [signInButton])
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
        footer.numberOfLines = 0
        footer.isUserInteractionEnabled = true
        footer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCreate)))
        footer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footer)
        let footerBottom = footer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40.dp)
        NSLayoutConstraint.activate([
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.dp),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.dp),
            footerBottom,
        ])
        footerKeyboardAvoidance = KeyboardBottomBarAvoidance()
        footerKeyboardAvoidance?.start(
            hostView: view, bottomConstraint: footerBottom, restingConstant: -40.dp)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
