import SwiftUI

struct BlobBackground: View {
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base Gradient
            LinearGradient(
                colors: [.backgroundGradientStart, .backgroundGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Starfield (Dark Mode only)
            Starfield()
            
            // Blob 1 (Purple/Lavender)
            Circle()
                .fill(
                    Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark
                            ? .systemPurple
                            : UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
                    }).opacity(0.35)
                )
                .frame(width: 350, height: 350)
                .blur(radius: 70)
                .offset(x: animate ? -120 : 120, y: animate ? -60 : 60)
                .blendMode(colorScheme == .dark ? .screen : .normal)
                .animation(
                    .easeInOut(duration: 12).repeatForever(autoreverses: true),
                    value: animate
                )
            
            // Blob 2 (Blue)
            Circle()
                .fill(
                    Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark
                            ? .systemBlue
                            : UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
                    }).opacity(0.25)
                )
                .frame(width: 450, height: 450)
                .blur(radius: 80)
                .offset(x: animate ? 180 : -80, y: animate ? 120 : -120)
                .blendMode(colorScheme == .dark ? .screen : .normal)
                .animation(
                    .easeInOut(duration: 14).repeatForever(autoreverses: true),
                    value: animate
                )
            
            // Blob 3 (Soft Teal)
            Circle()
                .fill(Color.fixCool.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: animate ? -80 : 220, y: animate ? 220 : -80)
                .blendMode(colorScheme == .dark ? .screen : .normal)
                .animation(
                    .easeInOut(duration: 18).repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    BlobBackground()
}
