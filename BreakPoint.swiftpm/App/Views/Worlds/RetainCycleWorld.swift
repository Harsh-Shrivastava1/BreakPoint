import SwiftUI

// MARK: - RetainCycleWorld
// Premium visualisation of a retain cycle —
//   • Dual-orbit particle rings (counter-rotating)
//   • Animated chain-link connection with two energy bolts
//   • Danger aura that breathes and reddens over time
//   • Rising memory-pressure bar
//   • Shatter-burst on fix

struct RetainCycleWorld: View {
    @ObservedObject var viewModel: AppViewModel

    @State private var phase = 0
    @State private var showDialog = false

    // orbital rings (driven by timer)
    @State private var orbitAngleA: Double = 0
    @State private var orbitAngleB: Double = 180

    // chain energy bolt 0→1
    @State private var chainProgress: Double = 0

    // danger / aura
    @State private var auraScale: CGFloat = 1.0
    @State private var dangerLevel: Double = 0     // 0→1 over 6 s

    // memory bar
    @State private var memFill: Double = 0.08

    // fix sequence
    @State private var shatterActive = false
    @State private var connectionOpacity: Double = 1
    @State private var objectBOpacity: Double  = 1
    @State private var fixFlash = false

    // stable debris positions computed once on tap
    @State private var debrisItems: [DebrisItem] = []

    @State private var animTimer: Timer? = nil

    // responsive constants (set from geometry)
    @State private var nodeOffset: CGFloat = 90   // A at -nodeOffset, B at +nodeOffset
    @State private var orbitRadius: CGFloat = 44
    @State private var circleSize: CGFloat  = 68
    @State private var chainWidth: CGFloat  = 144  // gap between node centres minus circle radius

    private let particleCount = 5

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Responsive sizing — adapt to the available width
            let nodeOff: CGFloat  = min(w * 0.26, 100)
            let orb: CGFloat      = min(w * 0.12, 46)
            let circ: CGFloat     = min(w * 0.185, 70)
            let chain: CGFloat    = nodeOff * 2 - circ   // length of chain between nodes

            ZStack(alignment: .top) {

                // ── Background ──────────────────────────────────────
                RadialGradient(
                    colors: [Color.loopBgCenter, Color.loopBgEdge],
                    center: .center, startRadius: 0, endRadius: 500
                )
                .ignoresSafeArea()

                // ── Danger aura glow (behind everything) ────────────
                if phase == 0 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.red.opacity(0.22 * dangerLevel), .clear],
                                center: .center, startRadius: 0, endRadius: 260
                            )
                        )
                        .frame(width: 520, height: 520)
                        .scaleEffect(auraScale)
                        .position(x: w / 2, y: h / 2)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: auraScale)
                }

                // ── Fix flash ────────────────────────────────────────
                if fixFlash {
                    Color.white.opacity(0.65)
                        .ignoresSafeArea()
                        .zIndex(20)
                }

                // ── Main layout ──────────────────────────────────────
                VStack(spacing: 0) {

                    // Header
                    VStack(spacing: 8) {
                        Text(titleText)
                            .font(.system(size: min(w * 0.068, 26), weight: .bold))
                            .foregroundColor(phase == 1 ? .successGreen : titleColor)
                            .multilineTextAlignment(.center)
                            .id("title-\(phase)")
                            .transition(.opacity.combined(with: .offset(y: 8)))
                            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: phase)

                        Text(subtitleText)
                            .font(.system(size: min(w * 0.042, 16), weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: w * 0.78)
                            .id("sub-\(phase)")
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.4).delay(0.1), value: phase)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 0)

                    // ── Visualization ────────────────────────────────
                    ZStack {

                        // Chain + energy bolts
                        if phase == 0 || connectionOpacity > 0 {
                            chainView(chainWidth: chain, circleSize: circ)
                                .opacity(connectionOpacity)
                        }

                        // Node A (left)
                        nodeView(letter: "A",
                                 baseColor: .blue,
                                 orbitAngle: orbitAngleA,
                                 orbitColor: .blue,
                                 orbitRadius: orb,
                                 circleSize: circ)
                            .offset(x: -nodeOff)

                        // Node B (right)
                        nodeView(letter: "B",
                                 baseColor: .purple,
                                 orbitAngle: orbitAngleB,
                                 orbitColor: .purple,
                                 orbitRadius: orb,
                                 circleSize: circ)
                            .offset(x: nodeOff)
                            .opacity(objectBOpacity)

                        // Debris particles (on shatter)
                        if shatterActive {
                            ForEach(debrisItems) { item in
                                Circle()
                                    .fill(item.color)
                                    .frame(width: item.size, height: item.size)
                                    .offset(item.offset)
                                    .opacity(item.opacity)
                            }
                        }
                    }
                    // Give the viz area a proper fraction of height
                    .frame(width: w, height: h * 0.38)
                    .clipped(antialiased: false) // allow orbital glow to breathe out

                    // ── Memory pressure bar ──────────────────────────
                    if phase == 0 {
                        VStack(spacing: 5) {
                            Text("MEMORY PRESSURE")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary.opacity(0.55))
                                .tracking(1.6)

                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.07))
                                    .frame(width: w * 0.5, height: 8)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple, .red],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: CGFloat(memFill) * w * 0.5, height: 8)
                                    .animation(.easeInOut(duration: 1.3), value: memFill)
                            }
                            .clipShape(Capsule())
                        }
                        .padding(.top, 16)
                        .transition(.opacity)
                    }

                    Spacer(minLength: 0)

                    // ── CTA Button ───────────────────────────────────
                    Button(action: handleButtonTap) {
                        Text(phase == 1 ? "Continue" : "Release Reference")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: min(w * 0.72, 280))
                            .background(Capsule().fill(buttonGradient))
                            .shadow(color: buttonShadowColor.opacity(0.4), radius: 12, y: 4)
                    }
                    .disabled(showDialog)
                    .padding(.bottom, 32)
                }
                .blur(radius: showDialog ? 10 : 0)

                // ── Dialog ───────────────────────────────────────────
                if showDialog { dialogView }
            }
            .onAppear {
                // Store responsive values for later use in handlers
                nodeOffset   = nodeOff
                orbitRadius  = orb
                circleSize   = circ
                chainWidth   = chain
                startAnimations()
            }
            .onDisappear { animTimer?.invalidate() }
        }
    }

    // MARK: - Node View

    private func nodeView(letter: String,
                          baseColor: Color,
                          orbitAngle: Double,
                          orbitColor: Color,
                          orbitRadius: CGFloat,
                          circleSize: CGFloat) -> some View {
        ZStack {
            // Glow halo
            Circle()
                .fill(baseColor.opacity(0.12 + dangerLevel * 0.18))
                .frame(width: circleSize * 1.6, height: circleSize * 1.6)
                .blur(radius: 14)

            // Orbit particles
            if phase == 0 {
                ForEach(0..<particleCount, id: \.self) { i in
                    let angle = orbitAngle + Double(i) * (360.0 / Double(particleCount))
                    let rad   = CGFloat(angle * .pi / 180)
                    let fade  = max(0.25, 0.75 - Double(i) * 0.1)
                    Circle()
                        .fill(orbitColor.opacity(fade))
                        .frame(width: 7, height: 7)
                        .blur(radius: 1)
                        .offset(x: orbitRadius * cos(rad),
                                y: orbitRadius * sin(rad))
                }
            }

            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [baseColor.opacity(0.85), baseColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1.5))
                .overlay(
                    Text(letter)
                        .font(.system(size: circleSize * 0.4, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
                .shadow(color: baseColor.opacity(0.45 + dangerLevel * 0.35),
                        radius: 12 + dangerLevel * 10, y: 3)
        }
    }

    // MARK: - Chain View

    private func chainView(chainWidth: CGFloat, circleSize: CGFloat) -> some View {
        let linkCount = max(4, Int(chainWidth / 22))
        let linkW     = (chainWidth - CGFloat(linkCount - 1) * 4) / CGFloat(linkCount)

        return ZStack {
            // Link segments
            HStack(spacing: 4) {
                ForEach(0..<linkCount, id: \.self) { _ in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.85)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: linkW, height: 7)
                        .shadow(color: Color.purple.opacity(0.25), radius: 3)
                }
            }

            // Arrow indicators
            Group {
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .offset(x: -(chainWidth * 0.2))

                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .offset(x: chainWidth * 0.2)
            }

            // Energy bolts (A→B and B→A)
            let halfChain = chainWidth / 2
            Group {
                Circle()
                    .fill(.white.opacity(0.92))
                    .frame(width: 10, height: 10)
                    .blur(radius: 3)
                    .shadow(color: .white, radius: 5)
                    .offset(x: -halfChain + CGFloat(chainProgress) * chainWidth)

                Circle()
                    .fill(.white.opacity(0.92))
                    .frame(width: 10, height: 10)
                    .blur(radius: 3)
                    .shadow(color: .white, radius: 5)
                    .offset(x: halfChain - CGFloat(chainProgress) * chainWidth)
            }
        }
    }

    // MARK: - Dialog

    private var dialogView: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showDialog = false } }
                .zIndex(1)

            VStack {
                Spacer()

                VStack(spacing: 18) {
                    Text("REFLECTION")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                        .tracking(2)

                    Text("Strong references trap objects. If A holds B and B holds A, neither can ever be deallocated — memory leaks silently.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.purple.opacity(0.7))
                            .padding(.top, 2)

                        Text("\"If two friends grip each other's wrists, neither can walk away. One must use weak to let go.\"")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .italic()
                            .foregroundColor(.primary.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(Color.purple.opacity(0.07))
                    .cornerRadius(14)

                    Text("Use `weak` or `unowned` to break retain cycles.")
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
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue))
                    }
                    .padding(.top, 4)
                }
                .padding(26)
                .padding(.bottom, 4)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.18), radius: 28, y: 12)
                )
                .padding(.horizontal, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: 12)
            .transition(.scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 20)))
            .zIndex(2)
        }
    }

    // MARK: - Computed

    var titleText: String {
        phase == 0 ? "Memory is leaking…" : "Cycle broken. Memory freed."
    }
    var subtitleText: String {
        phase == 0
            ? "A holds B. B holds A. Neither can be deallocated."
            : "Weak reference lets one object go."
    }
    var titleColor: Color {
        Color(UIColor { traitCollection in
            let isDark = traitCollection.userInterfaceStyle == .dark
            let level = CGFloat(dangerLevel)
            
            // Start from black (light mode) or white (dark mode)
            let baseR: CGFloat = isDark ? 1.0 : 0.0
            let baseG: CGFloat = isDark ? 1.0 : 0.0
            let baseB: CGFloat = isDark ? 1.0 : 0.0
            
            // Target warning color (vibrant in dark, stronger/deeper in light)
            let targetR: CGFloat = isDark ? 1.0 : 0.95
            let targetG: CGFloat = isDark ? 0.45 : 0.25
            let targetB: CGFloat = isDark ? 0.35 : 0.2
            
            return UIColor(
                red: baseR + (targetR - baseR) * level,
                green: baseG + (targetG - baseG) * level,
                blue: baseB + (targetB - baseB) * level,
                alpha: 1.0
            )
        })
    }
    var buttonGradient: LinearGradient {
        phase == 1
            ? LinearGradient(colors: [.successGreen, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
            : LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
    }
    var buttonShadowColor: Color { phase == 1 ? .successGreen : .blue }

    // MARK: - Animation Start

    func startAnimations() {
        // High-freq timer: orbit + bolt
        animTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            orbitAngleA += 1.4
            orbitAngleB -= 1.4
            chainProgress += 0.008
            if chainProgress >= 1 { chainProgress = 0 }
        }

        // Aura breath
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            auraScale = 1.2
        }

        // Danger level climbs to 1 over ~6 s
        let steps = 60
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.linear(duration: 0.1)) {
                    dangerLevel = Double(i) / Double(steps)
                }
            }
        }

        // Memory bar fills in steps
        scheduleMemFill(0.08)
    }

    private func scheduleMemFill(_ v: Double) {
        guard v <= 1.0, phase == 0 else { return }
        withAnimation(.easeInOut(duration: 1.3)) { memFill = v }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            scheduleMemFill(min(v + 0.13, 1.0))
        }
    }

    // MARK: - Button Handler

    func handleButtonTap() {
        guard !showDialog else { return }
        if phase == 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { showDialog = true }
            return
        }

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // Flash
        withAnimation(.easeOut(duration: 0.07)) { fixFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.3)) { fixFlash = false }
        }

        // Build stable debris (fixed sizes/positions — no flicker)
        debrisItems = (0..<14).map { i in
            let angle  = Double(i) / 14.0 * 2 * .pi + Double.random(in: -0.4...0.4)
            let dist   = CGFloat.random(in: 50...120)
            let sz     = CGFloat([6, 8, 10, 12, 14][i % 5])
            let col: Color = i < 7 ? Color.blue.opacity(0.85) : Color.purple.opacity(0.85)
            return DebrisItem(
                id: i,
                offset: CGSize(width: cos(angle) * dist, height: sin(angle) * dist),
                size: sz,
                color: col,
                opacity: 0
            )
        }
        shatterActive = true

        // Break connection
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            connectionOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.55)) { objectBOpacity = 0 }
        }

        // Set phase 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
            animTimer?.invalidate()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { phase = 1 }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        // Dialog
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { showDialog = true }
        }
    }
}

// MARK: - Debris Item Model

private struct DebrisItem: Identifiable {
    let id: Int
    let offset: CGSize
    let size: CGFloat
    let color: Color
    var opacity: Double
}

#Preview {
    RetainCycleWorld(viewModel: AppViewModel())
}
