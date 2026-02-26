import SwiftUI

struct GlassCloseButton: View {
    let action: () -> Void
    
    // Internal state for pressing animation
    @State private var isPressing = false
    
    var body: some View {
        Button(action: {
            // Light impact feedback on tap
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            ZStack {
                // Background: Ultra thin material
                Circle()
                    .fill(.ultraThinMaterial)
                
                // Border: White with 0.2 opacity
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                
                // Icon: 14pt semibold
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            // Frame: 36x36
            .frame(width: 36, height: 36)
            // Shadow: Black with 0.08 opacity, soft blur
            .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)
            // Tap Animation: Scale and Opacity
            .scaleEffect(isPressing ? 0.92 : 1.0)
            .opacity(isPressing ? 0.8 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        // Gesture to handle press state for manual animation control
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isPressing = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isPressing = false
                    }
                }
        )
        // Ensure it's fully visible inside the screen (clear of corners/notches)
        .padding(.top, 56)
        .padding(.leading, 24)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        GlassCloseButton(action: {})
    }
}
