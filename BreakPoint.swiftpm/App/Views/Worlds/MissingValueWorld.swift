import SwiftUI

// MARK: - Phase Map
// 0  idle
// 1  box appears (scale-in + pulse)
// 2  dot drops toward box
// 3  dot fades mid-air → failure (shake + orange glow)
// 4  "No value found" capsule visible; pause
// --- user taps "Handle Safely" ---
// 5  reset → "Handling safely..." title
// 6  new dot appears, pauses above box ("Checking before use")
// 7  dot fades safely → box turns green
// 8  success — "Logic Fixed" title, Continue button

struct MissingValueWorld: View {
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Phase
    @State private var phase: Int = 0
    @State private var showDialog: Bool = false

    // MARK: - Box States
    @State private var boxOpacity: Double = 0
    @State private var boxScale: CGFloat = 0.9
    @State private var boxColor: Color = .secondary
    @State private var boxGlowColor: Color = .clear
    @State private var boxGlowRadius: CGFloat = 0
    @State private var boxShakeX: CGFloat = 0

    // MARK: - Dot States
    @State private var dotVisible: Bool = false
    @State private var dotY: CGFloat = -110      // relative to box center; starts above
    @State private var dotOpacity: Double = 1
    @State private var dotColor: Color = Color.blue

    // MARK: - Labels
    @State private var floatingLabel: String = "Waiting for value..."
    @State private var floatingLabelVisible: Bool = false
    @State private var warningCapsuleVisible: Bool = false
    @State private var warningCapsuleText: String = "No value found"
    @State private var warningCapsuleColor: Color = .orange

    // MARK: - Caption
    @State private var captionText: String = ""
    @State private var captionVisible: Bool = false

    // MARK: - Header
    @State private var titleText: String = "Expecting a value..."
    @State private var subtitleText: String = "But nothing is there."

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack(alignment: .top) {
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

                // MARK: Animation Area
                ZStack(alignment: .center) {

                    // ── BACKGROUND GLOW ─────────────────────────────
                    Circle()
                        .fill(boxGlowColor.opacity(0.25))
                        .frame(width: 140, height: 140)
                        .blur(radius: boxGlowRadius)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: boxGlowRadius)

                    // ── BOX ─────────────────────────────────────────
                    VStack(spacing: 0) {
                        Image(systemName: phase >= 4 && phase < 5 ? "shippingbox" : "shippingbox.fill")
                            .font(.system(size: 72, weight: .light))
                            .foregroundColor(boxColor)
                            .scaleEffect(boxScale)
                            .offset(x: boxShakeX)
                            .shadow(color: boxColor.opacity(0.2), radius: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: boxColor)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: boxScale)
                    }
                    .opacity(boxOpacity)
                    .animation(.easeOut(duration: 0.5), value: boxOpacity)

                    // ── FLOATING DOT ─────────────────────────────────
                    if dotVisible {
                        Circle()
                            .fill(dotColor)
                            .frame(width: 14, height: 14)
                            .shadow(color: dotColor.opacity(0.5), radius: 6)
                            .offset(y: dotY)
                            .opacity(dotOpacity)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: dotY)
                            .animation(.easeOut(duration: 0.35), value: dotOpacity)
                    }

                    // ── FLOATING LABEL (above box) ───────────────────
                    if floatingLabelVisible {
                        Text(floatingLabel)
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color.secondary.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .offset(y: -120)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // ── WARNING / SUCCESS CAPSULE ────────────────────
                    if warningCapsuleVisible {
                        Label(warningCapsuleText,
                              systemImage: warningCapsuleText == "No value found"
                                ? "exclamationmark.triangle.fill"
                                : warningCapsuleText == "Checking before use"
                                    ? "eye.fill"
                                    : "checkmark.shield.fill"
                        )
                        .font(.caption.bold())
                        .foregroundColor(warningCapsuleColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(warningCapsuleColor.opacity(0.35), lineWidth: 1)
                        )
                        .offset(y: -120)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }

                    // ── CAPTION (below box) ──────────────────────────
                    if captionVisible {
                        Text(captionText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .offset(y: 72)
                            .transition(.opacity)
                    }
                }
                .frame(width: 300, height: 320)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

                Spacer()

                // MARK: CTA Button
                Button(action: handleButtonTap) {
                    Text(phase >= 8 ? "Continue" : "Handle Safely")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 260, height: 52)
                        .background(
                            Capsule()
                                .fill(buttonGradient(for: phase))
                        )
                        .shadow(
                            color: (phase >= 8 ? Color.green : Color.blue).opacity(0.35),
                            radius: 10,
                            y: 4
                        )
                        .scaleEffect(phase >= 8 ? 1.05 : 1.0)
                }
                .disabled(phase < 4 || (phase > 4 && phase < 8))
                .padding(.bottom, 28)
                .opacity(phase >= 4 ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.4), value: phase)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 32)
            .blur(radius: showDialog ? 10 : 0)


            if showDialog {
                DialogView(viewModel: viewModel, showDialog: $showDialog)
            }
        }
        .frame(width: w, height: h)
        }
        .onAppear {
            runFailureSequence()
        }
    }

    // MARK: - Button Gradient
    func buttonGradient(for phase: Int) -> LinearGradient {
        phase >= 8
            ? LinearGradient(colors: [.green, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
            : LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
    }

    // MARK: - Button Handler
    func handleButtonTap() {
        if phase >= 8 {
            withAnimation { showDialog = true }
        } else {
            runSafeHandlingSequence()
        }
    }

    // MARK: - Failure Sequence (auto-plays on appear)

    func runFailureSequence() {
        // STEP 1 — box appears
        phase = 1
        delay(0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                boxOpacity = 1
                boxScale = 1.0
                boxColor = Color(uiColor: .systemGray2)
            }
            // floating label
            delay(0.4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    floatingLabel = "Waiting for value..."
                    floatingLabelVisible = true
                }
            }
            // subtle pulse
            delay(0.6) {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.6)) {
                    boxScale = 1.04
                }
                delay(0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        boxScale = 1.0
                    }
                }
            }
        }

        // STEP 2 — dot drops
        delay(1.4) {
            phase = 2
            withAnimation(.easeOut(duration: 0.3)) {
                floatingLabelVisible = false
            }
            delay(0.3) {
                dotColor = .blue
                dotOpacity = 1.0
                dotY = -110
                dotVisible = true
                // drop toward box
                withAnimation(.easeInOut(duration: 0.7)) {
                    dotY = -10
                }
            }
        }

        // STEP 3 — dot fails mid-air
        delay(2.5) {
            phase = 3
            // dot fades mid-way
            withAnimation(.easeOut(duration: 0.35)) {
                dotOpacity = 0
            }
            delay(0.3) {
                dotVisible = false
            }
        }

        // STEP 4 — failure feedback
        delay(2.9) {
            phase = 4
            // box turns orange
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                boxColor = .orange
                boxGlowColor = .orange
                boxGlowRadius = 24
            }
            // shake
            shakeBox()
            // warning capsule
            delay(0.35) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    warningCapsuleText = "No value found"
                    warningCapsuleColor = .orange
                    warningCapsuleVisible = true
                }
            }
            // caption
            delay(0.6) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    captionText = "Nothing exists here"
                    captionVisible = true
                }
            }
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    // MARK: - Safe Handling Sequence (triggered on button tap)

    func runSafeHandlingSequence() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // STEP 5 — reset
        phase = 5
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            warningCapsuleVisible = false
            captionVisible = false
            boxColor = Color(uiColor: .systemGray2)
            boxGlowColor = .clear
            boxGlowRadius = 0
        }
        delay(0.25) {
            withAnimation(.easeInOut(duration: 0.4)) {
                titleText = "Handling safely..."
                subtitleText = "Applying a safe check before using the value."
            }
        }

        // STEP 6 — dot appears and pauses ("Checking before use")
        delay(0.8) {
            phase = 6
            dotColor = .blue
            dotOpacity = 1.0
            dotY = -110
            dotVisible = true

            // dot drops only partway, then stops
            delay(0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    dotY = -55   // pause above box — NOT inside
                }
            }
            // show "Checking before use"
            delay(0.6) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    warningCapsuleText = "Checking before use"
                    warningCapsuleColor = Color(uiColor: .systemBlue)
                    warningCapsuleVisible = true
                }
            }
        }

        // STEP 7 — dot fades safely, box turns green
        delay(2.2) {
            phase = 7
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                warningCapsuleVisible = false
            }
            // dot fades out (safe — no crash)
            withAnimation(.easeOut(duration: 0.45)) {
                dotOpacity = 0
            }
            delay(0.5) {
                dotVisible = false
                // box turns green
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    boxColor = .green
                    boxGlowColor = .green
                    boxGlowRadius = 22
                }
                // "Handled safely" capsule
                delay(0.2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        warningCapsuleText = "Handled safely"
                        warningCapsuleColor = .green
                        warningCapsuleVisible = true
                    }
                }
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        // STEP 8 — success
        delay(3.5) {
            phase = 8
            withAnimation(.easeInOut(duration: 0.4)) {
                titleText = "Logic Fixed"
                subtitleText = "No crash. Safe handling applied."
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                boxScale = 1.06
            }
        }

        // Auto-show dialog
        delay(5.2) {
            withAnimation { showDialog = true }
        }
    }

    // MARK: - Box Shake
    func shakeBox() {
        let offsets: [CGFloat] = [5, -5, 4, -4, 2, -2, 0]
        var t: Double = 0
        for offset in offsets {
            let d = t
            delay(d) {
                withAnimation(.spring(response: 0.12, dampingFraction: 0.5)) {
                    boxShakeX = offset
                }
            }
            t += 0.07
        }
    }

    // MARK: - Delay helper
    func delay(_ seconds: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: action)
    }

    // MARK: - Reflection Dialog
    struct DialogView: View {
        @ObservedObject var viewModel: AppViewModel
        @Binding var showDialog: Bool

        var body: some View {
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

                    Text("Programs fail when they expect data but get nothing.")
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("\"Like opening a fridge to cook and finding it empty.\"")
                        .font(.system(size: 16, design: .serif))
                        .italic()
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.08))
                        )

                    Text("Checking for values prevents crashes.")
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

#Preview {
    MissingValueWorld(viewModel: AppViewModel())
}
