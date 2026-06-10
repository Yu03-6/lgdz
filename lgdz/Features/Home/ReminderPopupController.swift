import UIKit

/// Screen 9 — AI pricing / insufficient-balance reminder popup.
/// Uses the `popup_card` cutout (rounded card + heart/dots bubbles baked in);
/// title, body and OK button are overlaid.
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

        let card = UIImageView(image: UIImage(named: "popup_card"))
        card.contentMode = .scaleAspectFit
        card.isUserInteractionEnabled = true
        card.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(card)

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = DesignTokens.Font.bold(46)
        titleLabel.textColor = DesignTokens.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let body = UILabel()
        body.numberOfLines = 0
        body.textAlignment = .center
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
        s.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: s.length))
        body.attributedText = s
        body.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(body)

        let ok = PillButton(style: .primary, title: buttonTitle)
        ok.designCornerRadius = 40
        ok.addTarget(self, action: #selector(tapOK), for: .touchUpInside)
        ok.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(ok)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: containerView.topAnchor),
            card.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            card.widthAnchor.constraint(equalToConstant: 656.dp),
            card.heightAnchor.constraint(equalToConstant: 576.dp),

            // Card art has bubbles in the top ~20%; content starts below.
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 200.dp),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            body.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.dp),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 60.dp),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -60.dp),

            ok.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 36.dp),
            ok.heightAnchor.constraint(equalToConstant: 110.dp),
        ])

        if let secondaryTitle {
            let close = PillButton(style: .secondary, title: secondaryTitle)
            close.designCornerRadius = 40
            close.addTarget(self, action: #selector(tapSecondary), for: .touchUpInside)
            close.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(close)
            NSLayoutConstraint.activate([
                close.topAnchor.constraint(equalTo: ok.topAnchor),
                close.heightAnchor.constraint(equalTo: ok.heightAnchor),
                close.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 60.dp),
                close.trailingAnchor.constraint(equalTo: card.centerXAnchor, constant: -16.dp),
                ok.leadingAnchor.constraint(equalTo: card.centerXAnchor, constant: 16.dp),
                ok.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -60.dp),
            ])
        } else {
            NSLayoutConstraint.activate([
                ok.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                ok.widthAnchor.constraint(equalToConstant: 460.dp),
            ])
        }
    }

    @objc private func tapSecondary() {
        dismiss(animated: true) { [weak self] in self?.onSecondary?() }
    }

    @objc private func tapOK() {
        dismiss(animated: true) { [weak self] in self?.onConfirm?() }
    }
}
