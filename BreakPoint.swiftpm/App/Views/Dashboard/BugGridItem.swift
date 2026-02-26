import SwiftUI

struct BugGridItem: View {
    let bug: Bug
    let namespace: Namespace.ID
    
    @State private var isHovering = false
    @State private var floatOffset: CGFloat = 0.0
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon Container
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .shadow(color: bug.color.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: bug.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(bug.color)
            }
            .scaleEffect(isHovering ? 1.1 : 1.0)
            .animation(AnimationSystem.springSnappy, value: isHovering)
            
            VStack(spacing: 8) {
                Text("Interactive Story")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(.bugWarm)
                    .padding(.top, 8)
                
                Text(bug.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(bug.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 40)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glassPanel()
        .matchedGeometryEffect(id: bug.id, in: namespace)
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(AnimationSystem.springSnappy, value: isHovering)
        // Apply interactive scale to the whole card
        // Note: The tap gesture is handled by the parent, but we can add the press effect here
        // or rely on ButtonStyle if it was a button. Since it's a View with onTapGesture,
        // we can use a custom configuration.
        // For now, let's just stick to the hover scaling and let DashboardView handle the tap.
        .offset(y: floatOffset)
        .onHover { hover in
            withAnimation(AnimationSystem.springSnappy) {
                isHovering = hover
            }
        }
        .onAppear {
            // Idle floating animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                floatOffset = 5.0
            }
        }
    }
}

#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            BugGridItem(bug: Bug(
                type: .infiniteLoop,
                name: "Infinite Loop",
                description: "A loop that never exits.",
                iconName: "arrow.triangle.2.circlepath"
            ), namespace: namespace)
            .padding()
        }
    }
}
