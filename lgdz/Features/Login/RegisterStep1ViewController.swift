import UIKit

/// Screen 3/4 — Create Account (注册1).
/// The design combines email + password + confirm into one screen (the spec's
/// "Step1 email / Step2 password" split is merged here per the original).
/// Email format is validated; passwords must match before continuing.
final class RegisterStep1ViewController: UIViewController {

    private let formContent = UIView()
    private let emailField = InputField(title: "Email", placeholder: "Your email address")
    private let passwordField = InputField(title: "Password", placeholder: "Your password", secure: true)
    private let confirmField = InputField(title: "Password again", placeholder: "Your password", secure: true)
    private let nextButton = PillButton(style: .primary, title: "Next")
    private let footer = UILabel()
    private var keyboardAvoidance: KeyboardShiftAvoidance?
    private var footerKeyboardAvoidance: KeyboardBottomBarAvoidance?

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()

        let header = NavHeader(title: "Create Account") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        setupFooter()

        let formArea = LoginPinnedFooterLayout.installFixedForm(
            in: view,
            below: header.bottomAnchor,
            footerView: footer,
            gapAboveFooter: 16.dp)

        formContent.translatesAutoresizingMaskIntoConstraints = false
        formArea.addSubview(formContent)

        emailField.textField.keyboardType = .emailAddress
        [emailField, passwordField, confirmField, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            formContent.addSubview($0)
        }
        nextButton.addTarget(self, action: #selector(tapNext), for: .touchUpInside)

        let spacer = LoginPinnedFooterLayout.makeVerticalSpacer()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        formContent.addSubview(spacer)

        let margin = 60.dp
        let fieldGap = 50.dp
        let minGap: CGFloat = 20.dp
        let nextGap = 80.dp

        let designConfirmGap = confirmField.topAnchor.constraint(
            equalTo: passwordField.bottomAnchor, constant: fieldGap)
        designConfirmGap.priority = UILayoutPriority(750)

        let designPasswordGap = passwordField.topAnchor.constraint(
            equalTo: emailField.bottomAnchor, constant: fieldGap)
        designPasswordGap.priority = UILayoutPriority(750)

        let designNextGap = nextButton.topAnchor.constraint(
            equalTo: confirmField.bottomAnchor, constant: nextGap)
        designNextGap.priority = UILayoutPriority(750)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            formContent.topAnchor.constraint(equalTo: formArea.topAnchor),
            formContent.leadingAnchor.constraint(equalTo: formArea.leadingAnchor),
            formContent.trailingAnchor.constraint(equalTo: formArea.trailingAnchor),
            formContent.bottomAnchor.constraint(equalTo: formArea.bottomAnchor),

            nextButton.leadingAnchor.constraint(equalTo: formContent.leadingAnchor, constant: margin),
            nextButton.trailingAnchor.constraint(equalTo: formContent.trailingAnchor, constant: -margin),
            nextButton.heightAnchor.constraint(equalToConstant: 120.dp),
            nextButton.bottomAnchor.constraint(equalTo: formContent.bottomAnchor, constant: -8.dp),

            designNextGap,
            nextButton.topAnchor.constraint(
                greaterThanOrEqualTo: confirmField.bottomAnchor, constant: minGap),

            confirmField.leadingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            confirmField.trailingAnchor.constraint(equalTo: nextButton.trailingAnchor),

            designConfirmGap,
            confirmField.topAnchor.constraint(
                greaterThanOrEqualTo: passwordField.bottomAnchor, constant: minGap),

            passwordField.leadingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nextButton.trailingAnchor),

            designPasswordGap,
            passwordField.topAnchor.constraint(
                greaterThanOrEqualTo: emailField.bottomAnchor, constant: minGap),

            emailField.leadingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nextButton.trailingAnchor),
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
            actionButtons: [nextButton])
        KeyboardDismiss.installTapToDismiss(on: view, target: self, action: #selector(dismissKeyboard))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
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
        let s = NSMutableAttributedString(string: "Already have an account? ", attributes: normal)
        s.append(NSAttributedString(string: "Sign in", attributes: link))
        footer.attributedText = s
        footer.textAlignment = .center
        footer.numberOfLines = 0
        footer.isUserInteractionEnabled = true
        footer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSignIn)))
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

    private func isValidEmail(_ s: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func tapNext() {
        view.endEditing(true)
        let email = emailField.text.trimmingCharacters(in: .whitespaces)
        guard isValidEmail(email) else { Toast.show("Invalid email format", in: view); return }
        guard passwordField.text.count >= 6 else {
            Toast.show("Password needs at least 6 characters", in: view); return
        }
        guard passwordField.text == confirmField.text else {
            Toast.show("Passwords do not match", in: view); return
        }
        let vc = RegisterStep2ViewController(email: email, password: passwordField.text)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func tapSignIn() {
        if let stack = navigationController?.viewControllers,
           let login = stack.first(where: { $0 is EmailLoginViewController }) {
            navigationController?.popToViewController(login, animated: true)
        } else {
            navigationController?.pushViewController(EmailLoginViewController(), animated: true)
        }
    }
}
