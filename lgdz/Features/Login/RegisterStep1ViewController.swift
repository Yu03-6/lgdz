import UIKit

/// Screen 3/4 — Create Account (注册1).
/// The design combines email + password + confirm into one screen (the spec's
/// "Step1 email / Step2 password" split is merged here per the original).
/// Email format is validated; passwords must match before continuing.
final class RegisterStep1ViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIView()
    private let emailField = InputField(title: "Email", placeholder: "Your email address")
    private let passwordField = InputField(title: "Password", placeholder: "Your password", secure: true)
    private let confirmField = InputField(title: "Password again", placeholder: "Your password", secure: true)
    private let nextButton = PillButton(style: .primary, title: "Next")
    private let footer = UILabel()
    private var keyboardAvoidance: KeyboardFormAvoidance?

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()

        let header = NavHeader(title: "Create Account") { [weak self] in
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

        emailField.textField.keyboardType = .emailAddress
        [emailField, passwordField, confirmField, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }
        nextButton.addTarget(self, action: #selector(tapNext), for: .touchUpInside)
        setupFooter()

        let margin = 60.dp
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

            emailField.topAnchor.constraint(equalTo: content.topAnchor, constant: 90.dp),
            emailField.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: margin),
            emailField.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -margin),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 50.dp),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            confirmField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 50.dp),
            confirmField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            confirmField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            nextButton.topAnchor.constraint(greaterThanOrEqualTo: confirmField.bottomAnchor, constant: 80.dp),
            nextButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 120.dp),

            footer.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            footer.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 36.dp),
            footer.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -40.dp),
        ])

        keyboardAvoidance = KeyboardFormAvoidance()
        keyboardAvoidance?.attach(scrollView: scroll, hostView: view, baseBottomInset: 32.dp)
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
        footer.isUserInteractionEnabled = true
        footer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSignIn)))
        footer.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(footer)
    }

    private func isValidEmail(_ s: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return s.range(of: pattern, options: .regularExpression) != nil
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
