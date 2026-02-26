import SwiftUI

struct AnimationSystem {
    // MARK: - Springs
    // Bouncy: Use for emphasizing arrival or selection
    static let springBounce = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
    
    // Smooth: Use for transitions, moves, and UI flows
    static let springSmooth = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    
    // Snappy: Use for quick feedback (like toggle switches or small interactions)
    static let springSnappy = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    
    // MARK: - Eases
    // Standard ease for opacity/colors
    static let easeStandard = Animation.easeInOut(duration: 0.3)
    
    // Ease out for entering elements
    static let easeOut = Animation.easeOut(duration: 0.3)
}

// MARK: - Interaction Modifiers

struct InteractiveScaleModifier: ViewModifier {
    let scaleAmount: CGFloat
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scaleAmount : 1.0)
            .animation(AnimationSystem.springSnappy, value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

extension View {
    func interactiveScale(amount: CGFloat = 0.95) -> some View {
        self.modifier(InteractiveScaleModifier(scaleAmount: amount))
    }
}
