import UIKit

/// Centers app content in a phone-width column on iPad so Auto Layout constraints
/// that use `DesignMetrics` match the visible width.
final class PhoneLayoutHostViewController: UIViewController {

    private let content: UIViewController
    private let contentContainer = UIView()

    init(content: UIViewController) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.Color.background

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = .clear
        view.addSubview(contentContainer)

        addChild(content)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(content.view)
        content.didMove(toParent: self)

        let width = contentContainer.widthAnchor.constraint(equalTo: view.widthAnchor)
        width.priority = .defaultHigh
        let maxWidth = contentContainer.widthAnchor.constraint(
            lessThanOrEqualToConstant: DesignMetrics.padMaxContentWidth)

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            width,
            maxWidth,

            content.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            content.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            content.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
        ])
    }

    override var childForStatusBarStyle: UIViewController? { content }
    override var childForStatusBarHidden: UIViewController? { content }
    override var childForHomeIndicatorAutoHidden: UIViewController? { content }
}
