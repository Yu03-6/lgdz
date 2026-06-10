import UIKit

/// Scrollable legal / policy text page (Community Guidelines, agreements, etc.).
final class LegalTextViewController: UIViewController {

    private let pageTitle: String
    private let bodyText: String

    init(title: String, body: String) {
        self.pageTitle = title
        self.bodyText = body
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()

        let header = NavHeader(title: pageTitle) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        card.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(card)

        let label = UILabel()
        label.numberOfLines = 0
        label.font = DesignTokens.Font.regular(28)
        label.textColor = DesignTokens.Color.textPrimary
        label.text = bodyText
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

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

            card.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            card.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40.dp),
            card.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: margin),
            card.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -margin),
            card.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -margin * 2),

            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 36.dp),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -36.dp),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 36.dp),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -36.dp),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }
}

enum LegalCopy {

    static let communityGuidelines = """
    Welcome to our dog-walking community! These guidelines help keep walks, meetups, and chats safe and friendly for people and pups.

    1. Be kind and respectful
    Treat other members, their dogs, and park staff with courtesy. Disagreements happen — stay constructive and avoid harassment, hate speech, or personal attacks.

    2. Keep dogs and people safe
    Share accurate info about your dog's temperament, leash status, and vaccination when joining group walks. Never encourage unsafe behavior around traffic, wildlife, or unfamiliar dogs.

    3. Respect privacy
    Ask before posting photos or videos that include someone else or their dog. Do not share private contact details in public posts or comments.

    4. No spam or scams
    Do not flood feeds with repetitive promotions, fake giveaways, or off-topic links. Commercial posts should be clearly labeled and relevant to dog walking or pet care.

    5. Report problems
    Use Block or Report on profiles and posts that violate these rules. We review reports locally in this demo build and may restrict accounts that harm the community.

    6. Have fun responsibly
    Meet in public places, tell a friend where you are going, and follow local leash laws. Our app connects dog lovers — your judgment keeps every walk enjoyable.

    By using this app you agree to follow these guidelines. Updates may be posted here from time to time.
    """
}
