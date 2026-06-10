import PhotosUI
import UIKit

/// Screen 14 — Posting updates. Title + content + album photo picker +
/// Add Address. Posting costs 29 coins (screen 15 unlock popup → screen 16
/// success).
final class PublishViewController: UIViewController {

    private let titleField = UITextField()
    private let contentView = UITextView()
    private let contentPlaceholder = UILabel()
    private let mediaRow = UIStackView()
    private var pickedPhotos: [UIImage] = []
    private let postCost = 29
    private let maxPhotos = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func build() {
        let margin = 32.dp
        let header = NavHeader(title: "Posting updates") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let titleLabel = sectionLabel("Title")
        view.addSubview(titleLabel)

        let titleBox = UIView()
        titleBox.backgroundColor = DesignTokens.Color.fieldFill
        titleBox.layer.cornerRadius = 28.dp
        titleBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleBox)
        titleField.placeholder = "Give your post a name."
        titleField.font = DesignTokens.Font.regular(30)
        titleField.textColor = DesignTokens.Color.textPrimary
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleBox.addSubview(titleField)

        let contentLabel = sectionLabel("Content")
        view.addSubview(contentLabel)

        let contentBox = UIView()
        contentBox.backgroundColor = DesignTokens.Color.fieldFill
        contentBox.layer.cornerRadius = 28.dp
        contentBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentBox)

        contentView.backgroundColor = .clear
        contentView.font = DesignTokens.Font.regular(30)
        contentView.textColor = DesignTokens.Color.textPrimary
        contentView.textContainerInset = UIEdgeInsets(top: 28.dp, left: 28.dp, bottom: 28.dp, right: 28.dp)
        contentView.delegate = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentBox.addSubview(contentView)
        contentPlaceholder.text = "Share your daily life with your dog~"
        contentPlaceholder.font = DesignTokens.Font.regular(30)
        contentPlaceholder.textColor = DesignTokens.Color.textMuted
        contentPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        contentBox.addSubview(contentPlaceholder)

        mediaRow.axis = .horizontal
        mediaRow.spacing = 24.dp
        mediaRow.alignment = .center
        mediaRow.translatesAutoresizingMaskIntoConstraints = false
        contentBox.addSubview(mediaRow)
        rebuildMedia()

        let addr = makeAddressRow()
        contentBox.addSubview(addr)

        let post = PillButton(style: .primary, title: "Post")
        post.designCornerRadius = 36
        post.addTarget(self, action: #selector(tapPost), for: .touchUpInside)
        post.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(post)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            titleLabel.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 40.dp),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            titleBox.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.dp),
            titleBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            titleBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            titleBox.heightAnchor.constraint(equalToConstant: 118.dp),
            titleField.leadingAnchor.constraint(equalTo: titleBox.leadingAnchor, constant: 36.dp),
            titleField.trailingAnchor.constraint(equalTo: titleBox.trailingAnchor, constant: -36.dp),
            titleField.centerYAnchor.constraint(equalTo: titleBox.centerYAnchor),

            contentLabel.topAnchor.constraint(equalTo: titleBox.bottomAnchor, constant: 40.dp),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            contentBox.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24.dp),
            contentBox.leadingAnchor.constraint(equalTo: titleBox.leadingAnchor),
            contentBox.trailingAnchor.constraint(equalTo: titleBox.trailingAnchor),
            contentBox.heightAnchor.constraint(equalToConstant: 620.dp),

            contentView.topAnchor.constraint(equalTo: contentBox.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentBox.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 280.dp),
            contentPlaceholder.topAnchor.constraint(equalTo: contentBox.topAnchor, constant: 30.dp),
            contentPlaceholder.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor, constant: 32.dp),

            mediaRow.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor, constant: 32.dp),
            mediaRow.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10.dp),

            addr.leadingAnchor.constraint(equalTo: contentBox.leadingAnchor, constant: 32.dp),
            addr.trailingAnchor.constraint(equalTo: contentBox.trailingAnchor, constant: -32.dp),
            addr.topAnchor.constraint(equalTo: mediaRow.bottomAnchor, constant: 36.dp),

            post.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            post.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            post.heightAnchor.constraint(equalToConstant: 120.dp),
            post.topAnchor.constraint(equalTo: contentBox.bottomAnchor, constant: 60.dp),
        ])
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = DesignTokens.Font.bold(34)
        l.textColor = DesignTokens.Color.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func rebuildMedia() {
        mediaRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let tile: CGFloat = 180.dp
        for (index, image) in pickedPhotos.enumerated() {
            let wrap = UIView()
            wrap.translatesAutoresizingMaskIntoConstraints = false
            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 20.dp
            iv.translatesAutoresizingMaskIntoConstraints = false
            wrap.addSubview(iv)

            let del = UIButton(type: .custom)
            del.setImage(
                UIImage(named: "publish_delete_photo")?.withRenderingMode(.alwaysOriginal),
                for: .normal)
            del.imageView?.contentMode = .scaleAspectFit
            del.tag = index
            del.addTarget(self, action: #selector(removeMedia(_:)), for: .touchUpInside)
            del.translatesAutoresizingMaskIntoConstraints = false
            wrap.addSubview(del)

            NSLayoutConstraint.activate([
                wrap.widthAnchor.constraint(equalToConstant: tile),
                wrap.heightAnchor.constraint(equalToConstant: tile),
                iv.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8.dp),
                iv.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
                iv.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -8.dp),
                iv.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
                del.topAnchor.constraint(equalTo: wrap.topAnchor),
                del.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
                del.widthAnchor.constraint(equalToConstant: 48.dp),
                del.heightAnchor.constraint(equalToConstant: 48.dp),
            ])
            mediaRow.addArrangedSubview(wrap)
        }

        guard pickedPhotos.count < maxPhotos else { return }

        let add = UIButton(type: .custom)
        add.setImage(
            UIImage(named: "publish_pick_photo")?.withRenderingMode(.alwaysOriginal),
            for: .normal)
        add.imageView?.contentMode = .scaleAspectFit
        add.addTarget(self, action: #selector(addMedia), for: .touchUpInside)
        add.translatesAutoresizingMaskIntoConstraints = false
        add.widthAnchor.constraint(equalToConstant: tile).isActive = true
        add.heightAnchor.constraint(equalToConstant: tile).isActive = true
        mediaRow.addArrangedSubview(add)
    }

    private func makeAddressRow() -> UIView {
        let row = UIControl()
        row.translatesAutoresizingMaskIntoConstraints = false
        let pin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        pin.tintColor = DesignTokens.Color.accent
        pin.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(pin)
        let label = UILabel()
        label.text = "Add Address"
        label.font = DesignTokens.Font.bold(32)
        label.textColor = DesignTokens.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = DesignTokens.Color.textMuted
        chevron.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(chevron)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 60.dp),
            pin.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            pin.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            pin.widthAnchor.constraint(equalToConstant: 48.dp),
            pin.heightAnchor.constraint(equalToConstant: 48.dp),
            label.leadingAnchor.constraint(equalTo: pin.trailingAnchor, constant: 16.dp),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    @objc private func addMedia() {
        view.endEditing(true)
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = maxPhotos - pickedPhotos.count
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func removeMedia(_ sender: UIButton) {
        let index = sender.tag
        guard pickedPhotos.indices.contains(index) else { return }
        pickedPhotos.remove(at: index)
        rebuildMedia()
    }

    @objc private func tapPost() {
        view.endEditing(true)
        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let content = (contentView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            Toast.show("Please enter a title", in: view)
            return
        }
        guard !content.isEmpty else {
            Toast.show("Please enter content", in: view)
            return
        }
        guard AppSession.shared.canAfford(postCost) else {
            showInsufficientBalance()
            return
        }
        let popup = ReminderPopupController(
            title: "Unlock Release",
            bodyParts: [("This feature requires ", false), ("\(postCost)", true), (" coins to unlock.", false)],
            buttonTitle: "Unlock",
            secondaryTitle: "Close",
            onSecondary: nil,
            onConfirm: { [weak self] in self?.confirmPost() })
        popup.present(over: self)
    }

    private func showInsufficientBalance() {
        let insufficient = ReminderPopupController(
            title: "Not enough coins",
            bodyParts: [("Posting needs ", false), ("\(postCost)", true), (" coins. Please top up.", false)],
            buttonTitle: "Recharge",
            onConfirm: { [weak self] in
                self?.navigationController?.pushViewController(RechargeViewController(), animated: true)
            })
        insufficient.present(over: self)
    }

    private func confirmPost() {
        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let content = (contentView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !content.isEmpty, AppSession.shared.canAfford(postCost) else { return }
        if AppSession.shared.spend(postCost) {
            DemoContent.addUserPost(title: title, content: content, photo: pickedPhotos.first)
            let success = ReminderPopupController(
                title: "Posted!",
                bodyParts: [("Your update is live. ", false), ("-\(postCost)", true), (" coins.", false)],
                buttonTitle: "OK",
                onConfirm: { [weak self] in self?.navigationController?.popViewController(animated: true) })
            success.present(over: self)
        } else {
            showInsufficientBalance()
        }
    }
}

extension PublishViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        let group = DispatchGroup()
        var loaded = [UIImage?](repeating: nil, count: results.count)
        for (index, result) in results.enumerated() {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                defer { group.leave() }
                if let image = object as? UIImage {
                    loaded[index] = image
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            let images = loaded.compactMap { $0 }
            guard !images.isEmpty else { return }
            let remaining = self.maxPhotos - self.pickedPhotos.count
            self.pickedPhotos.append(contentsOf: images.prefix(remaining))
            self.rebuildMedia()
        }
    }
}

extension PublishViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder.isHidden = !textView.text.isEmpty
    }
}
