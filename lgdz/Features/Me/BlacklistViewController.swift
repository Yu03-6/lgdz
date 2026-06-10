import UIKit

/// Screen 27 — Blacklist. Empty by default (§3: 新用户为空); unblock removes rows.
final class BlacklistViewController: UIViewController {

    private let scroll = UIScrollView()
    private let list = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        let header = NavHeader(title: "Blacklist") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)
        list.axis = .vertical
        list.spacing = 28.dp
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),
            scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 32.dp),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -32.dp),
            list.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -64.dp),
        ])
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        reload()
    }

    private func reload() {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let blocked = AppSession.shared.blockedNames
        if blocked.isEmpty {
            let empty = EmptyStateView(
                title: "No blocked users",
                subtitle: "People you block will appear here.")
            list.addArrangedSubview(empty)
            return
        }
        for name in blocked { list.addArrangedSubview(makeRow(name)) }
    }

    private func makeRow(_ name: String) -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        card.heightAnchor.constraint(equalToConstant: 150.dp).isActive = true

        let avatarAsset = DemoContent.user(named: name)?.avatar ?? "content_dog2"
        let avatar = CircleImageView(asset: avatarAsset)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatar)

        let label = UILabel()
        label.text = name
        label.font = DesignTokens.Font.bold(36)
        label.textColor = DesignTokens.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        let unblock = UIButton(type: .custom)
        unblock.setImage(
            UIImage(named: "blacklist_remove")?.withRenderingMode(.alwaysOriginal),
            for: .normal)
        unblock.imageView?.contentMode = .scaleAspectFit
        unblock.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(unblock)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 96.dp),
            avatar.heightAnchor.constraint(equalToConstant: 96.dp),
            label.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 28.dp),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            unblock.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28.dp),
            unblock.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            unblock.widthAnchor.constraint(equalToConstant: 90.dp),
            unblock.heightAnchor.constraint(equalToConstant: 80.dp),
        ])
        unblock.addAction(UIAction { [weak self] _ in
            DemoContent.unblockUser(named: name)
            self?.reload()
        }, for: .touchUpInside)
        return card
    }
}
