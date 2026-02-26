import SwiftUI

// MARK: - Glassmorphism

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 24 // Increased for modern look
    
    func body(content: Content) -> some View {
        content
            .background(.regularMaterial) // Slightly thicker material for light mode
            .background(Color.glassBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5) // Soft subtle shadow
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - System Status Text Style

struct SystemStatusTextStyle: ViewModifier {
    var isWarning: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded)) // Rounded for friendlier feel
            .foregroundColor(isWarning ? .bugWarm : .fixCool)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func systemStatus(isWarning: Bool = false) -> some View {
        self.modifier(SystemStatusTextStyle(isWarning: isWarning))
    }
}
