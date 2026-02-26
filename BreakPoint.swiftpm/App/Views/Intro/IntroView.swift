import SwiftUI

struct IntroView: View {
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Entry Animation
    @State private var titleOpacity: Double = 1
    @State private var titleOffset: CGFloat = 0
    @State private var taglineOpacity: Double = 1
    @State private var taglineOffset: CGFloat = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.95

    // MARK: - Screen entrance / exit
    @State private var screenOpacity: Double = 0
    @State private var screenScale: CGFloat = 0.96
    @State private var screenOffset: CGFloat = 0

    // MARK: - Progress + Auto-Advance
    @State private var progressValue: Double = 0
    @State private var autoTask: Task<Void, Never>? = nil
    @State private var didAdvance = false

    private let autoDelay: Double = 5.0

    var body: some View {
        ZStack {
            // MARK: Background
            BlobBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                // MARK: Title
                Text("Breakpoint")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .primary,
                                .primary.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                // MARK: Tagline
                Text("Where Code Thinks Out Loud")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.7))
                    .tracking(0.5)
                    .padding(.top, 14)
                    .opacity(taglineOpacity)
                    .offset(y: taglineOffset)

                // MARK: Progress Bar (auto-advance hint)
                ProgressBar(value: progressValue)
                    .frame(width: 56, height: 3)
                    .padding(.top, 20)
                    .opacity(taglineOpacity) // fades in with tagline
                
                Spacer(minLength: 40)

                // MARK: Continue Button
                Button(action: advance) {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "5B7FE8"), Color(hex: "7B5EA7")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            // Glow layer
                            Capsule()
                                .fill(Color(hex: "5B7FE8").opacity(0.45))
                                .blur(radius: 10)
                                .offset(y: 6)
                        }
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "5B7FE8").opacity(0.4), radius: 18, x: 0, y: 8)
                }
                .buttonStyle(IntroButtonStyle())
                .opacity(buttonOpacity)
                .scaleEffect(buttonScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: buttonScale)
                .padding(.horizontal, 40)
                .padding(.bottom, 64)
            }
        }
        // Screen-level fade-in + scale-in (removes the hard "cut")
        .opacity(screenOpacity)
        .scaleEffect(screenScale)
        .offset(y: screenOffset)
        .onAppear {
            runEntryAnimation()
        }
        .onDisappear {
            autoTask?.cancel()
        }
    }

    // MARK: - Entry Animation
    func runEntryAnimation() {
        // 0. Screen fades in + scales up
        withAnimation(.easeOut(duration: 0.5)) {
            screenOpacity = 1
        }
        withAnimation(.spring(response: 0.65, dampingFraction: 0.82)) {
            screenScale = 1.0
        }

        // 1. Button — fades in with screen
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.2)) {
            buttonOpacity = 1
            buttonScale   = 1
        }

        // Progress bar fills over the 5s hold period
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.linear(duration: autoDelay - 0.65)) {
                progressValue = 1
            }
        }

        // Auto-advance task
        autoTask = Task {
            try? await Task.sleep(for: .seconds(autoDelay))
            guard !Task.isCancelled else { return }
            await MainActor.run { advance() }
        }
    }

    // MARK: - Advance (shared by button tap + auto-timer)
    func advance() {
        guard !didAdvance else { return }
        didAdvance = true
        autoTask?.cancel()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Simpler, faster exit that relies on the global .move transition
        withAnimation(.easeIn(duration: 0.15)) {
            screenOpacity = 0.6
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.advanceFlow()
        }
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    var value: Double    // 0–1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 3)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "5B7FE8"), Color(hex: "7B5EA7")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * value, height: 3)
            }
        }
    }
}

// MARK: - Button Style
struct IntroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Backwards compat alias (used in other files if any)
typealias EnhancedScaleButtonStyle = IntroButtonStyle

#Preview {
    IntroView(viewModel: AppViewModel())
}
