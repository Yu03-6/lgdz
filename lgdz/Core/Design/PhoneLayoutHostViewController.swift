import UIKit

/// Centers phone-layout content in a capped-width column when running on iPad.
/// Prevents `.dp` scaling from using the full tablet window width while the UI
/// is rendered in a narrower compatibility column.
final class PhoneLayoutHostViewController: UIViewController {

    private let content: UIViewController

    init(content: UIViewController) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.Color.background

        addChild(content)

        let column = UIView()
        column.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(column)

        content.view.translatesAutoresizingMaskIntoConstraints = false
        column.addSubview(content.view)
        content.didMove(toParent: self)

        let matchWindowWidth = column.widthAnchor.constraint(equalTo: view.widthAnchor)
        matchWindowWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            column.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            column.topAnchor.constraint(equalTo: view.topAnchor),
            column.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            matchWindowWidth,
            column.widthAnchor.constraint(lessThanOrEqualToConstant: DesignMetrics.padMaxContentWidth),

            content.view.topAnchor.constraint(equalTo: column.topAnchor),
            content.view.leadingAnchor.constraint(equalTo: column.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: column.trailingAnchor),
            content.view.bottomAnchor.constraint(equalTo: column.bottomAnchor),
        ])
    }
}
