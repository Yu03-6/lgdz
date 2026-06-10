import UIKit

/// Settings — Contact Us. Local support details themed for the dog-walking app.
final class ContactUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()

        let header = NavHeader(title: "Contact Us") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 28.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        stack.addArrangedSubview(makeCard(
            title: "Customer Support",
            body: "Questions about walks, coins, posting, or your account? Our team is happy to help."
        ))
        stack.addArrangedSubview(makeCard(
            title: "Email",
            body: "support@vivi.app\n\nInclude your registered email and a short description of the issue. Screenshots are welcome."
        ))
        stack.addArrangedSubview(makeCard(
            title: "Response Time",
            body: "We aim to reply within 1–2 business days. Messages about safety or harassment are prioritized."
        ))
        stack.addArrangedSubview(makeCard(
            title: "Feedback",
            body: "Suggestions for new park routes, group walk features, or AI chat improvements? Tell us — this app is built for dog lovers like you."
        ))

        let margin = 32.dp
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40.dp),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: margin),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -margin),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -margin * 2),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func makeCard(title: String, body: String) -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignTokens.Font.bold(34)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.font = DesignTokens.Font.regular(28)
        bodyLabel.textColor = DesignTokens.Color.textPrimary
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 32.dp),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 36.dp),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -36.dp),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.dp),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32.dp),
        ])
        return card
    }
}
