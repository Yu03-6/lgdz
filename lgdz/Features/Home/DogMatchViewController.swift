import UIKit
import ObjectiveC

/// Dog buddy matching — pick breed / size / personality tags and find similar walkers.
final class DogMatchViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()
    private let resultsStack = UIStackView()
    private let emptyView = EmptyStateView(
        title: "No matches yet",
        subtitle: "Choose your dog's tags and tap Find Matches")

    private let breedFlow = TagFlowView()
    private let sizeFlow = TagFlowView()
    private let personalityFlow = TagFlowView()
    private let dogNameField = UITextField()
    private var keyboardAvoidance: KeyboardFormAvoidance?

    private var matchResults: [DogMatchResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        setupLayout()
        loadSavedProfile()
        NotificationCenter.default.addObserver(
            self, selector: #selector(loadSavedProfile),
            name: .dogProfileDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func setupLayout() {
        let header = NavHeader(title: "Dog Buddy Match") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)

        content.axis = .vertical
        content.spacing = 28.dp
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        let intro = UILabel()
        intro.text = "Set your pup's tags to find walkers with similar dogs nearby."
        intro.font = DesignTokens.Font.regular(28)
        intro.textColor = DesignTokens.Color.textMuted
        intro.numberOfLines = 0
        content.addArrangedSubview(intro)

        content.addArrangedSubview(makeProfileCard())

        let find = PillButton(style: .primary, title: "Find Matches")
        find.designCornerRadius = 32
        find.heightAnchor.constraint(equalToConstant: 108.dp).isActive = true
        find.addTarget(self, action: #selector(tapFindMatches), for: .touchUpInside)
        content.addArrangedSubview(find)

        let resultsTitle = UILabel()
        resultsTitle.text = "Matches"
        resultsTitle.font = DesignTokens.Font.bold(38)
        resultsTitle.textColor = DesignTokens.Color.textPrimary
        content.addArrangedSubview(resultsTitle)

        resultsStack.axis = .vertical
        resultsStack.spacing = 20.dp
        content.addArrangedSubview(resultsStack)

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

        keyboardAvoidance = KeyboardFormAvoidance()
        keyboardAvoidance?.attach(scrollView: scroll, hostView: view, baseBottomInset: 40.dp)
    }

    private func makeProfileCard() -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 32.dp

        dogNameField.placeholder = "Your dog's name"
        dogNameField.font = DesignTokens.Font.regular(28)
        dogNameField.textColor = DesignTokens.Color.textPrimary
        dogNameField.backgroundColor = DesignTokens.Color.secondaryFill
        dogNameField.layer.cornerRadius = 20.dp
        dogNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20.dp, height: 1))
        dogNameField.leftViewMode = .always
        dogNameField.translatesAutoresizingMaskIntoConstraints = false

        let breedLabel = sectionLabel("Breed")
        breedFlow.translatesAutoresizingMaskIntoConstraints = false
        breedFlow.setTags(DogWalkingStore.breeds, multiSelect: false)

        let sizeLabel = sectionLabel("Size")
        sizeFlow.translatesAutoresizingMaskIntoConstraints = false
        sizeFlow.setTags(DogSize.allCases.map(\.rawValue), multiSelect: false)

        let personalityLabel = sectionLabel("Personality (pick 1–3)")
        personalityFlow.translatesAutoresizingMaskIntoConstraints = false
        personalityFlow.setTags(DogWalkingStore.personalities, multiSelect: true)

        let stack = UIStackView(arrangedSubviews: [
            dogNameField, breedLabel, breedFlow, sizeLabel, sizeFlow,
            personalityLabel, personalityFlow,
        ])
        stack.axis = .vertical
        stack.spacing = 16.dp
        stack.setCustomSpacing(24.dp, after: dogNameField)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            dogNameField.heightAnchor.constraint(equalToConstant: 88.dp),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 32.dp),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32.dp),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28.dp),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28.dp),
        ])
        return card
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = DesignTokens.Font.semibold(30)
        label.textColor = DesignTokens.Color.textPrimary
        return label
    }

    @objc private func loadSavedProfile() {
        guard let profile = DogWalkingStore.currentUserDogProfile() else { return }
        dogNameField.text = profile.dogName
        breedFlow.setTags(DogWalkingStore.breeds, selected: [profile.breed], multiSelect: false)
        sizeFlow.setTags(DogSize.allCases.map(\.rawValue), selected: [profile.size.rawValue], multiSelect: false)
        personalityFlow.setTags(DogWalkingStore.personalities, selected: Set(profile.personality), multiSelect: true)
        matchResults = DogWalkingStore.matchBuddies(query: profile)
        reloadResults()
    }

    @objc private func tapFindMatches() {
        view.endEditing(true)
        guard let profile = buildProfile() else {
            Toast.show("Please select breed, size, and at least one personality tag.", in: view)
            return
        }
        DogWalkingStore.saveCurrentUserDogProfile(profile)
        matchResults = DogWalkingStore.matchBuddies(query: profile)
        reloadResults()
        if matchResults.isEmpty {
            Toast.show("No similar buddies found — try adjusting your tags.", in: view)
        }
    }

    private func buildProfile() -> DogProfile? {
        guard let breed = breedFlow.selectedTitles.first,
              let sizeRaw = sizeFlow.selectedTitles.first,
              let size = DogSize(rawValue: sizeRaw) else { return nil }
        let traits = personalityFlow.selectedTitles
        guard !traits.isEmpty else { return nil }
        let name = (dogNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return DogProfile(
            dogName: name.isEmpty ? "My Dog" : name,
            breed: breed,
            size: size,
            personality: Array(traits.prefix(3)))
    }

    private func reloadResults() {
        resultsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyView.isHidden = !matchResults.isEmpty

        for result in matchResults {
            resultsStack.addArrangedSubview(makeResultCard(result))
        }
    }

    private func makeResultCard(_ result: DogMatchResult) -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.card
        card.layer.cornerRadius = 28.dp

        let avatar = CircleImageView(asset: result.avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: 96.dp).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 96.dp).isActive = true

        let name = UILabel()
        name.text = result.userName
        name.font = DesignTokens.Font.bold(32)
        name.textColor = DesignTokens.Color.textPrimary

        let dogLine = UILabel()
        dogLine.text = "\(result.dog.dogName) · \(result.dog.breed) · \(result.dog.size.rawValue)"
        dogLine.font = DesignTokens.Font.regular(26)
        dogLine.textColor = DesignTokens.Color.textMuted
        dogLine.numberOfLines = 0

        let traits = UILabel()
        traits.text = result.dog.personality.joined(separator: " · ")
        traits.font = DesignTokens.Font.medium(24)
        traits.textColor = DesignTokens.Color.textPrimary
        traits.numberOfLines = 0

        let badge = UILabel()
        badge.text = "\(result.matchPercent)% match"
        badge.font = DesignTokens.Font.bold(26)
        badge.textColor = DesignTokens.Color.textPrimary
        badge.backgroundColor = DesignTokens.Color.accentYellow
        badge.textAlignment = .center
        badge.layer.cornerRadius = 20.dp
        badge.layer.masksToBounds = true

        let matched = UILabel()
        matched.text = "Matched: \(result.matchedTraits.joined(separator: ", "))"
        matched.font = DesignTokens.Font.regular(24)
        matched.textColor = DesignTokens.Color.textMuted
        matched.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [name, dogLine, traits, matched])
        textStack.axis = .vertical
        textStack.spacing = 6.dp

        let top = UIStackView(arrangedSubviews: [avatar, textStack, badge])
        top.axis = .horizontal
        top.alignment = .top
        top.spacing = 16.dp
        top.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(top)

        let tap = UITapGestureRecognizer(target: self, action: #selector(openProfile(_:)))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        card.tag = result.userId.hashValue
        objc_setAssociatedObject(card, &AssociatedKeys.userId, result.userId, .OBJC_ASSOCIATION_COPY_NONATOMIC)

        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 140.dp),
            badge.heightAnchor.constraint(equalToConstant: 48.dp),
            top.topAnchor.constraint(equalTo: card.topAnchor, constant: 24.dp),
            top.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24.dp),
            top.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24.dp),
            top.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24.dp),
        ])
        return card
    }

    @objc private func openProfile(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view,
              let userId = objc_getAssociatedObject(card, &AssociatedKeys.userId) as? String,
              let user = DemoContent.user(id: userId) else { return }
        navigationController?.pushViewController(UserProfileViewController(user: user), animated: true)
    }
}

private enum AssociatedKeys {
    static var userId = "dogMatch.userId"
}
