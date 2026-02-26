import SwiftUI

// MARK: - InfiniteLoopWorld
// Premium particle-loop animation with escalating CPU stress visual and clean fix flow.
//
// Phase Map:
// 0  idle
// 1  loop running — stage 1 "Running..."         (blue)
// 2  loop faster  — stage 2 "Still running..."   (blue→purple)
// 3  loop faster  — stage 3 "CPU usage rising..."(purple)
// 4  overload     — stage 4 "System overloaded"  (purple→red)  button active
// 5  fixing       — slowing down, "Adding condition..."
// 6  break        — path gap, dot exits
// 7  resolved     — green calm, "Loop stopped"
// 8  success      — checkmark, "Execution completes normally" / Continue

struct InfiniteLoopWorld: View {
    @ObservedObject var viewModel: AppViewModel

    // MARK: - Phase
    @State private var phase: Int = 0
    @State private var showDialog: Bool = false

    // MARK: - Loop Rotation
    @State private var rotationAngle: Double = 0       // drives particle position
    @State private var loopDuration: Double = 2.8      // rotation period (decreases = faster)
    @State private var isLooping: Bool = false

    // MARK: - Visual Intensity
    @State private var ringColor1: Color = .blue
    @State private var ringColor2: Color = Color(uiColor: .systemIndigo)
    @State private var glowRadius: CGFloat = 12
    @State private var glowColor: Color = .blue
    @State private var bgPulseScale: CGFloat = 1.0
    @State private var jitterAmount: CGFloat = 0
    @State private var showEnergyRing: Bool = false
    @State private var energyRingOpacity: Double = 0
    @State private var isFlashing: Bool = false
    
    // MARK: - UI Labels
    @State private var stageText: String = "Initializing..."
    @State private var titleText: String = "Infinite Loop"
    @State private var subtitleText: String = "Code repeating — no exit condition."

    // MARK: - Fix / Success
    @State private var showCheckmark: Bool = false
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var ringVisible: Bool = true

    // MARK: - Timers
    @State private var rotationTimer: Timer? = nil

    // MARK: - Path Break (fix)
    @State private var pathGapStart: Double = 0         // degrees where gap opens
    @State private var pathGapSize: Double = 0          // degrees of gap
    @State private var dotExitY: CGFloat = 0            // offset downward when exiting

    // MARK: - Particle trail
    @State private var trailPositions: [Double] = []    // lag angles for trail dots

    // MARK: - Path radius
    @State private var ringRadius: CGFloat = 108
    let particleSize: CGFloat = 14
    let trailCount: Int = 5
    let trailSpacing: Double = 18   // degrees between trail dots

    var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: 1. Background
            RadialGradient(
                colors: [Color.loopBgCenter, Color.loopBgEdge], // Premium background
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Background pulse (syncs with loop speed)
            Circle()
                .fill(glowColor.opacity(0.06))
                .frame(width: 420, height: 420)
                .scaleEffect(bgPulseScale)
                .blur(radius: 40)
                .animation(
                    .easeInOut(duration: loopDuration / 2)
                    .repeatForever(autoreverses: true),
                    value: bgPulseScale
                )

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

                // MARK: Loop Visualization
                ZStack {
                    // ── OVERLAY FLASH ──────────────────────────────────
                    if isFlashing {
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: ringRadius * 3, height: ringRadius * 3)
                            .blur(radius: 40)
                            .zIndex(100)
                    }

                    // ── OUTER ENERGY RING (Overload state) ─────────────
                    if showEnergyRing {
                        Circle()
                            .stroke(
                                ringColor2.opacity(0.3),
                                style: StrokeStyle(lineWidth: 2, dash: [4, 8])
                            )
                            .frame(width: ringRadius * 2 + 40, height: ringRadius * 2 + 40)
                            .rotationEffect(.degrees(-rotationAngle * 0.5))
                            .opacity(energyRingOpacity)
                    }

                    // ── OUTER GLOW ───────────────────────────────────
                    Circle()
                        .fill(glowColor.opacity(0.18))
                        .frame(width: ringRadius * 2 + 60, height: ringRadius * 2 + 60)
                        .blur(radius: glowRadius)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: glowColor)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: glowRadius)

                    // ── RING TRACK with JITTER ─────────────────────────
                    if ringVisible {
                        LoopRingShape(gapStart: pathGapStart, gapSize: pathGapSize)
                            .stroke(
                                AngularGradient(
                                    colors: [ringColor1, ringColor2, ringColor1],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: ringRadius * 2, height: ringRadius * 2)
                            .opacity(0.35)
                            .offset(
                                x: CGFloat.random(in: -jitterAmount...jitterAmount),
                                y: CGFloat.random(in: -jitterAmount...jitterAmount)
                            )
                            .animation(.spring(response: 0.7, dampingFraction: 0.8), value: ringColor1)
                            .animation(.spring(response: 0.7, dampingFraction: 0.8), value: ringColor2)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: pathGapSize)

                        // BRIGHT ACCENT RING (full, thinner, no gap)
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [ringColor1.opacity(0.0), ringColor2, ringColor1.opacity(0.0)],
                                    center: .center,
                                    startAngle: .degrees(rotationAngle - 60),
                                    endAngle: .degrees(rotationAngle + 60)
                                ),
                                lineWidth: 3
                            )
                            .frame(width: ringRadius * 2, height: ringRadius * 2)
                            .offset(
                                x: CGFloat.random(in: -jitterAmount/2...jitterAmount/2),
                                y: CGFloat.random(in: -jitterAmount/2...jitterAmount/2)
                            )
                    }

                    // ── TRAIL DOTS ────────────────────────────────────
                    if isLooping && phase < 6 {
                        ForEach(0..<trailCount, id: \.self) { i in
                            let lagAngle = rotationAngle - Double(i + 1) * trailSpacing
                            let pos = particlePosition(angle: lagAngle)
                            let trailScale = 1.0 - Double(i) * 0.12
                            
                            Circle()
                                .fill(ringColor2.opacity(0.6 - Double(i) * 0.1))
                                .frame(
                                    width: particleSize * trailScale,
                                    height: particleSize * trailScale
                                )
                                .offset(x: pos.x, y: pos.y)
                                .blur(radius: CGFloat(i) * 0.5)
                        }
                    }

                    // ── MAIN PARTICLE ─────────────────────────────────
                    if phase < 7 {
                        let pos = particlePosition(angle: rotationAngle)
                        Circle()
                            .fill(LinearGradient(colors: [.white, ringColor2], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: particleSize, height: particleSize)
                            .shadow(color: ringColor2.opacity(0.8), radius: 8 + jitterAmount)
                            .offset(x: pos.x, y: pos.y + dotExitY)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dotExitY)
                    }

                    // ── CENTER CONTENT ────────────────────────────────
                    VStack(spacing: 10) {
                        if showCheckmark {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.green)
                                .scaleEffect(checkmarkScale)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: checkmarkScale)
                        } else {
                            // Stage status label
                            Text(stageText)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundColor(labelColor)
                                .multilineTextAlignment(.center)
                                .id(stageText)
                                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                                .animation(.easeInOut(duration: 0.3), value: stageText)
                        }
                    }
                    .frame(maxWidth: ringRadius * 1.2)
                }
                .frame(width: ringRadius * 2 + 80, height: ringRadius * 2 + 80)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

                Spacer()

                // MARK: CTA Button
                Button(action: handleButtonTap) {
                    Text(phase >= 8 ? "Continue" : "Add Exit Condition")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 260, height: 52)
                        .background(
                            Capsule()
                                .fill(buttonGradient(for: phase))
                        )
                        .shadow(
                            color: buttonShadowColor(for: phase).opacity(0.4),
                            radius: 12,
                            y: 4
                        )
                        .scaleEffect(phase >= 8 ? 1.05 : 1.0)
                }
                .disabled(phase < 4 || (phase > 4 && phase < 8))
                .opacity(phase >= 4 ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5), value: phase)
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
                        // Label
                        Text("REFLECTION")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(2.5)

                        // Main text
                        Text("An infinite loop keeps executing the same code without a stopping condition, consuming system resources continuously.")
                            .font(.system(size: 18, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 4)

                        // Analogy block
                        HStack(spacing: 14) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Like running on a treadmill that never stops — you keep moving, but never reach an end.")
                                .font(.system(size: 14, design: .serif))
                                .italic()
                                .foregroundColor(.primary.opacity(0.82))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue.opacity(0.08))
                        )

                        // Supporting line
                        Text("Always define an exit condition to stop execution.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        // Continue button
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showDialog = false
                            }
                            viewModel.clearSelection()
                        }) {
                            Text("Continue Exploring")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.blue)
                                        .shadow(color: Color.blue.opacity(0.35), radius: 8, y: 4)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(28)
                    .padding(.bottom, 8) // Slight breathing space inside card
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.18), radius: 24, y: 10)
                    )
                    .padding(.horizontal, 28)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: 15) // Bias slightly downwards
                .transition(.scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 25)))
                .zIndex(2)
            }
        }
        .onAppear {
            startLoopSequence()
        }
        .onDisappear {
            rotationTimer?.invalidate()
        }
    }

    // MARK: - Computed Helpers

    var labelColor: Color {
        switch phase {
        case 0, 1: return .blue
        case 2: return Color(uiColor: .systemIndigo)
        case 3: return .purple
        case 4: return .red
        case 5: return .orange
        case 6: return .orange
        case 7: return .green
        default: return .green
        }
    }

    func buttonGradient(for phase: Int) -> LinearGradient {
        if phase >= 8 {
            return LinearGradient(colors: [.green, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
        } else if phase >= 4 {
            return LinearGradient(colors: [.orange, Color(hex: "FF9500")], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        }
    }

    func buttonShadowColor(for phase: Int) -> Color {
        phase >= 8 ? .green : .orange
    }

    func particlePosition(angle: Double) -> CGPoint {
        let rad = CGFloat(angle * .pi / 180)
        return CGPoint(
            x: ringRadius * cos(rad),
            y: ringRadius * sin(rad)
        )
    }

    // MARK: - Button Handler
    func handleButtonTap() {
        if phase >= 8 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showDialog = true
            }
        } else if phase == 4 {
            runFixSequence()
        }
    }

    // MARK: - Rotation Driver
    // We use a Timer at ~60fps to smoothly update rotationAngle based on loopDuration.
    func startRotationDriver() {
        rotationTimer?.invalidate()
        let fps: Double = 60
        let interval = 1.0 / fps
        rotationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            let degreesPerFrame = 360.0 / (loopDuration * fps)
            rotationAngle += degreesPerFrame
            if rotationAngle >= 360 { rotationAngle -= 360 }
        }
    }

    // MARK: - Main Sequence

    func startLoopSequence() {
        // Stage 1 — calm blue loop
        phase = 1
        loopDuration = 2.8
        ringColor1 = .blue
        ringColor2 = Color(uiColor: .systemIndigo)
        glowColor = .blue
        glowRadius = 12
        bgPulseScale = 1.04
        stageText = "Running..."
        subtitleText = "The loop starts, checking the condition repeatedly."
        isLooping = true
        startRotationDriver()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Stage 2 — slightly faster, blue→purple
        delay(2.5) {
            phase = 2
            loopDuration = 2.0
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                ringColor1 = Color(uiColor: .systemIndigo)
                ringColor2 = .purple
                glowColor = .purple
                glowRadius = 16
                stageText = "Still running..."
                subtitleText = "The cycle repeats. Speed is increasing."
            }
        }

        // Stage 3 — faster, purple
        delay(5.0) {
            phase = 3
            loopDuration = 1.3
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                ringColor1 = .purple
                ringColor2 = Color(uiColor: .systemPink)
                glowColor = .purple
                glowRadius = 22
                bgPulseScale = 1.08
                stageText = "CPU usage rising..."
                subtitleText = "Resources are being consumed by the endless task."
            }
        }

        // Stage 4 — overload, red, button appears
        delay(7.5) {
            phase = 4
            loopDuration = 0.85
            showEnergyRing = true
            withAnimation(.easeInOut(duration: 1.0)) {
                energyRingOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                ringColor1 = Color(uiColor: .systemPink)
                ringColor2 = .red
                glowColor = .red
                glowRadius = 35
                jitterAmount = 4
                bgPulseScale = 1.15
                stageText = "SYSTEM OVERLOAD"
                subtitleText = "The system is trapped! It's an unbreakable cycle."
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // Subtle screen shake
            delay(0.3) { vibrateScreen() }
        }
    }

    // MARK: - Fix Sequence

    func runFixSequence() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        // Flash!
        withAnimation(.easeOut(duration: 0.15)) { isFlashing = true }
        delay(0.15) {
            withAnimation(.easeIn(duration: 0.4)) { isFlashing = false }
        }

        // Step 5 — slow down, "Adding condition..."
        phase = 5
        loopDuration = 3.5    // slows dramatically
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            ringColor1 = .orange
            ringColor2 = Color(uiColor: .systemYellow)
            glowColor = .orange
            glowRadius = 20
            jitterAmount = 0.5
            energyRingOpacity = 0
            bgPulseScale = 1.02
            stageText = "Breaking cycle..."
            subtitleText = "Injecting exit condition..."
        }

        // Step 6 — gap opens in path, dot exits downward
        delay(1.2) {
            phase = 6
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                pathGapStart = rotationAngle      // gap at current dot position
                pathGapSize = 60                  // 60-degree gap
            }
            // Dot exits
            delay(0.3) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    dotExitY = 180
                    stageText = "Loop stopped"
                    subtitleText = "The code escapes the loop through the new path."
                }
                isLooping = false
                rotationTimer?.invalidate()
            }
        }

        // Step 7 — calm green resolution
        delay(2.2) {
            phase = 7
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                ringColor1 = Color(uiColor: .systemTeal)
                ringColor2 = .green
                glowColor = .green
                glowRadius = 14
                bgPulseScale = 1.0
                pathGapSize = 0     // ring heals
                stageText = "Loop stopped"
                subtitleText = "Exit condition applied successfully."
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        // Step 8 — success state
        delay(3.2) {
            phase = 8
            ringVisible = false
            showCheckmark = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
                titleText = "Loop Fixed"
                subtitleText = "Execution completes normally."
            }
            stageText = "Done ✓"
        }
    }

    // MARK: - Screen Vibration (subtle)
    func vibrateScreen() {
        let offsets: [Double] = [0.05, -0.05, 0.04, -0.04, 0.02, -0.02, 0]
        var t: Double = 0
        for _ in offsets {
            let d = t
            delay(d) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.4)
            }
            t += 0.06
        }
    }

    // MARK: - Delay helper
    func delay(_ seconds: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: action)
    }
}

// MARK: - Loop Ring Shape (supports a gap for the "break" effect)
struct LoopRingShape: Shape {
    var gapStart: Double   // degrees
    var gapSize: Double    // degrees

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(gapStart, gapSize) }
        set {
            gapStart = newValue.first
            gapSize = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        if gapSize <= 0 {
            // Full circle
            return Path { p in
                p.addArc(center: center, radius: radius,
                         startAngle: .degrees(0), endAngle: .degrees(360),
                         clockwise: false)
            }
        }

        // Arc with gap
        let gapStartRad = gapStart
        let gapEndRad = gapStart + gapSize
        return Path { p in
            p.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(gapEndRad),
                endAngle: .degrees(gapStartRad),
                clockwise: false
            )
        }
    }
}

#Preview {
    InfiniteLoopWorld(viewModel: AppViewModel())
}
