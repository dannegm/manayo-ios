import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    public let name: String
    public let loopMode: LottieLoopMode

    public init(name: String, loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
    }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor),
            animationView.heightAnchor.constraint(lessThanOrEqualTo: container.heightAnchor),
        ])

        animationView.play()

        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // nada que actualizar por ahora
    }
}
