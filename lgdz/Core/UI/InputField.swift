import UIKit

/// A labeled rounded input used across login/register/forms.
/// Mirrors the design: dark-green bold label above a white rounded field with
/// muted placeholder, optional password visibility toggle.
final class InputField: UIView {

    let textField = UITextField()
    private let label = UILabel()
    private let box = UIView()
    private var eyeButton: UIButton?

    var text: String { textField.text ?? "" }

    /// - Parameters:
    ///   - title: label text above the field
    ///   - placeholder: muted placeholder
    ///   - secure: render as password field with eye toggle
    init(title: String, placeholder: String, secure: Bool = false) {
        super.init(frame: .zero)
        buildLabel(title)
        buildBox(placeholder: placeholder, secure: secure)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildLabel(_ title: String) {
        label.text = title
        label.font = DesignTokens.Font.bold(30)
        label.textColor = DesignTokens.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func buildBox(placeholder: String, secure: Bool) {
        box.backgroundColor = DesignTokens.Color.fieldFill
        box.layer.cornerRadius = 28.dp
        box.translatesAutoresizingMaskIntoConstraints = false
        addSubview(box)

        textField.font = DesignTokens.Font.regular(30)
        textField.textColor = DesignTokens.Color.textPrimary
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: DesignTokens.Color.textMuted,
                         .font: DesignTokens.Font.regular(30)])
        textField.isSecureTextEntry = secure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(textField)

        let trailing: CGFloat
        if secure {
            let eye = UIButton(type: .system)
            let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34))
            eye.setImage(UIImage(systemName: "eye.slash", withConfiguration: cfg), for: .normal)
            eye.tintColor = DesignTokens.Color.textMuted
            eye.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
            eye.translatesAutoresizingMaskIntoConstraints = false
            box.addSubview(eye)
            eyeButton = eye
            NSLayoutConstraint.activate([
                eye.centerYAnchor.constraint(equalTo: box.centerYAnchor),
                eye.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -40.dp),
                eye.widthAnchor.constraint(equalToConstant: 50.dp),
            ])
            trailing = -90.dp
        } else {
            trailing = -40.dp
        }

        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 28.dp),
            box.leadingAnchor.constraint(equalTo: leadingAnchor),
            box.trailingAnchor.constraint(equalTo: trailingAnchor),
            box.heightAnchor.constraint(equalToConstant: 118.dp),
            box.bottomAnchor.constraint(equalTo: bottomAnchor),

            textField.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 40.dp),
            textField.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: trailing),
            textField.centerYAnchor.constraint(equalTo: box.centerYAnchor),
        ])
    }

    @objc private func toggleSecure() {
        textField.isSecureTextEntry.toggle()
        let name = textField.isSecureTextEntry ? "eye.slash" : "eye"
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(34))
        eyeButton?.setImage(UIImage(systemName: name, withConfiguration: cfg), for: .normal)
    }
}
