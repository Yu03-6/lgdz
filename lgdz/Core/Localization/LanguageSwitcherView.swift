import UIKit

/// Tap to reveal EN / FR / SV options with selected vs unselected styling.
final class LanguageSwitcherView: UIView {

    weak var overlayHost: UIView?

    private let trigger = UIButton(type: .system)
    private let menu = UIView()
    private let optionsStack = UIStackView()
    private var optionButtons: [AppLanguage: UIButton] = [:]
    private var isMenuVisible = false
    private var menuConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        trigger.titleLabel?.font = DesignTokens.Font.bold(28)
        trigger.setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
        trigger.backgroundColor = DesignTokens.Color.card
        trigger.layer.cornerRadius = 30.dp
        trigger.layer.masksToBounds = true
        trigger.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24.dp, bottom: 0, right: 20.dp)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(22), weight: .semibold)
        trigger.setImage(UIImage(systemName: "chevron.down", withConfiguration: cfg), for: .normal)
        trigger.tintColor = DesignTokens.Color.textMuted
        trigger.semanticContentAttribute = .forceRightToLeft
        trigger.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8.dp, bottom: 0, right: -8.dp)
        trigger.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        trigger.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trigger)

        menu.backgroundColor = DesignTokens.Color.card
        menu.layer.cornerRadius = 24.dp
        menu.layer.shadowColor = UIColor.black.cgColor
        menu.layer.shadowOpacity = 0.12
        menu.layer.shadowRadius = 12
        menu.layer.shadowOffset = CGSize(width: 0, height: 6)
        menu.isHidden = true
        menu.alpha = 0
        menu.translatesAutoresizingMaskIntoConstraints = false

        optionsStack.axis = .vertical
        optionsStack.spacing = 8.dp
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        menu.addSubview(optionsStack)

        for (index, language) in AppLanguage.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(language.displayCode, for: .normal)
            button.titleLabel?.font = DesignTokens.Font.semibold(28)
            button.layer.cornerRadius = 20.dp
            button.layer.masksToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 12.dp, left: 24.dp, bottom: 12.dp, right: 24.dp)
            button.contentHorizontalAlignment = .leading
            button.addTarget(self, action: #selector(selectLanguage(_:)), for: .touchUpInside)
            optionButtons[language] = button
            optionsStack.addArrangedSubview(button)
            button.heightAnchor.constraint(equalToConstant: 56.dp).isActive = true
        }

        NSLayoutConstraint.activate([
            trigger.topAnchor.constraint(equalTo: topAnchor),
            trigger.leadingAnchor.constraint(equalTo: leadingAnchor),
            trigger.trailingAnchor.constraint(equalTo: trailingAnchor),
            trigger.heightAnchor.constraint(equalToConstant: 60.dp),
            trigger.bottomAnchor.constraint(equalTo: bottomAnchor),

            optionsStack.topAnchor.constraint(equalTo: menu.topAnchor, constant: 12.dp),
            optionsStack.bottomAnchor.constraint(equalTo: menu.bottomAnchor, constant: -12.dp),
            optionsStack.leadingAnchor.constraint(equalTo: menu.leadingAnchor, constant: 12.dp),
            optionsStack.trailingAnchor.constraint(equalTo: menu.trailingAnchor, constant: -12.dp),
        ])

        refreshSelection()
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshSelection),
            name: .languageDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        menu.removeFromSuperview()
    }

    var menuViewIfVisible: UIView? {
        isMenuVisible ? menu : nil
    }

    @objc func refreshSelection() {
        trigger.setTitle(L10n.current.displayCode, for: .normal)
        for (language, button) in optionButtons {
            let selected = language == L10n.current
            button.backgroundColor = selected
                ? DesignTokens.Color.accent
                : DesignTokens.Color.secondaryFill
            button.setTitleColor(
                selected ? DesignTokens.Color.textPrimary : DesignTokens.Color.textMuted,
                for: .normal)
        }
    }

    func dismissMenu() {
        guard isMenuVisible else { return }
        isMenuVisible = false
        UIView.animate(withDuration: 0.2) {
            self.menu.alpha = 0
        } completion: { _ in
            self.menu.isHidden = true
            self.menu.removeFromSuperview()
        }
        updateChevron(expanded: false)
    }

    @objc private func toggleMenu() {
        if isMenuVisible {
            dismissMenu()
            return
        }
        guard let host = overlayHost ?? window else { return }
        host.addSubview(menu)
        menu.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.deactivate(menuConstraints)
        let anchor = convert(trigger.bounds, to: host)
        menuConstraints = [
            menu.topAnchor.constraint(equalTo: host.topAnchor, constant: anchor.maxY + 10.dp),
            menu.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: anchor.minX),
            menu.widthAnchor.constraint(equalToConstant: 168.dp),
        ]
        NSLayoutConstraint.activate(menuConstraints)
        isMenuVisible = true
        menu.isHidden = false
        updateChevron(expanded: true)
        UIView.animate(withDuration: 0.2) {
            self.menu.alpha = 1
        }
    }

    private func updateChevron(expanded: Bool) {
        let symbol = expanded ? "chevron.up" : "chevron.down"
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(22), weight: .semibold)
        trigger.setImage(UIImage(systemName: symbol, withConfiguration: cfg), for: .normal)
    }

    @objc private func selectLanguage(_ sender: UIButton) {
        let index = sender.tag
        guard AppLanguage.allCases.indices.contains(index) else { return }
        let language = AppLanguage.allCases[index]
        if language != L10n.current {
            L10n.current = language
            refreshSelection()
        }
        dismissMenu()
    }
}

/// Tap outside the open language menu to dismiss it.
final class LanguageMenuDismissInstaller: NSObject, UIGestureRecognizerDelegate {

    private weak var switcher: LanguageSwitcherView?
    private weak var hostView: UIView?
    private var tap: UITapGestureRecognizer?

    func install(on hostView: UIView, switcher: LanguageSwitcherView) {
        self.switcher = switcher
        self.hostView = hostView
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        hostView.addGestureRecognizer(tap)
        self.tap = tap
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let switcher, let hostView else { return }
        let point = gesture.location(in: hostView)
        let switcherFrame = switcher.convert(switcher.bounds, to: hostView)
        if switcherFrame.contains(point) { return }
        if let menu = switcher.menuViewIfVisible {
            let menuFrame = menu.convert(menu.bounds, to: hostView)
            if menuFrame.contains(point) { return }
        }
        switcher.dismissMenu()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        if view is UIControl { return false }
        return true
    }
}
