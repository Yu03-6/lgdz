import UIKit

/// Screen 9 — AI pricing / insufficient-balance reminder popup.
/// Uses the `popup_card` cutout (rounded card + heart/dots bubbles baked in);
/// title, body and OK button are overlaid. Card height grows with copy.
final class ReminderPopupController: DimmedPopupController {

    private let titleText: String
    private let bodyParts: [(String, Bool)]  // (text, isHighlighted)
    private let buttonTitle: String
    private let onConfirm: (() -> Void)?
    private let secondaryTitle: String?
    private let onSecondary: (() -> Void)?

    init(title: String,
         bodyParts: [(String, Bool)],
         buttonTitle: String = "OK",
         secondaryTitle: String? = nil,
         onSecondary: (() -> Void)? = nil,
         onConfirm: (() -> Void)? = nil) {
        self.titleText = title
        self.bodyParts = bodyParts
        self.buttonTitle = buttonTitle
        self.secondaryTitle = secondaryTitle
        self.onSecondary = onSecondary
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(card)

        let cardArt = UIImageView(image: UIImage(named: "popup_card"))
        cardArt.contentMode = .scaleToFill
        cardArt.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardArt)
        card.sendSubviewToBack(cardArt)

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = DesignTokens.Font.bold(46)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.numberOfLines = 0
        body.textAlignment = .center
        body.lineBreakMode = .byWordWrapping
        let s = NSMutableAttributedString()
        for (text, hi) in bodyParts {
            s.append(NSAttributedString(string: text, attributes: [
                .font: DesignTokens.Font.medium(30),
                .foregroundColor: hi ? DesignTokens.Color.accentYellow : DesignTokens.Color.textPrimary,
            ]))
        }
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        para.lineSpacing = 6.dp
        para.lineBreakMode = .byWordWrapping
        s.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: s.length))
        body.attributedText = s
        body.translatesAutoresizingMaskIntoConstraints = false

        let ok = PillButton(style: .primary, title: buttonTitle)
        ok.designCornerRadius = 40
        ok.addTarget(self, action: #selector(tapOK), for: .touchUpInside)
        ok.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, body])
        contentStack.axis = .vertical
        contentStack.spacing = 24.dp
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(contentStack)

        let buttonRow: UIView
        if let secondaryTitle {
            let close = PillButton(style: .secondary, title: secondaryTitle)
            close.designCornerRadius = 40
            close.addTarget(self, action: #selector(tapSecondary), for: .touchUpInside)
            close.translatesAutoresizingMaskIntoConstraints = false

            let row = UIStackView(arrangedSubviews: [close, ok])
            row.axis = .horizontal
            row.spacing = 32.dp
            row.distribution = .fillEqually
            row.translatesAutoresizingMaskIntoConstraints = false
            buttonRow = row
        } else {
            let row = UIStackView(arrangedSubviews: [ok])
            row.axis = .horizontal
            row.alignment = .center
            row.translatesAutoresizingMaskIntoConstraints = false
            buttonRow = row
        }
        card.addSubview(buttonRow)

        var constraints: [NSLayoutConstraint] = [
            card.topAnchor.constraint(equalTo: containerView.topAnchor),
            card.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            card.widthAnchor.constraint(equalToConstant: 656.dp),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 576.dp),

            cardArt.topAnchor.constraint(equalTo: card.topAnchor),
            cardArt.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cardArt.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cardArt.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 200.dp),
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 60.dp),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -60.dp),

            buttonRow.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 36.dp),
            buttonRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 60.dp),
            buttonRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -60.dp),
            buttonRow.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -48.dp),
            buttonRow.heightAnchor.constraint(equalToConstant: 110.dp),

            ok.heightAnchor.constraint(equalToConstant: 110.dp),
        ]

        if secondaryTitle == nil {
            constraints.append(ok.widthAnchor.constraint(equalToConstant: 460.dp))
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func tapSecondary() {
        dismiss(animated: true) { [weak self] in self?.onSecondary?() }
    }

    @objc private func tapOK() {
        dismiss(animated: true) { [weak self] in self?.onConfirm?() }
    }
}
