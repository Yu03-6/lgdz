import UIKit

/// 举报拉黑 — Report / Block action sheet. Self-drawn bottom sheet with two
/// side-by-side buttons (Block = olive, Report = red).
final class ReportBlockSheet: UIViewController {

    private let targetName: String
    private let onBlock: () -> Void
    private let sheet = UIView()
    private var sheetBottom: NSLayoutConstraint!

    init(targetName: String, onBlock: (() -> Void)? = nil) {
        self.targetName = targetName
        self.onBlock = onBlock ?? { DemoContent.blockUser(named: targetName) }
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.35)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))

        sheet.backgroundColor = DesignTokens.Color.background
        sheet.layer.cornerRadius = 40.dp
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheet)

        let block = makeButton("Block", bg: DesignTokens.Color.textPrimary)
        block.addTarget(self, action: #selector(tapBlock), for: .touchUpInside)
        let report = makeButton("Report", bg: DesignTokens.Color.danger)
        report.addTarget(self, action: #selector(tapReport), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [block, report])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 28.dp
        row.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(row)

        sheetBottom = sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400.dp)
        NSLayoutConstraint.activate([
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetBottom,
            row.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 44.dp),
            row.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 40.dp),
            row.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -40.dp),
            row.heightAnchor.constraint(equalToConstant: 130.dp),
            row.bottomAnchor.constraint(equalTo: sheet.safeAreaLayoutGuide.bottomAnchor, constant: -24.dp),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetBottom.constant = 0
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.4) {
            self.view.layoutIfNeeded()
        }
    }

    private func makeButton(_ title: String, bg: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = DesignTokens.Font.bold(34)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = bg
        b.layer.cornerRadius = 32.dp
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }

    @objc private func tapBlock() {
        let host = presentingViewController
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.onBlock()
            let toastHost = host?.view ?? UIApplication.keyWindowTop
            Toast.show("Blocked \(self.targetName)", in: toastHost)
        }
    }

    @objc private func tapReport() {
        let host = presentingViewController
        dismiss(animated: true) {
            guard let host else { return }
            let popup = ReminderPopupController(
                title: "Thank You",
                bodyParts: [(
                    "We've received your feedback. Our team will review this content shortly.",
                    false)],
                buttonTitle: "OK")
            popup.present(over: host)
        }
    }

    @objc private func close() { dismiss(animated: true) }
}

extension UIApplication {
    /// Top-most key window for transient UI (toasts) after a modal dismiss.
    static var keyWindowTop: UIView {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        return scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first ?? UIView()
    }
}
