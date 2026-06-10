import UIKit

/// Bottom-left live chat overlay: random incoming comments, scroll-up feed, user posts as red "ME".
final class LiveCommentOverlayView: UIView {

    struct Message: Equatable {
        let avatar: String
        let name: String
        let text: String
        let isSelf: Bool
    }

    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let fadeMask = CAGradientLayer()

    private var pool: [Message] = []
    private var recentRandomTexts: [String] = []
    private var timer: Timer?
    private let maxStoredRows = 48

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isUserInteractionEnabled = false

        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        stack.axis = .vertical
        stack.spacing = 14.dp
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        fadeMask.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor,
            UIColor.black.cgColor,
        ]
        fadeMask.locations = [0, 0.18, 1]
        layer.mask = fadeMask
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        fadeMask.frame = bounds
    }

    func configure(pool: [Message]) {
        self.pool = pool
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        recentRandomTexts.removeAll()
        for _ in 0..<Int.random(in: 2...4) {
            appendRandom(animated: false)
        }
        scrollToBottom(animated: false)
    }

    func startAutoFeed() {
        scheduleNextRandom()
    }

    func stopAutoFeed() {
        timer?.invalidate()
        timer = nil
    }

    func appendUserComment(text: String, avatar: String) {
        append(
            Message(avatar: avatar, name: "ME", text: text, isSelf: true),
            animated: true)
    }

    private func scheduleNextRandom() {
        timer?.invalidate()
        let delay = Double.random(in: 1.6...3.4)
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.appendRandom(animated: true)
            self?.scheduleNextRandom()
        }
    }

    private func appendRandom(animated: Bool) {
        guard !pool.isEmpty else { return }
        var candidates = pool.filter { !recentRandomTexts.contains($0.text) }
        if candidates.isEmpty {
            recentRandomTexts.removeAll()
            candidates = pool
        }
        let pick = candidates.randomElement() ?? pool[0]
        recentRandomTexts.append(pick.text)
        if recentRandomTexts.count > min(6, pool.count) {
            recentRandomTexts.removeFirst()
        }
        append(pick, animated: animated)
    }

    private func append(_ message: Message, animated: Bool) {
        let row = makeRow(message)
        stack.addArrangedSubview(row)
        trimOldRows()

        if animated {
            row.alpha = 0
            row.transform = CGAffineTransform(translationX: 0, y: 24.dp)
            layoutIfNeeded()
            scrollToBottom(animated: true)
            UIView.animate(withDuration: 0.38, delay: 0, options: .curveEaseOut) {
                row.alpha = 1
                row.transform = .identity
            }
        } else {
            layoutIfNeeded()
            scrollToBottom(animated: false)
        }
    }

    private func trimOldRows() {
        while stack.arrangedSubviews.count > maxStoredRows,
              let first = stack.arrangedSubviews.first {
            first.removeFromSuperview()
        }
    }

    private func scrollToBottom(animated: Bool) {
        layoutIfNeeded()
        let y = max(0, scrollView.contentSize.height - scrollView.bounds.height)
        guard animated else {
            scrollView.contentOffset.y = y
            return
        }
        UIView.animate(withDuration: 0.38, delay: 0, options: .curveEaseOut) {
            self.scrollView.contentOffset.y = y
        }
    }

    private func makeRow(_ message: Message) -> UIView {
        let row = UIView()
        row.backgroundColor = UIColor(white: 0, alpha: 0.32)
        row.layer.cornerRadius = 18.dp
        row.translatesAutoresizingMaskIntoConstraints = false

        let avatar = CircleImageView(asset: message.avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(avatar)

        let name = UILabel()
        name.text = message.name
        name.font = DesignTokens.Font.semibold(24)
        name.textColor = message.isSelf ? DesignTokens.Color.danger : UIColor(white: 1, alpha: 0.72)
        name.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(name)

        let text = UILabel()
        text.text = message.text
        text.numberOfLines = 0
        text.font = DesignTokens.Font.medium(28)
        text.textColor = .white
        text.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(text)

        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(lessThanOrEqualToConstant: 520.dp),

            avatar.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14.dp),
            avatar.topAnchor.constraint(equalTo: row.topAnchor, constant: 12.dp),
            avatar.widthAnchor.constraint(equalToConstant: 56.dp),
            avatar.heightAnchor.constraint(equalToConstant: 56.dp),
            avatar.bottomAnchor.constraint(lessThanOrEqualTo: row.bottomAnchor, constant: -12.dp),

            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12.dp),
            name.topAnchor.constraint(equalTo: row.topAnchor, constant: 12.dp),
            name.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16.dp),

            text.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            text.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2.dp),
            text.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16.dp),
            text.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12.dp),
        ])
        return row
    }
}
