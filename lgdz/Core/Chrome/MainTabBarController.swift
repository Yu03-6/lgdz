import UIKit

/// Floating custom tab bar (设计原稿: green rounded bar, margin 30, height 119).
/// Tabs: Home (default), Feed, Chat, Me. System tab bar is hidden.
final class MainTabBarController: UITabBarController {

    private let floatingBar = FloatingTabBar()

    private struct TabSpec {
        let title: String
        let icon: String
        let iconSel: String
        let make: () -> UIViewController
    }

    private let specs: [TabSpec] = [
        TabSpec(title: "Home", icon: "home_tab", iconSel: "home_tab_sel") { HomeViewController() },
        TabSpec(title: "Feed", icon: "feed_tab", iconSel: "feed_tab_sel") { FeedViewController() },
        TabSpec(title: "Chat", icon: "chat_tab", iconSel: "chat_tab_sel") { ChatListViewController() },
        TabSpec(title: "Me", icon: "me_tab", iconSel: "me_tab_sel") { MeViewController() },
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.Color.background
        tabBar.isHidden = true

        viewControllers = specs.map { spec in
            let nav = TabNavigationController(rootViewController: spec.make())
            nav.tabBarOwner = self
            return nav
        }

        floatingBar.configure(items: specs.map { ($0.title, $0.icon, $0.iconSel) })
        floatingBar.onSelect = { [weak self] index in
            self?.selectedIndex = index
            self?.updateFloatingBarVisibility()
        }
        floatingBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingBar)
        NSLayoutConstraint.activate([
            floatingBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.dp),
            floatingBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.dp),
            floatingBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.dp),
            floatingBar.heightAnchor.constraint(equalToConstant: 119.dp),
        ])
        selectedIndex = 0
        floatingBar.select(index: 0)
        refreshChatBadge()
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshChatBadge),
            name: .accountDidActivate, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshChatBadge),
            name: .chatUnreadDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func refreshChatBadge() {
        setChatBadge(DemoContent.totalUnread)
    }

    /// Expose bottom inset so tab content can avoid the floating bar.
    static var contentBottomInset: CGFloat { 119.dp + 20.dp }

    /// Programmatically switch tabs (updates floating bar selection and visibility).
    func selectTab(at index: Int) {
        guard specs.indices.contains(index) else { return }
        selectedIndex = index
        floatingBar.select(index: index)
        updateFloatingBarVisibility()
    }

    /// Set a badge count on the Chat tab (index 2).
    func setChatBadge(_ count: Int) {
        floatingBar.setBadge(count, at: 2)
    }

    private static let tabBarHideDuration: TimeInterval = 0.12
    private static let tabBarShowDuration: TimeInterval = 0.22

    /// Hide the floating tab bar while a pushed screen is shown (设计: Push 页无 TabBar).
    func setFloatingBarHidden(_ hidden: Bool, animated: Bool = true) {
        guard floatingBar.isHidden != hidden else { return }
        if !animated {
            floatingBar.layer.removeAllAnimations()
            floatingBar.alpha = hidden ? 0 : 1
            floatingBar.isHidden = hidden
            return
        }
        if hidden {
            UIView.animate(
                withDuration: Self.tabBarHideDuration,
                delay: 0,
                options: [.curveEaseIn, .beginFromCurrentState],
                animations: { self.floatingBar.alpha = 0 },
                completion: { _ in
                    self.floatingBar.isHidden = true
                })
        } else {
            floatingBar.isHidden = false
            floatingBar.alpha = 0
            UIView.animate(
                withDuration: Self.tabBarShowDuration,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState],
                animations: { self.floatingBar.alpha = 1 })
        }
    }

    /// Bottom tab bar is visible only on the four main tab roots; hidden on all pushed screens.
    func updateFloatingBarVisibility(animated: Bool = true) {
        guard let nav = selectedViewController as? UINavigationController else {
            setFloatingBarHidden(true, animated: animated)
            return
        }
        let hidden = nav.viewControllers.count > 1
        setFloatingBarHidden(hidden, animated: animated)
    }

    /// Called from `willShow` so the tab bar hides as soon as a push starts, not after the transition ends.
    func updateFloatingBarVisibility(for navigationController: UINavigationController,
                                     showing viewController: UIViewController,
                                     animated: Bool) {
        guard navigationController === selectedViewController else { return }
        let isRoot = navigationController.viewControllers.first === viewController
        setFloatingBarHidden(!isRoot, animated: animated)
    }
}

/// Per-tab navigation stack; toggles floating tab bar visibility on push/pop.
final class TabNavigationController: UINavigationController, UINavigationControllerDelegate {

    weak var tabBarOwner: MainTabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        tabBarOwner?.updateFloatingBarVisibility(for: navigationController,
                                                 showing: viewController,
                                                 animated: animated)
    }
}

/// The rounded green bar view with icon+label buttons.
final class FloatingTabBar: UIView {

    var onSelect: ((Int) -> Void)?
    private var buttons: [TabButton] = []
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignTokens.Color.accent
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.dp),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.dp),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(items: [(String, String, String)]) {
        for (i, item) in items.enumerated() {
            let b = TabButton(title: item.0, icon: item.1, iconSel: item.2)
            b.tag = i
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            buttons.append(b)
            stack.addArrangedSubview(b)
        }
    }

    func setBadge(_ count: Int, at index: Int) {
        guard index < buttons.count else { return }
        buttons[index].setBadge(count)
    }

    @objc private func tap(_ sender: TabButton) {
        select(index: sender.tag)
        onSelect?(sender.tag)
    }

    func select(index: Int) {
        for (i, b) in buttons.enumerated() { b.setSelected(i == index) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
    }
}

private final class TabButton: UIControl {
    private let iconView = UIImageView()
    private let label = UILabel()
    private let badge = UILabel()
    private let icon: String
    private let iconSel: String

    init(title: String, icon: String, iconSel: String) {
        self.icon = icon
        self.iconSel = iconSel
        super.init(frame: .zero)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        label.text = title
        label.font = DesignTokens.Font.semibold(22)
        label.textColor = DesignTokens.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        badge.font = DesignTokens.Font.bold(18)
        badge.textColor = .white
        badge.backgroundColor = .systemRed
        badge.textAlignment = .center
        badge.layer.masksToBounds = true
        badge.isHidden = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badge)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 22.dp),
            iconView.widthAnchor.constraint(equalToConstant: 46.dp),
            iconView.heightAnchor.constraint(equalToConstant: 46.dp),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6.dp),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            badge.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: -6.dp),
            badge.centerYAnchor.constraint(equalTo: iconView.topAnchor, constant: 2.dp),
            badge.heightAnchor.constraint(equalToConstant: 30.dp),
            badge.widthAnchor.constraint(greaterThanOrEqualTo: badge.heightAnchor),
        ])
        isUserInteractionEnabled = true
        iconView.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ selected: Bool) {
        iconView.image = UIImage(named: selected ? iconSel : icon)
        label.font = selected ? DesignTokens.Font.bold(22) : DesignTokens.Font.semibold(22)
    }

    func setBadge(_ count: Int) {
        if count <= 0 { badge.isHidden = true; return }
        badge.isHidden = false
        badge.text = count > 99 ? "99+" : " \(count) "
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        badge.layer.cornerRadius = badge.bounds.height / 2
    }
}
