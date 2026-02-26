import SwiftUI

// MARK: - Animation Phases
// 0: idle — single "Decision Point" card visible
// 1: card appears (scale + opacity)
// 2: split into two cards (wrong / correct)
// 3: dot moves to wrong card
// 4: wrong card shakes + strong orange
// 5: merge back to single card
// 6: "Fixing logic…" title
// 7: split again
// 8: dot moves to correct card
// 9: correct card glows green — success
// 10: "Logic Fixed" — button active

struct LogicErrorWorld: View {
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Phase
    @State private var phase: Int = 0
    @State private var showDialog: Bool = false

    // MARK: - Card Layout States
    @State private var cardOpacity: Double = 0
    @State private var cardScale: CGFloat = 0.95
    @State private var isSplit: Bool = false          // drives horizontal layout
    @State private var splitProgress: CGFloat = 0     // 0 = merged, 1 = fully split

    // MARK: - Card Appearance
    @State private var wrongCardStrength: Double = 0   // 0 = normal, 1 = strong orange
    @State private var wrongCardShakeX: CGFloat = 0
    @State private var correctCardScale: CGFloat = 1.0
    @State private var correctGlowRadius: CGFloat = 0

    // MARK: - Dot States
    @State private var dotVisible: Bool = false
    @State private var dotX: CGFloat = 0              // relative offset from center
    @State private var dotY: CGFloat = -60            // starts above cards
    @State private var dotColor: Color = .blue

    // MARK: - Labels
    @State private var resultLabel: String = ""
    @State private var resultLabelVisible: Bool = false
    @State private var titleText: String = "Valid code. Wrong logic."
    @State private var subtitleText: String = "The program runs — but gives the wrong result."

    // MARK: - Geometry
    private let cardHeight: CGFloat = 220
    private let cardCornerRadius: CGFloat = 24
    private let splitSpacing: CGFloat = 16
    private let dotSize: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let screenW = geo.size.width
            let cardW = screenW * 0.8
            let halfCard = (cardW - splitSpacing) / 2

            ZStack(alignment: .topLeading) {
            // MARK: 1. Background
            RadialGradient(
                colors: [Color.loopBgCenter, Color.loopBgEdge], // Premium background
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                   // MARK: Header
                    VStack(spacing: 8) {
                        Text(titleText)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.4), value: titleText)

                        Text(subtitleText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                            .animation(.easeInOut(duration: 0.4), value: subtitleText)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)

                    Spacer()

                    // MARK: Decision Animation Area
                    ZStack {

                        // ── SINGLE / MERGED CARD ──────────────────────────
                        if !isSplit {
                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cardCornerRadius)
                                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                .frame(width: cardW, height: cardHeight)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "arrow.triangle.branch")
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text("Decision Point")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                )
                                .scaleEffect(cardScale)
                                .opacity(cardOpacity)
                                .transition(.scale(scale: 0.95).combined(with: .opacity))
                        }

                        // ── SPLIT CARDS ───────────────────────────────────
                        if isSplit {
                            HStack(spacing: splitSpacing) {

                                // LEFT — Wrong Logic
                                ZStack {
                                    RoundedRectangle(cornerRadius: cardCornerRadius)
                                        .fill(
                                            Color.orange.opacity(0.12 + wrongCardStrength * 0.28)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                                .strokeBorder(
                                                    Color.orange.opacity(0.3 + wrongCardStrength * 0.5),
                                                    lineWidth: 1.5
                                                )
                                        )

                                    VStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.orange)
                                        Text("Wrong Logic")
                                            .font(.headline)
                                            .foregroundColor(.orange)
                                    }
                                }
                                .frame(width: halfCard, height: cardHeight)
                                .offset(x: wrongCardShakeX)

                                // RIGHT — Correct Logic
                                ZStack {
                                    RoundedRectangle(cornerRadius: cardCornerRadius)
                                        .fill(Color.green.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: cardCornerRadius)
                                                .strokeBorder(Color.green.opacity(0.3), lineWidth: 1.5)
                                        )
                                        .shadow(
                                            color: Color.green.opacity(correctGlowRadius > 0 ? 0.55 : 0),
                                            radius: correctGlowRadius,
                                            x: 0, y: 0
                                        )

                                    VStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.green)
                                        Text("Correct Logic")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                }
                                .frame(width: halfCard, height: cardHeight)
                                .scaleEffect(correctCardScale)
                            }
                            .frame(width: cardW)
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                        }

                        // ── EXECUTION DOT ─────────────────────────────────
                        if dotVisible {
                            Circle()
                                .fill(dotColor)
                                .frame(width: dotSize, height: dotSize)
                                .shadow(color: dotColor.opacity(0.6), radius: 6)
                                .offset(x: dotX, y: dotY)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8),
                                    value: dotX
                                )
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8),
                                    value: dotY
                                )
                        }

                        // ── RESULT LABEL ──────────────────────────────────
                        if resultLabelVisible {
                            Text(resultLabel)
                                .font(.subheadline.bold())
                                .foregroundColor(resultLabel == "Wrong Result" ? .orange : .green)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            (resultLabel == "Wrong Result"
                                                ? Color.orange
                                                : Color.green
                                            ).opacity(0.15)
                                        )
                                )
                                .offset(y: cardHeight / 2 + 24)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }
                    }
                    .frame(width: cardW)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)

                    Spacer()

                    // MARK: Action Button
                    Button(action: handleButtonTap) {
                        Text(phase >= 10 ? "Continue" : "Correct Logic")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 260, height: 52)
                            .background(
                                Capsule()
                                    .fill(buttonGradient(phase: phase))
                            )
                            .shadow(
                                color: (phase >= 10 ? Color.green : Color.blue).opacity(0.35),
                                radius: 10,
                                y: 4
                            )
                            .scaleEffect(phase >= 10 ? 1.05 : 1.0)
                    }
                    .disabled(phase < 4 || (phase > 4 && phase < 10))
                    .opacity(phase >= 4 ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.4), value: phase)
                    .padding(.top, 32)
                    .padding(.bottom, 28)
            }
            .blur(radius: showDialog ? 10 : 0)
            
            // MARK: 5. Educational Dialog Overlay
              if showDialog {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showDialog = false } }
                        .zIndex(1)

                    VStack {
                        Spacer()
                        
                        VStack(spacing: 24) {
                            Text("REFLECTION")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(2)

                            Text("Logic errors don't crash — they mislead.")
                                .font(.system(size: 20, weight: .medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Text("\"Like a calculator using the wrong formula.\"")
                                .font(.system(size: 16, design: .serif))
                                .italic()
                                .foregroundColor(.primary.opacity(0.8))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.blue.opacity(0.08))
                                )

                            Text("Clear logic creates correct outcomes.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                withAnimation { showDialog = false }
                                viewModel.clearSelection()
                            }) {
                                Text("Continue Exploring")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(16)
                            }
                            .padding(.top, 8)
                        }
                        .padding(32)
                        .padding(.bottom, 8) // Slight breathing space inside card
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(.regularMaterial)
                        )
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: 15) // Bias slightly downwards
                    .transition(.scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 25)))
                    .zIndex(2)
                }
            }
        }
        .onAppear {
            runAnimationSequence()
        }
    }

    // MARK: - Button Gradient
    func buttonGradient(phase: Int) -> LinearGradient {
        phase >= 10
            ? LinearGradient(colors: [.green, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
            : LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
    }

    // MARK: - Button Handler
    func handleButtonTap() {
        if phase >= 10 {
            withAnimation { showDialog = true }
        } else {
            // "Correct Logic" tapped at phase == 4 — run the fix flow
            runFixFlow()
        }
    }

    // MARK: - Animation Sequence

    func runAnimationSequence() {
        // STEP 1 — Card appears
        phase = 1
        delay(0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardOpacity = 1
                cardScale = 1.0
            }
        }

        // STEP 2 — Split into two cards
        delay(0.7) {
            phase = 2
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isSplit = true
            }
            // Dot appears above center
            dotVisible = true
            dotX = 0
            dotY = -60
            dotColor = .blue
        }

        // STEP 3 — Dot moves to wrong (left) card
        delay(1.5) {
            phase = 3
            dotColor = .orange
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                dotX = -80   // approximate center of left card
                dotY = 0
            }
        }

        // STEP 4 — Wrong card shakes + highlights
        delay(2.5) {
            phase = 4
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                wrongCardStrength = 1.0
            }
            shakeCard()

            // Show "Wrong Result" label
            delay(0.3) {
                resultLabel = "Wrong Result"
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    resultLabelVisible = true
                }
            }

            // Haptic
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    func runFixFlow() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // STEP 5 — Merge back
        phase = 5
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            resultLabelVisible = false
            isSplit = false
            wrongCardStrength = 0
            dotVisible = false
        }

        // STEP 6 — Title changes to "Fixing logic..."
        delay(0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                titleText = "Fixing logic..."
                subtitleText = "Applying the correct decision path."
            }
        }

        // STEP 7 — Split again
        delay(0.9) {
            phase = 7
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isSplit = true
            }
            // Dot resets above center
            dotVisible = true
            dotX = 0
            dotY = -60
            dotColor = .blue
        }

        // STEP 8 — Dot moves to correct (right) card
        delay(1.7) {
            phase = 8
            dotColor = .green
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                dotX = 80    // approximate center of right card
                dotY = 0
            }
        }

        // STEP 9 — Success feedback on right card
        delay(2.7) {
            phase = 9
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                correctCardScale = 1.05
                correctGlowRadius = 18
            }

            // Show "Correct Result" label
            delay(0.3) {
                resultLabel = "Correct Result"
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    resultLabelVisible = true
                }
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        // STEP 10 — Final success state
        delay(3.5) {
            phase = 10
            withAnimation(.easeInOut(duration: 0.4)) {
                titleText = "Logic Fixed"
                subtitleText = "Correct decision leads to the correct result."
            }
        }

        // Auto-show dialog
        delay(5.2) {
            withAnimation { showDialog = true }
        }
    }

    // MARK: - Card Shake
    func shakeCard() {
        let steps: [CGFloat] = [6, -6, 4, -4, 2, -2, 0]
        var cumulativeDelay: Double = 0
        for offset in steps {
            let d = cumulativeDelay
            delay(d) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                    wrongCardShakeX = offset
                }
            }
            cumulativeDelay += 0.08
        }
    }

    // MARK: - Delay Helper
    func delay(_ seconds: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: action)
    }
}

#Preview {
    LogicErrorWorld(viewModel: AppViewModel())
}
