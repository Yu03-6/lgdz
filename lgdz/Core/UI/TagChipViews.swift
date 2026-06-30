import UIKit

/// Selectable tag chip used on dog-matching screens.
final class TagChipButton: UIButton {
    var isChipSelected = false {
        didSet { applyStyle() }
    }
    /// When false, selection is managed by the parent (single-select groups).
    var allowsToggle = true

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = DesignTokens.Font.semibold(26)
        contentEdgeInsets = UIEdgeInsets(top: 12.dp, left: 24.dp, bottom: 12.dp, right: 24.dp)
        addTarget(self, action: #selector(tap), for: .touchUpInside)
        applyStyle()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func tap() {
        if allowsToggle { isChipSelected.toggle() }
    }

    private func applyStyle() {
        if isChipSelected {
            backgroundColor = DesignTokens.Color.accent
            setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
            layer.borderWidth = 0
        } else {
            backgroundColor = DesignTokens.Color.card
            setTitleColor(DesignTokens.Color.textPrimary, for: .normal)
            layer.borderWidth = 2.dp
            layer.borderColor = DesignTokens.Color.separator.cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}

/// Flow-layout container for tag chips.
final class TagFlowView: UIView {
    private var chips: [TagChipButton] = []
    private let hSpacing: CGFloat
    private let vSpacing: CGFloat

    init(horizontalSpacing: CGFloat = 16, verticalSpacing: CGFloat = 16) {
        hSpacing = horizontalSpacing.dp
        vSpacing = verticalSpacing.dp
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTags(_ titles: [String], selected: Set<String> = [], multiSelect: Bool = true) {
        chips.forEach { $0.removeFromSuperview() }
        chips = titles.map { title in
            let chip = TagChipButton(title: title)
            chip.isChipSelected = selected.contains(title)
            chip.allowsToggle = multiSelect
            if !multiSelect {
                chip.addAction(UIAction { [weak self, weak chip] _ in
                    guard let self, let chip else { return }
                    self.selectSingle(chip)
                }, for: .touchUpInside)
            }
            addSubview(chip)
            return chip
        }
        setNeedsLayout()
    }

    var selectedTitles: [String] {
        chips.filter(\.isChipSelected).compactMap { $0.title(for: .normal) }
    }

    func selectSingle(_ selected: TagChipButton) {
        for chip in chips {
            chip.isChipSelected = (chip === selected)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = bounds.width

        for chip in chips {
            let size = chip.intrinsicContentSize
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + vSpacing
                rowHeight = 0
            }
            chip.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            x += size.width + hSpacing
            rowHeight = max(rowHeight, size.height)
        }
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let height = chips.map { $0.frame.maxY }.max() ?? 0
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}
