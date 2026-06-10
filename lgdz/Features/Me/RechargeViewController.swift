import UIKit

/// Screen 28 — Recharge. Balance card + 2×3 package grid (tap to buy) +
/// 3 bottom button cards. Wallet is a local demo (§6: StoreKit not wired).
final class RechargeViewController: UIViewController {

    private struct Package { let coins: Int; let price: String }
    private let packages = Array(repeating: Package(coins: 1000, price: "$0.99"), count: 6)
    private let bottomPackages: [Package] = [
        Package(coins: 500, price: "$0.49"),
        Package(coins: 1000, price: "$0.99"),
        Package(coins: 2000, price: "$1.99"),
    ]
    private var selected = 0
    private var tiles: [UIControl] = []
    private weak var balanceLabel: UILabel?

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
    }

    @objc private func refreshBalance() {
        balanceLabel?.text = "\(AppSession.shared.coins)"
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
        view.addSubview(choose)

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 24.dp
        grid.distribution = .fillEqually
        grid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grid)
        var i = 0
        while i < packages.count {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 24.dp
            row.distribution = .fillEqually
            for j in i..<min(i + 3, packages.count) {
                let tile = makeTile(packages[j], index: j)
                tiles.append(tile)
                row.addArrangedSubview(tile)
            }
            grid.addArrangedSubview(row)
            i += 3
        }
        updateSelection()

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 24.dp
        bottomRow.distribution = .fillEqually
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomRow)
        for (index, package) in bottomPackages.enumerated() {
            let card = makeButtonCard(package, index: index)
            bottomRow.addArrangedSubview(card)
        }

        let footer = UILabel()
        footer.text = "*Use coins to unlock posting features\nand chat with AI*"
        footer.numberOfLines = 2
        footer.textAlignment = .center
        footer.font = DesignTokens.Font.regular(26)
        footer.textColor = DesignTokens.Color.textMuted
        footer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footer)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            balance.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20.dp),
            balance.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            balance.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            balance.heightAnchor.constraint(equalToConstant: 200.dp),

            choose.topAnchor.constraint(equalTo: balance.bottomAnchor, constant: 40.dp),
            choose.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            grid.topAnchor.constraint(equalTo: choose.bottomAnchor, constant: 28.dp),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            grid.heightAnchor.constraint(equalToConstant: 580.dp),

            bottomRow.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 28.dp),
            bottomRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            bottomRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            bottomRow.heightAnchor.constraint(equalToConstant: 200.dp),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30.dp),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomRow.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -30.dp),
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
        coins.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(coins)
        let price = PaddingTag()
        price.text = p.price
        price.font = DesignTokens.Font.semibold(26)
        price.textColor = DesignTokens.Color.textPrimary
        price.backgroundColor = DesignTokens.Color.accent
        price.textAlignment = .center
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
            price.topAnchor.constraint(equalTo: coins.bottomAnchor, constant: 14.dp),
            price.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            price.heightAnchor.constraint(equalToConstant: 52.dp),
        ])
        tile.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.selected = index
            self.updateSelection()
            self.purchase(self.packages[index])
        }, for: .touchUpInside)
        return tile
    }

    private func makeButtonCard(_ package: Package, index: Int) -> UIControl {
        let card = UIControl()
        card.tag = index
        card.backgroundColor = DesignTokens.Color.secondaryFill
        card.layer.cornerRadius = 28.dp
        card.layer.borderWidth = 3
        card.layer.borderColor = UIColor.clear.cgColor

        let coin = UIImageView(image: UIImage(named: "coin"))
        coin.contentMode = .scaleAspectFit
        coin.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(coin)

        let coins = UILabel()
        coins.text = "\(package.coins)"
        coins.font = DesignTokens.Font.bold(36)
        coins.textColor = DesignTokens.Color.textPrimary
        coins.textAlignment = .center
        coins.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(coins)

        let price = PaddingTag()
        price.text = package.price
        price.font = DesignTokens.Font.semibold(24)
        price.textColor = DesignTokens.Color.textPrimary
        price.backgroundColor = DesignTokens.Color.accent
        price.textAlignment = .center
        price.layer.cornerRadius = 22.dp
        price.layer.masksToBounds = true
        price.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(price)

        NSLayoutConstraint.activate([
            coin.topAnchor.constraint(equalTo: card.topAnchor, constant: 24.dp),
            coin.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            coin.widthAnchor.constraint(equalToConstant: 72.dp),
            coin.heightAnchor.constraint(equalToConstant: 72.dp),
            coins.topAnchor.constraint(equalTo: coin.bottomAnchor, constant: 10.dp),
            coins.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            price.topAnchor.constraint(equalTo: coins.bottomAnchor, constant: 10.dp),
            price.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            price.heightAnchor.constraint(equalToConstant: 44.dp),
        ])

        card.addAction(UIAction { [weak self] _ in
            self?.purchase(package)
        }, for: .touchUpInside)
        return card
    }

    private func updateSelection() {
        for t in tiles {
            let on = t.tag == selected
            t.backgroundColor = on ? .white : DesignTokens.Color.secondaryFill
            t.layer.borderColor = on ? DesignTokens.Color.accent.cgColor : UIColor.clear.cgColor
        }
    }

    private func purchase(_ package: Package) {
        AppSession.shared.topUp(package.coins)
        Toast.show("Recharged \(package.coins) coins!", in: view)
        navigationController?.popViewController(animated: true)
    }
}
