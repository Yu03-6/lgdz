import UIKit

/// Shared spring / cross-fade animations for follow and like toggles.
enum InteractionAnimation {

    static func bounce(_ view: UIView, peakScale: CGFloat = 1.12) {
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.9,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { view.transform = CGAffineTransform(scaleX: peakScale, y: peakScale) },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.32,
                    delay: 0,
                    usingSpringWithDamping: 0.62,
                    initialSpringVelocity: 0.4,
                    options: [.allowUserInteraction, .beginFromCurrentState],
                    animations: { view.transform = .identity })
            })
    }

    static func pillToggle(on view: UIView, haptic: Bool = true, updates: @escaping () -> Void) {
        UIView.transition(
            with: view,
            duration: 0.26,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: updates)
        bounce(view, peakScale: 1.1)
        if haptic { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }

    static func likeToggle(on icon: UIView, label: UIView? = nil, liked: Bool, updates: @escaping () -> Void) {
        if liked {
            UIView.animate(
                withDuration: 0.1,
                animations: { icon.transform = CGAffineTransform(scaleX: 0.15, y: 0.15) },
                completion: { _ in
                    updates()
                    icon.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
                    UIView.animate(
                        withDuration: 0.48,
                        delay: 0,
                        usingSpringWithDamping: 0.42,
                        initialSpringVelocity: 1.2,
                        options: [.allowUserInteraction],
                        animations: { icon.transform = .identity })
                })
            if let label {
                UIView.animate(withDuration: 0.16, animations: {
                    label.transform = CGAffineTransform(translationX: 0, y: -3)
                        .scaledBy(x: 1.14, y: 1.14)
                }, completion: { _ in
                    UIView.animate(
                        withDuration: 0.28,
                        delay: 0,
                        usingSpringWithDamping: 0.72,
                        initialSpringVelocity: 0.3,
                        animations: { label.transform = .identity })
                })
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            UIView.animate(
                withDuration: 0.12,
                animations: { icon.transform = CGAffineTransform(scaleX: 1.28, y: 1.28) },
                completion: { _ in
                    UIView.transition(
                        with: icon,
                        duration: 0.2,
                        options: [.transitionCrossDissolve, .allowUserInteraction],
                        animations: updates)
                    UIView.animate(
                        withDuration: 0.34,
                        delay: 0,
                        usingSpringWithDamping: 0.68,
                        initialSpringVelocity: 0.5,
                        options: [.allowUserInteraction],
                        animations: { icon.transform = .identity })
                })
        }
    }
}
