import UIKit

/// Pins footer above the safe area and provides a fixed form region above it (no scroll).
enum LoginPinnedFooterLayout {

    @discardableResult
    static func installFixedForm(
        in hostView: UIView,
        below topAnchor: NSLayoutYAxisAnchor,
        footerView: UIView,
        gapAboveFooter: CGFloat = 16.dp
    ) -> UIView {
        let formArea = UIView()
        formArea.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(formArea)
        hostView.bringSubviewToFront(footerView)

        NSLayoutConstraint.activate([
            formArea.topAnchor.constraint(equalTo: topAnchor),
            formArea.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            formArea.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            formArea.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -gapAboveFooter),
        ])

        return formArea
    }

    /// Flexible spacer that grows on tall screens and collapses when vertical space is tight.
    static func makeVerticalSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return spacer
    }
}
