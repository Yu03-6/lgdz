import UIKit

/// Base for self-drawn modal popups (架构需求.md §5: 弹窗自绘).
/// Presents over full screen with a dimmed backdrop and a centered container
/// that animates in. Subclasses add content to `containerView`.
class DimmedPopupController: UIViewController {

    let containerView = UIView()
    private let dimView = UIView()

    /// Tap outside to dismiss (default false).
    var dismissOnBackdrop = false

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.45)
        dimView.frame = view.bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dimView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(backdropTap))
        dimView.addGestureRecognizer(tap)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        containerView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5, options: []) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }

    @objc private func backdropTap() {
        if dismissOnBackdrop { dismiss(animated: true) }
    }

    func present(over presenter: UIViewController) {
        presenter.present(self, animated: true)
    }
}
