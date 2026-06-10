import UIKit

/// Screen 26 — Settings. Rounded option rows + Log out (returns to login,
/// clearing the in-process session per §6 冷启动必回登录页).
final class SettingsViewController: UIViewController {

    private let options = ["Blacklist", "Privacy agreement", "User agreement",
                           "Community Guidelines", "Delete of account", "Contact Us"]

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()

        let header = NavHeader(title: "Settings") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 28.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        for (i, o) in options.enumerated() {
            stack.addArrangedSubview(makeRow(o, tag: i))
        }

        let logout = PillButton(style: .primary, title: "Log out")
        logout.backgroundColor = DesignTokens.Color.textPrimary
        logout.setTitleColor(.white, for: .normal)
        logout.designCornerRadius = 36
        logout.addTarget(self, action: #selector(tapLogout), for: .touchUpInside)
        logout.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logout)

        let margin = 32.dp
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 40.dp),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            logout.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            logout.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            logout.heightAnchor.constraint(equalToConstant: 120.dp),
            logout.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40.dp),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func makeRow(_ title: String, tag: Int) -> UIView {
        let row = UIControl()
        row.tag = tag
        row.backgroundColor = DesignTokens.Color.secondaryFill
        row.layer.cornerRadius = 32.dp
        row.heightAnchor.constraint(equalToConstant: 150.dp).isActive = true
        let label = UILabel()
        label.text = title
        label.font = DesignTokens.Font.bold(34)
        label.textColor = DesignTokens.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = DesignTokens.Color.textPrimary
        chevron.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(chevron)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 40.dp),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -40.dp),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        row.addAction(UIAction { [weak self] _ in self?.tapRow(tag) }, for: .touchUpInside)
        return row
    }

    private func tapRow(_ tag: Int) {
        switch tag {
        case 0:
            navigationController?.pushViewController(BlacklistViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(
                LegalWebViewController(title: "Privacy Agreement", url: LegalURLs.privacyAgreement),
                animated: true)
        case 2:
            navigationController?.pushViewController(
                LegalWebViewController(title: "User Agreement", url: LegalURLs.userAgreement),
                animated: true)
        case 3:
            navigationController?.pushViewController(
                LegalTextViewController(title: "Community Guidelines", body: LegalCopy.communityGuidelines),
                animated: true)
        case 4:
            tapDeleteAccount()
        case 5:
            navigationController?.pushViewController(ContactUsViewController(), animated: true)
        default:
            Toast.show("\(options[tag])", in: view)
        }
    }

    private func tapDeleteAccount() {
        if AppSession.shared.isTestAccount {
            ReminderPopupController(
                title: "Cannot Delete",
                bodyParts: [("This account is a test account and cannot be deleted.", false)],
                buttonTitle: "OK"
            ).present(over: self)
            return
        }

        ReminderPopupController(
            title: "Delete Account?",
            bodyParts: [(
                "This will permanently remove your profile, posts, wallet balance, and chat history from this device. This action cannot be undone.",
                false
            )],
            buttonTitle: "Delete",
            secondaryTitle: "Cancel",
            onConfirm: { [weak self] in
                do {
                    try AppSession.shared.deleteCurrentAccount()
                    AppRouter.shared.logout()
                } catch {
                    Toast.show("Unable to delete account.", in: self?.view ?? UIView())
                }
            }
        ).present(over: self)
    }

    @objc private func tapLogout() {
        AppRouter.shared.logout()
    }
}
