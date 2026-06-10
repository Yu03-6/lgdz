import UIKit

/// Live-room like burst: a stream of hearts floating upward from the heart button.
final class LiveHeartBurstView: UIView {

    private static let heartColors: [UIColor] = [
        UIColor(hex: 0xFF4D6D),
        UIColor(hex: 0xFF6B8A),
        DesignTokens.Color.danger,
        UIColor(hex: 0xFF85A1),
        UIColor(hex: 0xFF3366),
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Emits a staggered chain of hearts rising from `point` (in this view's coordinates).
    func burst(from point: CGPoint, count: Int = 9) {
        for i in 0..<count {
            let delay = Double(i) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.spawnHeart(near: point)
            }
        }
    }

    private func spawnHeart(near origin: CGPoint) {
        let size = CGFloat.random(in: 34...54).dp
        let startX = origin.x + CGFloat.random(in: -18...18).dp
        let startY = origin.y + CGFloat.random(in: -10...10).dp

        let cfg = UIImage.SymbolConfiguration(pointSize: size, weight: .bold)
        let heart = UIImageView(image: UIImage(systemName: "heart.fill", withConfiguration: cfg))
        heart.tintColor = Self.heartColors.randomElement()
        heart.contentMode = .scaleAspectFit
        heart.frame = CGRect(x: startX - size / 2, y: startY - size / 2, width: size, height: size)
        heart.alpha = 0
        heart.transform = CGAffineTransform(scaleX: 0.35, y: 0.35)
        addSubview(heart)

        let driftX = CGFloat.random(in: -56...56).dp
        let riseY = CGFloat.random(in: 240...420).dp
        let rotation = CGFloat.random(in: -0.55...0.55)
        let duration = Double.random(in: 1.15...1.75)

        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
            heart.alpha = 1
            heart.transform = CGAffineTransform(rotationAngle: rotation * 0.3).scaledBy(x: 1, y: 1)
        }

        UIView.animate(
            withDuration: duration,
            delay: 0.05,
            options: [.curveEaseOut],
            animations: {
                heart.center = CGPoint(x: startX + driftX, y: startY - riseY)
                heart.transform = CGAffineTransform(rotationAngle: rotation).scaledBy(x: 1.18, y: 1.18)
                heart.alpha = 0
            },
            completion: { _ in
                heart.removeFromSuperview()
            })
    }
}
