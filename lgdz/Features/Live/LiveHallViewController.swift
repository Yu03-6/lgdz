import UIKit

/// Screen 10 — Live Square. Header + segmented tabs (Discover / Nearby /
/// Following) + 2-column grid of live cards or empty states.
final class LiveHallViewController: UIViewController {

    private enum Tab: Int, CaseIterable {
        case discover, nearby, following

        var title: String {
            switch self {
            case .discover: return "Discover"
            case .nearby: return "Nearby"
            case .following: return "Following"
            }
        }
    }

    private var selectedTab: Tab = .discover
    private let segment = UIStackView()
    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupHeader()
        setupSegment()
        setupContent()
        reloadContent()
        NotificationCenter.default.addObserver(
            self, selector: #selector(liveFollowStateChanged),
            name: .liveFollowStateDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        reloadContent()
    }

    @objc private func liveFollowStateChanged() {
        reloadContent()
    }

    private func setupHeader() {
        let header = NavHeader(title: "Live Square") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),
        ])
    }

    private func setupSegment() {
        segment.axis = .horizontal
        segment.spacing = 24.dp
        segment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segment)
        for (i, tab) in Tab.allCases.enumerated() {
            let b = PillButton(style: .secondary, title: tab.title)
            b.designCornerRadius = 36
            b.tag = i
            b.titleLabel?.font = DesignTokens.Font.semibold(30)
            b.addTarget(self, action: #selector(selectTab(_:)), for: .touchUpInside)
            segment.addArrangedSubview(b)
            b.heightAnchor.constraint(equalToConstant: 96.dp).isActive = true
        }
        applyTabStyles()

        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130.dp),
            segment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
        ])
    }

    private func applyTabStyles() {
        for case let b as PillButton in segment.arrangedSubviews {
            let on = b.tag == selectedTab.rawValue
            b.backgroundColor = on ? DesignTokens.Color.accentYellow : DesignTokens.Color.secondaryFill
            b.setTitleColor(on ? .white : DesignTokens.Color.textPrimary, for: .normal)
        }
    }

    @objc private func selectTab(_ sender: UIButton) {
        guard let tab = Tab(rawValue: sender.tag) else { return }
        selectedTab = tab
        applyTabStyles()
        reloadContent()
    }

    private func setupContent() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset.bottom = 40.dp
        view.addSubview(scroll)

        content.axis = .vertical
        content.spacing = 24.dp
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 250.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 40.dp),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -40.dp),
        ])
    }

    private func reloadContent() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        scroll.setContentOffset(.zero, animated: false)

        switch selectedTab {
        case .discover:
            populateDiscoverGrid()
        case .nearby:
            content.addArrangedSubview(
                EmptyStateView(
                    title: "No live streams nearby",
                    subtitle: "No live streams within 10KM of you."))
        case .following:
            let rooms = DemoContent.followedLiveRooms
            if rooms.isEmpty {
                content.addArrangedSubview(
                    EmptyStateView(
                        title: "No friend streams",
                        subtitle: "Your friends haven't started live streaming yet."))
            } else {
                populateGrid(rooms)
            }
        }
    }

    private func populateDiscoverGrid() {
        populateGrid(DemoContent.liveRooms)
    }

    private func populateGrid(_ rooms: [DemoContent.LiveRoom]) {
        var i = 0
        while i < rooms.count {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 24.dp
            row.addArrangedSubview(makeCard(rooms[i]))
            if i + 1 < rooms.count {
                row.addArrangedSubview(makeCard(rooms[i + 1]))
            } else {
                row.addArrangedSubview(UIView())
            }
            content.addArrangedSubview(row)
            i += 2
        }
    }

    private func makeCard(_ room: DemoContent.LiveRoom) -> UIView {
        let card = UIControl()
        card.layer.cornerRadius = 28.dp
        card.clipsToBounds = true
        card.heightAnchor.constraint(equalToConstant: 310.dp).isActive = true
        card.accessibilityIdentifier = room.id

        let cover = UIImageView(image: UIImage(named: room.cover))
        cover.contentMode = .scaleAspectFill
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.isUserInteractionEnabled = false
        card.addSubview(cover)

        let viewers = makeBadge(room.viewers)
        card.addSubview(viewers)

        let pin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        pin.tintColor = .white
        pin.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pin)

        let title = UILabel()
        title.text = room.title
        title.font = DesignTokens.Font.semibold(28)
        title.textColor = .white
        title.lineBreakMode = .byTruncatingTail
        title.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(title)

        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: card.topAnchor),
            cover.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            cover.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            viewers.topAnchor.constraint(equalTo: card.topAnchor, constant: 18.dp),
            viewers.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18.dp),
            pin.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18.dp),
            pin.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22.dp),
            pin.widthAnchor.constraint(equalToConstant: 40.dp),
            pin.heightAnchor.constraint(equalToConstant: 40.dp),
            title.leadingAnchor.constraint(equalTo: pin.trailingAnchor, constant: 10.dp),
            title.centerYAnchor.constraint(equalTo: pin.centerYAnchor),
            title.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -12.dp),
        ])

        card.addAction(UIAction { [weak self] _ in
            self?.openRoom(room)
        }, for: .touchUpInside)
        return card
    }

    private func makeBadge(_ text: String) -> UIView {
        let bg = UIView()
        bg.backgroundColor = UIColor(white: 0, alpha: 0.4)
        bg.layer.cornerRadius = 24.dp
        bg.translatesAutoresizingMaskIntoConstraints = false
        let eye = UIImageView(image: UIImage(systemName: "eye.fill"))
        eye.tintColor = .white
        eye.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = text
        label.font = DesignTokens.Font.semibold(24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(eye)
        bg.addSubview(label)
        NSLayoutConstraint.activate([
            bg.heightAnchor.constraint(equalToConstant: 48.dp),
            eye.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 18.dp),
            eye.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            eye.widthAnchor.constraint(equalToConstant: 30.dp),
            eye.heightAnchor.constraint(equalToConstant: 30.dp),
            label.leadingAnchor.constraint(equalTo: eye.trailingAnchor, constant: 10.dp),
            label.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -18.dp),
            label.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
        ])
        return bg
    }

    private func openRoom(_ room: DemoContent.LiveRoom) {
        navigationController?.pushViewController(LiveRoomViewController(room: room), animated: true)
    }
}
