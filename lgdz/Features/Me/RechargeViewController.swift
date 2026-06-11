import UIKit

/// Screen 28 — Recharge. Balance card + 3+3+1 package grid (tap to buy).
/// Purchases use real StoreKit 2 consumable IAP.
final class RechargeViewController: UIViewController {

    private struct Package {
        let productID: String
        let coins: Int
        var price: String
    }
    private var packages: [Package] = IAPProductCatalog.rechargeGridProducts.map {
        Package(productID: $0.id, coins: $0.coins, price: $0.fallbackPrice)
    }
    private var selected = 0
    private var tiles: [UIControl] = []

    /// Design-canvas spacing from `充值.png`.
    private enum Layout {
        static let balanceToChoose: CGFloat = 68
        static let chooseToGrid: CGFloat = 28
        static let gridRowSpacing: CGFloat = 24
        /// Matches the original 2×3 grid row height: (580 - 24) / 2.
        static let tileRowHeight: CGFloat = 278
        static let gridToFooter: CGFloat = 40
    }
    private weak var balanceLabel: UILabel?
    private var isPurchasing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        build()
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshBalance),
            name: .walletBalanceDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
        refreshBalance()
        Task { await refreshStorePrices() }
    }

    @objc private func refreshBalance() {
        balanceLabel?.text = "\(AppSession.shared.coins)"
    }

    private func refreshStorePrices() async {
        await StoreKitManager.shared.loadProducts()
        packages = packages.map {
            Package(
                productID: $0.productID,
                coins: $0.coins,
                price: StoreKitManager.shared.displayPrice(forProductID: $0.productID))
        }
        updatePackageLabels()
    }

    private func updatePackageLabels() {
        for (index, tile) in tiles.enumerated() where index < packages.count {
            updatePriceLabel(in: tile, price: packages[index].price)
            updateCoinsLabel(in: tile, coins: packages[index].coins)
        }
    }

    private func updateCoinsLabel(in control: UIControl, coins: Int) {
        for subview in control.subviews {
            if let label = subview as? UILabel, !(subview is PaddingTag) {
                label.text = "\(coins)"
            }
        }
    }

    private func updatePriceLabel(in control: UIControl, price: String) {
        for subview in control.subviews {
            if let tag = subview as? PaddingTag {
                tag.text = price
            }
        }
    }

    private func build() {
        let margin = 32.dp
        let header = NavHeader(title: nil) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let balance = makeBalanceCard()
        view.addSubview(balance)

        let choose = UILabel()
        choose.text = "Choose a package"
        choose.font = DesignTokens.Font.bold(44)
        choose.textColor = DesignTokens.Color.textPrimary
        choose.translatesAutoresizingMaskIntoConstraints = false

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = Layout.gridRowSpacing.dp
        grid.distribution = .fill
        grid.translatesAutoresizingMaskIntoConstraints = false

        let packageSection = UIStackView(arrangedSubviews: [choose, grid])
        packageSection.axis = .vertical
        packageSection.spacing = Layout.chooseToGrid.dp
        packageSection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(packageSection)

        var rowConstraints: [NSLayoutConstraint] = []
        var tileIndex = 0
        for productIDs in IAPProductCatalog.rechargeGridRows {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 24.dp
            row.distribution = .fillEqually
            rowConstraints.append(
                row.heightAnchor.constraint(equalToConstant: Layout.tileRowHeight.dp))

            for productID in productIDs {
                guard tileIndex < packages.count else { break }
                let tile = makeTile(packages[tileIndex], index: tileIndex)
                tiles.append(tile)
                row.addArrangedSubview(tile)
                tileIndex += 1
            }

            if productIDs.count == 1 {
                row.addArrangedSubview(UIView())
                row.addArrangedSubview(UIView())
            }

            grid.addArrangedSubview(row)
        }
        updateSelection()

        let footer = UILabel()
        footer.text = "*Use coins to unlock posting features\nand chat with AI*"
        footer.numberOfLines = 2
        footer.textAlignment = .center
        footer.font = DesignTokens.Font.regular(26)
        footer.textColor = DesignTokens.Color.textMuted
        footer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footer)

        NSLayoutConstraint.activate(rowConstraints + [
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            balance.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20.dp),
            balance.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            balance.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            balance.heightAnchor.constraint(equalToConstant: 200.dp),

            packageSection.topAnchor.constraint(
                equalTo: balance.bottomAnchor, constant: Layout.balanceToChoose.dp),
            packageSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            packageSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            footer.topAnchor.constraint(
                equalTo: packageSection.bottomAnchor, constant: Layout.gridToFooter.dp),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: margin),
            footer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -margin),
            footer.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30.dp),
        ])
    }

    private func makeBalanceCard() -> UIView {
        let card = UIView()
        card.backgroundColor = DesignTokens.Color.textPrimary
        card.layer.cornerRadius = 36.dp
        card.translatesAutoresizingMaskIntoConstraints = false
        let coin = UIImageView(image: UIImage(named: "coin"))
        coin.contentMode = .scaleAspectFit
        coin.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(coin)
        let amount = UILabel()
        amount.text = "\(AppSession.shared.coins)"
        amount.font = DesignTokens.Font.bold(48)
        amount.textColor = .white
        amount.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(amount)
        balanceLabel = amount
        let label = UILabel()
        label.text = "Balance"
        label.font = DesignTokens.Font.medium(32)
        label.textColor = UIColor(white: 1, alpha: 0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        NSLayoutConstraint.activate([
            coin.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 40.dp),
            coin.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            coin.widthAnchor.constraint(equalToConstant: 100.dp),
            coin.heightAnchor.constraint(equalToConstant: 100.dp),
            amount.leadingAnchor.constraint(equalTo: coin.trailingAnchor, constant: 30.dp),
            amount.topAnchor.constraint(equalTo: card.topAnchor, constant: 50.dp),
            label.leadingAnchor.constraint(equalTo: amount.leadingAnchor),
            label.topAnchor.constraint(equalTo: amount.bottomAnchor, constant: 6.dp),
        ])
        return card
    }

    private func makeTile(_ p: Package, index: Int) -> UIControl {
        let tile = UIControl()
        tile.tag = index
        tile.layer.cornerRadius = 28.dp
        tile.layer.borderWidth = 3

        let coin = UIImageView(image: UIImage(named: "coin"))
        coin.contentMode = .scaleAspectFit
        coin.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(coin)
        let coins = UILabel()
        coins.text = "\(p.coins)"
        coins.font = DesignTokens.Font.bold(40)
        coins.textColor = DesignTokens.Color.textPrimary
        coins.textAlignment = .center
        coins.adjustsFontSizeToFitWidth = true
        coins.minimumScaleFactor = 0.5
        coins.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(coins)
        let price = PaddingTag(horizontalInsetDesign: 10)
        price.text = p.price
        price.font = DesignTokens.Font.semibold(26)
        price.textColor = DesignTokens.Color.textPrimary
        price.backgroundColor = DesignTokens.Color.accent
        price.textAlignment = .center
        price.lineBreakMode = .byClipping
        price.adjustsFontSizeToFitWidth = true
        price.minimumScaleFactor = 0.75
        price.setContentHuggingPriority(.required, for: .horizontal)
        price.setContentCompressionResistancePriority(.required, for: .horizontal)
        price.layer.cornerRadius = 26.dp
        price.layer.masksToBounds = true
        price.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(price)
        NSLayoutConstraint.activate([
            coin.topAnchor.constraint(equalTo: tile.topAnchor, constant: 28.dp),
            coin.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            coin.widthAnchor.constraint(equalToConstant: 90.dp),
            coin.heightAnchor.constraint(equalToConstant: 90.dp),
            coins.topAnchor.constraint(equalTo: coin.bottomAnchor, constant: 14.dp),
            coins.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            coins.leadingAnchor.constraint(greaterThanOrEqualTo: tile.leadingAnchor, constant: 8.dp),
            coins.trailingAnchor.constraint(lessThanOrEqualTo: tile.trailingAnchor, constant: -8.dp),
            price.topAnchor.constraint(equalTo: coins.bottomAnchor, constant: 14.dp),
            price.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            price.leadingAnchor.constraint(greaterThanOrEqualTo: tile.leadingAnchor, constant: 8.dp),
            price.trailingAnchor.constraint(lessThanOrEqualTo: tile.trailingAnchor, constant: -8.dp),
            price.heightAnchor.constraint(equalToConstant: 52.dp),
            price.bottomAnchor.constraint(lessThanOrEqualTo: tile.bottomAnchor, constant: -28.dp),
        ])
        tile.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.selected = index
            self.updateSelection()
            self.purchase(self.packages[index])
        }, for: .touchUpInside)
        return tile
    }

    private func updateSelection() {
        for t in tiles {
            let on = t.tag == selected
            t.backgroundColor = on ? .white : DesignTokens.Color.secondaryFill
            t.layer.borderColor = on ? DesignTokens.Color.accent.cgColor : UIColor.clear.cgColor
        }
    }

    private func purchase(_ package: Package) {
        guard !isPurchasing else { return }

        isPurchasing = true
        view.isUserInteractionEnabled = false
        Task { @MainActor in
            defer {
                isPurchasing = false
                view.isUserInteractionEnabled = true
            }
            do {
                let coins = try await StoreKitManager.shared.purchase(productID: package.productID)
                refreshBalance()
                Toast.show("Recharged \(coins) coins!", in: view)
            } catch StoreKitManager.PurchaseError.userCancelled {
                // System purchase sheet dismissed by user.
            } catch {
                let message = error.localizedDescription
                if !message.isEmpty {
                    Toast.show(message, in: view)
                }
            }
        }
    }
}
