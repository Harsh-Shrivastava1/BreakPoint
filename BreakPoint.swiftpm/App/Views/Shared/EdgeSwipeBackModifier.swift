import SwiftUI
import UIKit

// MARK: - EdgeSwipeBack ViewModifier
// Attaches a UIScreenEdgePanGestureRecognizer to the hosting UIView so that
// a left-edge swipe fires the provided action — giving native iOS "swipe back"
// feel even when the app uses a ZStack-based navigation (no NavigationStack).

struct EdgeSwipeBackModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.background(
            EdgeSwipeGestureView(action: action)
        )
    }
}

// MARK: - UIViewRepresentable bridge
private struct EdgeSwipeGestureView: UIViewRepresentable {
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        let recognizer = UIScreenEdgePanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleEdgePan(_:))
        )
        recognizer.edges = .left
        view.addGestureRecognizer(recognizer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the coordinator's action in case it changed
        context.coordinator.action = action
    }

    // MARK: - Coordinator
    class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func handleEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
            guard let view = recognizer.view else { return }

            switch recognizer.state {
            case .ended, .cancelled:
                let translation = recognizer.translation(in: view).x
                let velocity    = recognizer.velocity(in: view).x
                // Fire if dragged far enough OR flicked fast enough
                if translation > 60 || velocity > 300 {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    action()
                }
            default:
                break
            }
        }
    }
}

// MARK: - Convenience extension
extension View {
    /// Enables a native-feeling left-edge swipe-back gesture that calls `action`.
    func edgeSwipeBack(action: @escaping () -> Void) -> some View {
        modifier(EdgeSwipeBackModifier(action: action))
    }
}
