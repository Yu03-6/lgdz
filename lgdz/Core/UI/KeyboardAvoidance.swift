import UIKit

/// Pins a bottom bar above the system keyboard by adjusting a bottom constraint.
final class KeyboardBottomBarAvoidance {

    var onChange: (() -> Void)?

    private weak var hostView: UIView?
    private weak var bottomConstraint: NSLayoutConstraint?
    private var restingConstant: CGFloat = 0
    private var observer: NSObjectProtocol?

    func start(hostView: UIView, bottomConstraint: NSLayoutConstraint, restingConstant: CGFloat) {
        self.hostView = hostView
        self.bottomConstraint = bottomConstraint
        self.restingConstant = restingConstant
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }

    private func handleKeyboard(_ note: Notification) {
        guard let hostView, let bottomConstraint,
              let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = max(0, hostView.bounds.height - frame.origin.y)
        bottomConstraint.constant = overlap > 0
            ? -(overlap + abs(restingConstant) - hostView.safeAreaInsets.bottom)
            : restingConstant
        animateLayout(note, in: hostView)
        onChange?()
    }
}

/// Scrollable form keyboard avoidance: grows bottom inset and scrolls the focused field into view.
final class KeyboardFormAvoidance {

    private weak var scrollView: UIScrollView?
    private weak var hostView: UIView?
    private var baseBottomInset: CGFloat = 0
    private var observer: NSObjectProtocol?

    func attach(scrollView: UIScrollView, hostView: UIView, baseBottomInset: CGFloat) {
        self.scrollView = scrollView
        self.hostView = hostView
        self.baseBottomInset = baseBottomInset
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }

    private func handleKeyboard(_ note: Notification) {
        guard let scrollView, let hostView,
              let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardFrame = hostView.convert(frame, from: nil)
        let overlap = max(0, hostView.bounds.height - keyboardFrame.origin.y)
        let inset = overlap > 0 ? overlap + baseBottomInset : 0

        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let curve = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 7
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) {
            scrollView.contentInset.bottom = inset
            scrollView.verticalScrollIndicatorInsets.bottom = inset
        } completion: { _ in
            if overlap > 0 { self.scrollToFirstResponder() }
        }
    }

    private func scrollToFirstResponder() {
        guard let scrollView, let responder = findFirstResponder(in: scrollView) else { return }
        var rect = responder.convert(responder.bounds, to: scrollView)
        rect = rect.insetBy(dx: 0, dy: -24.dp)
        scrollView.scrollRectToVisible(rect, animated: true)
    }

    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for subview in view.subviews {
            if let found = findFirstResponder(in: subview) { return found }
        }
        return nil
    }
}

// MARK: - Shared animation helper

private func animateLayout(_ note: Notification, in view: UIView) {
    let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
    let curve = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 7
    UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) {
        view.layoutIfNeeded()
    }
}
