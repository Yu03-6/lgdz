import UIKit

/// Lightweight self-drawn toast (no system alert) for inline validation/errors.
enum Toast {
    static func show(_ message: String, in view: UIView) {
        let label = PaddingLabel()
        label.text = message
        label.font = DesignTokens.Font.medium(26)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 0, alpha: 0.82)
        label.layer.cornerRadius = 20.dp
        label.layer.masksToBounds = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 80.dp),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -80.dp),
        ])
        UIView.animate(withDuration: 0.2, animations: { label.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.6, options: [], animations: {
                label.alpha = 0
            }) { _ in label.removeFromSuperview() }
        }
    }
}

private final class PaddingLabel: UILabel {
    private let inset = UIEdgeInsets(top: 22, left: 36, bottom: 22, right: 36)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: scaledInset))
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        let i = scaledInset
        return CGSize(width: s.width + i.left + i.right, height: s.height + i.top + i.bottom)
    }
    private var scaledInset: UIEdgeInsets {
        UIEdgeInsets(top: inset.top.dp, left: inset.left.dp, bottom: inset.bottom.dp, right: inset.right.dp)
    }
}
