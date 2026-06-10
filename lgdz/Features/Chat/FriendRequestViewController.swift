import UIKit

/// 好友申请 — Friend Request list. Reached from the Chat tab top-right icon.
/// Accept / reject remove the row (local demo).
final class FriendRequestViewController: UIViewController {

    private let scroll = UIScrollView()
    private let list = UIStackView()
    private var requests: [DemoContent.SocialUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        requests = DemoContent.friendRequests

        let header = NavHeader(title: "Friend Request") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset.bottom = 40.dp
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
    }

    private func reload() {
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if requests.isEmpty {
            let empty = EmptyStateView(title: "No friend requests", subtitle: "New requests will show up here.")
            list.addArrangedSubview(empty)
            return
        }
        for u in requests { list.addArrangedSubview(makeCard(u)) }
    }

    private func makeCard(_ u: DemoContent.SocialUser) -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        card.heightAnchor.constraint(equalToConstant: 200.dp).isActive = true

        let avatar = CircleImageView(asset: u.avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatar)
        let name = UILabel()
        name.text = u.name
        name.font = DesignTokens.Font.bold(38)
        name.textColor = DesignTokens.Color.textPrimary
        name.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(name)

        let reject = UIButton(type: .system)
        reject.setImage(UIImage(named: "fr_reject")?.withRenderingMode(.alwaysOriginal), for: .normal)
        reject.imageView?.contentMode = .scaleAspectFit
        reject.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(reject)
        let accept = UIButton(type: .system)
        accept.setImage(UIImage(named: "fr_accept")?.withRenderingMode(.alwaysOriginal), for: .normal)
        accept.imageView?.contentMode = .scaleAspectFit
        accept.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(accept)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 100.dp),
            avatar.heightAnchor.constraint(equalToConstant: 100.dp),
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 28.dp),
            name.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            name.trailingAnchor.constraint(lessThanOrEqualTo: reject.leadingAnchor, constant: -16.dp),
            accept.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28.dp),
            accept.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            accept.widthAnchor.constraint(equalToConstant: 168.dp),
            accept.heightAnchor.constraint(equalToConstant: 144.dp),
            reject.trailingAnchor.constraint(equalTo: accept.leadingAnchor, constant: -24.dp),
            reject.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            reject.widthAnchor.constraint(equalToConstant: 168.dp),
            reject.heightAnchor.constraint(equalToConstant: 144.dp),
        ])
        accept.addAction(UIAction { [weak self] _ in self?.respond(u, accepted: true) }, for: .touchUpInside)
        reject.addAction(UIAction { [weak self] _ in self?.respond(u, accepted: false) }, for: .touchUpInside)
        return card
    }

    private func respond(_ u: DemoContent.SocialUser, accepted: Bool) {
        requests.removeAll { $0.name == u.name }
        reload()
        let popup: ReminderPopupController
        if accepted {
            popup = ReminderPopupController(
                title: "Friends!",
                bodyParts: [("You are now friends with \(u.name).", false)],
                buttonTitle: "OK"
            )
        } else {
            popup = ReminderPopupController(
                title: "Declined",
                bodyParts: [("Friend request declined.", false)],
                buttonTitle: "OK"
            )
        }
        popup.present(over: self)
    }
}
