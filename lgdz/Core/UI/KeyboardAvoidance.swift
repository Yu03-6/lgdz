import UIKit

/// Shared keyboard frame helpers (screen → host view coordinates).
enum KeyboardMetrics {

    /// Height of the keyboard overlapping `hostView` (0 when dismissed).
    static func overlap(in hostView: UIView, keyboardEndFrame: CGRect) -> CGFloat {
        let frameInView = hostView.convert(keyboardEndFrame, from: nil)
        return max(0, hostView.bounds.height - frameInView.origin.y)
    }

    static func animate(
        with note: Notification,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let curve = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 7
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: animations,
            completion: completion)
    }
}

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
        let overlap = KeyboardMetrics.overlap(in: hostView, keyboardEndFrame: frame)
        bottomConstraint.constant = overlap > 0
            ? -(overlap - hostView.safeAreaInsets.bottom) + restingConstant
            : restingConstant
        KeyboardMetrics.animate(with: note) {
            hostView.layoutIfNeeded()
        }
        onChange?()
    }
}

/// Scrollable form keyboard avoidance: grows bottom inset and scrolls the focused field into view.
final class KeyboardFormAvoidance {

    private weak var scrollView: UIScrollView?
    private weak var hostView: UIView?
    private var baseBottomInset: CGFloat = 0
    private var actionButtons: [UIView] = []
    private var savedScrollEnabled: Bool?
    private var observer: NSObjectProtocol?
    private var fieldFocusObserver: NSObjectProtocol?
    private var textViewFocusObserver: NSObjectProtocol?

    func attach(
        scrollView: UIScrollView,
        hostView: UIView,
        baseBottomInset: CGFloat,
        actionButtons: [UIView] = []
    ) {
        self.scrollView = scrollView
        self.hostView = hostView
        self.baseBottomInset = baseBottomInset
        self.actionButtons = actionButtons
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
        fieldFocusObserver = NotificationCenter.default.addObserver(
            forName: UITextField.textDidBeginEditingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scrollVisibleFormContentIfKeyboardVisible()
        }
        textViewFocusObserver = NotificationCenter.default.addObserver(
            forName: UITextView.textDidBeginEditingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scrollVisibleFormContentIfKeyboardVisible()
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
        if let fieldFocusObserver { NotificationCenter.default.removeObserver(fieldFocusObserver) }
        if let textViewFocusObserver { NotificationCenter.default.removeObserver(textViewFocusObserver) }
    }

    private func handleKeyboard(_ note: Notification) {
        guard let scrollView, let hostView,
              let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = KeyboardMetrics.overlap(in: hostView, keyboardEndFrame: frame)
        let inset = overlap > 0 ? overlap + baseBottomInset : 0

        if overlap > 0 {
            if savedScrollEnabled == nil { savedScrollEnabled = scrollView.isScrollEnabled }
            scrollView.isScrollEnabled = true
        } else if let savedScrollEnabled {
            scrollView.isScrollEnabled = savedScrollEnabled
            self.savedScrollEnabled = nil
        }

        KeyboardMetrics.animate(with: note, animations: {
            scrollView.contentInset.bottom = inset
            scrollView.verticalScrollIndicatorInsets.bottom = inset
        }, completion: { _ in
            if overlap > 0 { self.scrollVisibleFormContent() }
        })
    }

    private func scrollVisibleFormContent() {
        guard let scrollView else { return }
        var target: CGRect?

        if let responder = findFirstResponder(in: scrollView) {
            var rect = responder.convert(responder.bounds, to: scrollView)
            rect = rect.insetBy(dx: 0, dy: -32.dp)
            target = rect
        }

        for button in actionButtons where button.window != nil {
            var rect = button.convert(button.bounds, to: scrollView)
            rect = rect.insetBy(dx: 0, dy: -20.dp)
            target = target.map { $0.union(rect) } ?? rect
        }

        guard let target else { return }
        scrollView.scrollRectToVisible(target, animated: true)
    }

    private func scrollVisibleFormContentIfKeyboardVisible() {
        guard let scrollView, scrollView.contentInset.bottom > 0 else { return }
        DispatchQueue.main.async { [weak self] in
            self?.scrollVisibleFormContent()
        }
    }

    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for subview in view.subviews {
            if let found = findFirstResponder(in: subview) { return found }
        }
        return nil
    }
}

/// Shifts a fixed form container upward so focused fields and action buttons stay above the keyboard.
final class KeyboardShiftAvoidance {

    private weak var hostView: UIView?
    private weak var contentView: UIView?
    private var actionButtons: [UIView] = []
    private var currentOverlap: CGFloat = 0
    private var observer: NSObjectProtocol?
    private var fieldFocusObserver: NSObjectProtocol?
    private var textViewFocusObserver: NSObjectProtocol?

    func attach(hostView: UIView, contentView: UIView, actionButtons: [UIView] = []) {
        self.hostView = hostView
        self.contentView = contentView
        self.actionButtons = actionButtons
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
        fieldFocusObserver = NotificationCenter.default.addObserver(
            forName: UITextField.textDidBeginEditingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reapplyShift(animated: true)
        }
        textViewFocusObserver = NotificationCenter.default.addObserver(
            forName: UITextView.textDidBeginEditingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reapplyShift(animated: true)
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
        if let fieldFocusObserver { NotificationCenter.default.removeObserver(fieldFocusObserver) }
        if let textViewFocusObserver { NotificationCenter.default.removeObserver(textViewFocusObserver) }
    }

    private func handleKeyboard(_ note: Notification) {
        guard let hostView,
              let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        currentOverlap = KeyboardMetrics.overlap(in: hostView, keyboardEndFrame: frame)
        let shift = currentOverlap > 0 ? computeShift(overlap: currentOverlap) : 0
        KeyboardMetrics.animate(with: note) {
            self.contentView?.transform = shift > 0
                ? CGAffineTransform(translationX: 0, y: -shift)
                : .identity
        }
    }

    private func reapplyShift(animated: Bool) {
        guard currentOverlap > 0, let contentView else { return }
        let shift = computeShift(overlap: currentOverlap)
        let updates = {
            contentView.transform = shift > 0
                ? CGAffineTransform(translationX: 0, y: -shift)
                : .identity
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: updates)
        } else {
            updates()
        }
    }

    private func computeShift(overlap: CGFloat) -> CGFloat {
        guard let hostView, let contentView, overlap > 0 else { return 0 }
        var bottomY: CGFloat = 0

        if let responder = findFirstResponder(in: contentView) {
            let frame = responder.convert(responder.bounds, to: hostView)
            bottomY = max(bottomY, frame.maxY + 20.dp)
        }
        for button in actionButtons where button.window != nil {
            let frame = button.convert(button.bounds, to: hostView)
            bottomY = max(bottomY, frame.maxY + 20.dp)
        }

        let visibleBottom = hostView.bounds.height - overlap - 12.dp
        return max(0, bottomY - visibleBottom)
    }

    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for subview in view.subviews {
            if let found = findFirstResponder(in: subview) { return found }
        }
        return nil
    }
}

/// Tap outside inputs to dismiss the keyboard without blocking control taps.
enum KeyboardDismiss {
    static func installTapToDismiss(on view: UIView, target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

/// Shifts a centered modal container upward when the keyboard would cover it.
final class KeyboardPopupAvoidance {

    private weak var hostView: UIView?
    private weak var containerView: UIView?
    private var observer: NSObjectProtocol?

    func attach(hostView: UIView, containerView: UIView) {
        self.hostView = hostView
        self.containerView = containerView
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
        guard let hostView, let containerView,
              let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = KeyboardMetrics.overlap(in: hostView, keyboardEndFrame: frame)
        let shift = overlap > 0 ? min(overlap * 0.42, 220.dp) : 0
        KeyboardMetrics.animate(with: note) {
            containerView.transform = shift > 0
                ? CGAffineTransform(translationX: 0, y: -shift)
                : .identity
        }
    }
}
