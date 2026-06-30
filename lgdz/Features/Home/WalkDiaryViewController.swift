import UIKit

/// Walk diary — check-in history and new walk logging.
final class WalkDiaryViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()
    private let entriesStack = UIStackView()
    private let emptyView = EmptyStateView(
        title: "No walks yet",
        subtitle: "Tap Check In after your next stroll")

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupLayout()
        reloadEntries()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadEntries),
            name: .walkDiaryDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        reloadEntries()
    }

    private func setupLayout() {
        let header = NavHeader(title: "Walk Diary") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)

        content.axis = .vertical
        content.spacing = 24.dp
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        let statsCard = makeStatsCard()
        content.addArrangedSubview(statsCard)

        let checkIn = PillButton(style: .primary, title: "Check In Today's Walk")
        checkIn.designCornerRadius = 32
        checkIn.heightAnchor.constraint(equalToConstant: 108.dp).isActive = true
        checkIn.addTarget(self, action: #selector(tapCheckIn), for: .touchUpInside)
        content.addArrangedSubview(checkIn)

        let listTitle = UILabel()
        listTitle.text = "Recent walks"
        listTitle.font = DesignTokens.Font.bold(38)
        listTitle.textColor = DesignTokens.Color.textPrimary
        content.addArrangedSubview(listTitle)

        entriesStack.axis = .vertical
        entriesStack.spacing = 20.dp
        content.addArrangedSubview(entriesStack)

        emptyView.isHidden = true
        content.addArrangedSubview(emptyView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16.dp),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40.dp),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 32.dp),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -32.dp),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -64.dp),
        ])
    }

    private func makeStatsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp
        card.translatesAutoresizingMaskIntoConstraints = false

        let streak = UILabel()
        streak.tag = 100
        streak.font = DesignTokens.Font.bold(44)
        streak.textColor = DesignTokens.Color.textPrimary

        let streakSub = UILabel()
        streakSub.text = "day streak"
        streakSub.font = DesignTokens.Font.medium(28)
        streakSub.textColor = DesignTokens.Color.textMuted

        let today = UILabel()
        today.tag = 101
        today.font = DesignTokens.Font.semibold(30)
        today.textColor = DesignTokens.Color.textPrimary
        today.numberOfLines = 0

        let v1 = UIStackView(arrangedSubviews: [streak, streakSub])
        v1.axis = .vertical
        v1.alignment = .leading

        let row = UIStackView(arrangedSubviews: [v1, UIView()])
        row.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [row, today])
        stack.axis = .vertical
        stack.spacing = 20.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 180.dp),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 32.dp),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32.dp),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 32.dp),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -32.dp),
        ])
        return card
    }

    @objc private func reloadEntries() {
        if let card = content.arrangedSubviews.first,
           let streakLabel = card.viewWithTag(100) as? UILabel,
           let todayLabel = card.viewWithTag(101) as? UILabel {
            streakLabel.text = "\(DogWalkingStore.currentStreak())"
            todayLabel.text = DogWalkingStore.hasCheckedInToday()
                ? "✓ You checked in today — keep it up!"
                : "No check-in yet today. Log your walk when you're back."
        }

        entriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let entries = DogWalkingStore.walkDiaryEntries()
        emptyView.isHidden = !entries.isEmpty

        for entry in entries {
            entriesStack.addArrangedSubview(makeEntryCard(entry))
        }
    }

    private func makeEntryCard(_ entry: WalkCheckIn) -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 28.dp

        let day = UILabel()
        day.text = DogWalkingStore.relativeDay(entry.date)
        day.font = DesignTokens.Font.bold(32)
        day.textColor = DesignTokens.Color.textPrimary

        let time = UILabel()
        time.text = DogWalkingStore.formattedDate(entry.date)
        time.font = DesignTokens.Font.regular(26)
        time.textColor = DesignTokens.Color.textMuted

        let duration = UILabel()
        duration.text = "\(entry.durationMinutes) min walk"
        duration.font = DesignTokens.Font.semibold(28)
        duration.textColor = DesignTokens.Color.accentYellow

        let note = UILabel()
        note.text = entry.note.isEmpty ? "No note added" : entry.note
        note.font = DesignTokens.Font.regular(28)
        note.textColor = DesignTokens.Color.textPrimary
        note.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [day, time, duration, note])
        stack.axis = .vertical
        stack.spacing = 8.dp
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28.dp),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28.dp),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28.dp),
        ])
        return card
    }

    @objc private func tapCheckIn() {
        presentCheckInSheet()
    }

    private func presentCheckInSheet() {
        let sheet = WalkCheckInSheetController { [weak self] note, minutes in
            DogWalkingStore.addCheckIn(note: note, durationMinutes: minutes)
            self?.present(ReminderPopupController(
                title: "Checked in!",
                bodyParts: [("Your walk is saved to the diary.", false)],
                onConfirm: nil), animated: true)
        }
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        present(sheet, animated: true)
    }
}

/// Bottom sheet for logging a walk check-in.
final class WalkCheckInSheetController: DimmedPopupController {

    private let onSave: (String, Int) -> Void
    private var selectedMinutes = 30
    private let noteField = UITextView()
    private var minuteButtons: [UIButton] = []
    private var keyboardPopupAvoidance: KeyboardPopupAvoidance?

    init(onSave: @escaping (String, Int) -> Void) {
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 40.dp
        card.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(card)

        let title = UILabel()
        title.text = "Log your walk"
        title.font = DesignTokens.Font.bold(40)
        title.textColor = DesignTokens.Color.textPrimary

        let durationLabel = UILabel()
        durationLabel.text = "Duration"
        durationLabel.font = DesignTokens.Font.semibold(30)
        durationLabel.textColor = DesignTokens.Color.textPrimary

        let durationRow = UIStackView()
        durationRow.axis = .horizontal
        durationRow.spacing = 16.dp
        durationRow.distribution = .fillEqually
        for minutes in [15, 30, 45, 60] {
            let btn = UIButton(type: .system)
            btn.setTitle("\(minutes)m", for: .normal)
            btn.titleLabel?.font = DesignTokens.Font.semibold(28)
            btn.layer.cornerRadius = 24.dp
            btn.tag = minutes
            btn.addTarget(self, action: #selector(selectDuration(_:)), for: .touchUpInside)
            minuteButtons.append(btn)
            durationRow.addArrangedSubview(btn)
        }
        updateDurationButtons()

        let noteLabel = UILabel()
        noteLabel.text = "Note (optional)"
        noteLabel.font = DesignTokens.Font.semibold(30)
        noteLabel.textColor = DesignTokens.Color.textPrimary

        noteField.font = DesignTokens.Font.regular(28)
        noteField.textColor = DesignTokens.Color.textPrimary
        noteField.backgroundColor = DesignTokens.Color.secondaryFill
        noteField.layer.cornerRadius = 20.dp
        noteField.textContainerInset = UIEdgeInsets(top: 18.dp, left: 20.dp, bottom: 18.dp, right: 20.dp)
        noteField.translatesAutoresizingMaskIntoConstraints = false

        let save = PillButton(style: .primary, title: "Save Check-in")
        save.designCornerRadius = 32
        save.addTarget(self, action: #selector(tapSave), for: .touchUpInside)

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.font = DesignTokens.Font.medium(28)
        cancel.setTitleColor(DesignTokens.Color.textMuted, for: .normal)
        cancel.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            title, durationLabel, durationRow, noteLabel, noteField, save, cancel,
        ])
        stack.axis = .vertical
        stack.spacing = 24.dp
        stack.setCustomSpacing(32.dp, after: noteField)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        let cardHPad = 40.dp
        let cardVPad = 40.dp

        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48.dp),

            card.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            card.topAnchor.constraint(equalTo: containerView.topAnchor),
            card.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: cardVPad),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -cardVPad),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: cardHPad),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -cardHPad),

            durationRow.heightAnchor.constraint(equalToConstant: 80.dp),
            noteField.heightAnchor.constraint(equalToConstant: 150.dp),
            save.heightAnchor.constraint(equalToConstant: 100.dp),
        ])

        keyboardPopupAvoidance = KeyboardPopupAvoidance()
        keyboardPopupAvoidance?.attach(hostView: view, containerView: containerView)
    }

    @objc private func selectDuration(_ sender: UIButton) {
        selectedMinutes = sender.tag
        updateDurationButtons()
    }

    private func updateDurationButtons() {
        for btn in minuteButtons {
            let selected = btn.tag == selectedMinutes
            btn.backgroundColor = selected ? DesignTokens.Color.accent : DesignTokens.Color.secondaryFill
            btn.setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
        }
    }

    @objc private func tapSave() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.onSave(self.noteField.text ?? "", self.selectedMinutes)
        }
    }

    @objc private func tapCancel() {
        dismiss(animated: true)
    }
}
