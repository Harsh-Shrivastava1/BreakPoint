import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel
    let namespace: Namespace.ID

    @State private var showInfo = false

    // Strict 2-column equal-width grid with uniform 16pt gutter
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack(alignment: .top) {

            // MARK: — Static Background
            // Subtle top-to-bottom gradient; no movement
            LinearGradient(
                colors: [
                    .backgroundGradientStart,
                    .backgroundGradientEnd
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // MARK: — Scroll Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Swift Bug Worlds")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                            .tracking(-0.3)

                        Text("Learn by seeing bugs in action.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 74)           // more room for dynamic islands
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)

                    // ── Featured World ────────────────────────────────
                    if let featured = viewModel.bugs.first(where: { $0.type == .infiniteLoop }) {
                        FeaturedCard(
                            bug: featured,
                            namespace: namespace,
                            onTap: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.selectBug(featured)
                            }
                        )
                        .padding(.horizontal, 40)
                    }

                    // ── Section Label ─────────────────────────────────
                    Text("LIBRARY")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2.2)
                        .foregroundColor(.secondary.opacity(0.55))
                        .padding(.horizontal, 42)
                        .padding(.top, 30)
                        .padding(.bottom, 12)

                    // ── Library Grid ──────────────────────────────────
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.bugs.filter { $0.type != .infiniteLoop }) { bug in
                            LibraryCard(
                                bug: bug,
                                namespace: namespace,
                                onTap: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    viewModel.selectBug(bug)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }

            // MARK: — Floating Nav Bar (back + info)
            HStack {
                // Back button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.65))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
                        )
                }
                .padding(.leading, 40)

                Spacer()

                // Info button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(AnimationSystem.springSmooth) { showInfo = true }
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue.opacity(0.8))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
                        )
                }
                .padding(.trailing, 40)
            }
            .padding(.top, 20)
        }
        // MARK: — Info Sheet
        .fullScreenCover(isPresented: $showInfo) {
            AppInfoSheet(isPresented: $showInfo)
        }
    }
}

// MARK: - Featured Card (Hero)
struct FeaturedCard: View {
    let bug: Bug
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { isPressed = false }
                onTap()
            }
        }) {
            ZStack(alignment: .bottomLeading) {

                // Very subtle blue radial behind icon area
                RadialGradient(
                    colors: [Color.blue.opacity(0.06), Color.clear],
                    center: .trailing,
                    startRadius: 0,
                    endRadius: 180
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                HStack(alignment: .center, spacing: 0) {
                    // Text block
                    VStack(alignment: .leading, spacing: 10) {
                        // FEATURED tag
                        Text("FEATURED")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.8)
                            .foregroundColor(.blue.opacity(0.65))

                        // Title
                        Text(bug.name)
                            .font(.system(size: 26, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                            .tracking(-0.2)

                        // Descriptor
                        Text("Code that never stops.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Icon (static — no animation)
                    Image(systemName: bug.iconName)
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), Color(uiColor: .systemIndigo).opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 30)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 168)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.07), radius: 24, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Color.glassBorder, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isPressed)
        }
        .buttonStyle(.plain)
        .matchedGeometryEffect(id: bug.id, in: namespace)
    }
}

// MARK: - Library Card
struct LibraryCard: View {
    let bug: Bug
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var isPressed = false

    private var iconBGColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.05)
                : UIColor(hex: "EEF2FB")
        })
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { isPressed = false }
                onTap()
            }
        }) {
            VStack(spacing: 0) {

                // Icon container — perfectly centered
                ZStack {
                    Circle()
                        .fill(iconBGColor)
                        .frame(width: 52, height: 52)

                    Image(systemName: bug.iconName)
                        .font(.system(size: 23, weight: .medium))
                        .foregroundColor(.blue.opacity(0.75))
                }
                .padding(.top, 22)

                Spacer()

                // Text block — baseline-consistent
                VStack(spacing: 5) {
                    Text(bug.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.88)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(shortDescription)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
            .frame(height: 148)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.055), radius: 16, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.glassBorder, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isPressed)
        }
        .buttonStyle(.plain)
        .matchedGeometryEffect(id: bug.id, in: namespace)
    }

    private var shortDescription: String {
        switch bug.type {
        case .infiniteLoop:   return "Never stops"
        case .optionalNil:    return "Nothing exists"
        case .stateMismatch:  return "UI disconnected"
        case .retainCycle:    return "Memory trap"
        case .raceCondition:  return "Timing clash"
        case .offByOne:       return "Almost right"
        case .deadlock:       return "Forever stuck"
        case .logicError:     return "Wrong math"
        case .missingValue:   return "Data is missing"
        }
    }
}

// MARK: - App Info Sheet
struct AppInfoSheet: View {
    @Binding var isPresented: Bool
    @State private var headerVisible   = false
    @State private var step1Visible    = false
    @State private var step2Visible    = false
    @State private var step3Visible    = false
    @State private var step4Visible    = false
    @State private var buttonVisible   = false

    var body: some View {
        ZStack {
            // ── Background ──────────────────────────────────────────
            AboutBackground()


            // ── Content ─────────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Hero Header ───────────────────────────────────
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About BreakPoint")
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(.primary)
                                .tracking(-0.8)

                            Text("Learn Swift bugs the visual way —\nby watching them happen.")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundColor(.secondary.opacity(0.8))
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: 340, alignment: .leading)
                        }
                    }

                    .padding(.top, 64)
                    .padding(.horizontal, 20)
                    .opacity(headerVisible ? 1 : 0)
                    .offset(y: headerVisible ? 0 : 16)

                    // ── Content Blocks ────────────────────────────────
                    VStack(alignment: .leading, spacing: 20) {
                        InfoNarrativeBlock(
                            icon: "map.fill",
                            accentColor: .blue,
                            title: "Pick a Bug World",
                            description: "Choose from 9 classic Swift bug categories — Infinite Loops, Race Conditions, Deadlocks, and more. Each world isolates a single real-world mistake.",
                            visible: step1Visible
                        )

                        InfoNarrativeBlock(
                            icon: "play.circle.fill",
                            accentColor: .purple,
                            title: "Watch It Unfold",
                            description: "An interactive simulation plays the bug out in real time. See exactly what broken code does — and why — through live animation and visual feedback.",
                            visible: step2Visible
                        )

                        InfoNarrativeBlock(
                            icon: "hammer.fill",
                            accentColor: .orange,
                            title: "Apply the Fix",
                            description: "Tap to apply the correct solution and watch the behavior change instantly. Each fix reinforces the right mental model for that bug type.",
                            visible: step3Visible
                        )

                        InfoNarrativeBlock(
                            icon: "lightbulb.fill",
                            accentColor: .successGreen,
                            title: "Build Real Intuition",
                            description: "Visual memory of bugs and their fixes sticks far better than reading docs alone. Each session leaves a clear mental picture you can rely on.",
                            visible: step4Visible
                        )
                    }

                    .padding(.horizontal, 20)
                    .padding(.top, 40)

                    // ── Footer Note ───────────────────────────────────
                    Text("No internet required · Swift Playgrounds native · Made for curious developers")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                        .opacity(buttonVisible ? 1 : 0)

                    // ── Dismiss Button ────────────────────────────────
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(AnimationSystem.springSmooth) { isPresented = false }
                    }) {
                        Text("Got it")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.15, green: 0.45, blue: 0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 52)
                    .opacity(buttonVisible ? 1 : 0)
                    .offset(y: buttonVisible ? 0 : 10)
                }
            }

            // ── NavBar / Close Button ───────────────────────────────
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(AnimationSystem.springSmooth) { isPresented = false }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.8))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial.opacity(0.85))
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1))  { headerVisible = true }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.25)) { step1Visible  = true }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.35)) { step2Visible  = true }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.45)) { step3Visible  = true }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.55)) { step4Visible  = true }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.70)) { buttonVisible = true }
    }

}

// MARK: - Info Narrative Block (Soft Card)
private struct InfoNarrativeBlock: View {
    let icon: String
    let accentColor: Color
    let title: String
    let description: String
    let visible: Bool

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack(alignment: .top, spacing: 18) {
                // Animated Icon with Glow
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                        .scaleEffect(visible ? 1 : 0.5)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(accentColor)
                        .shadow(color: accentColor.opacity(0.4), radius: 8)
                }
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .tracking(-0.3)

                    Text(description)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.85))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.3), .clear, accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 30)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: visible)
    }
}

// Simple button style to track press state
struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Animated Background
private struct AboutBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.adaptiveBackground
                .ignoresSafeArea()
            
            // Dynamic Interactive Blobs
            GeometryReader { geo in
                ZStack {
                    // Core Glow
                    Circle()
                        .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 450, height: 450)
                        .blur(radius: 100)
                        .offset(x: animate ? 120 : -80, y: animate ? -250 : -100)
                    
                    Circle()
                        .fill(LinearGradient(colors: [.orange.opacity(0.2), .red.opacity(0.1)], startPoint: .bottomTrailing, endPoint: .topLeading))
                        .frame(width: 400, height: 400)
                        .blur(radius: 90)
                        .offset(x: animate ? -180 : 120, y: animate ? 150 : 250)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: animate ? 60 : -100, y: animate ? 350 : 100)
                }
                .scaleEffect(animate ? 1.1 : 0.9)
            }
            .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animate)
            
            // Noise / Grain Texture for 'Premium' feel
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Color.black.opacity(0.02)
                        .blendMode(.overlay)
                )
                .ignoresSafeArea()
        }
        .onAppear { animate = true }
    }
}

// MARK: - Blur Helper
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}


// MARK: - Preview
#Preview {
    DashboardPreviewWrapper()
}

struct DashboardPreviewWrapper: View {
    @Namespace var namespace

    var body: some View {
        DashboardView(viewModel: AppViewModel(), namespace: namespace)
    }
}
