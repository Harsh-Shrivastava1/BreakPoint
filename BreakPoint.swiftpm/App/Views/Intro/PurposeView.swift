import SwiftUI

struct PurposeView: View {
    @ObservedObject var viewModel: AppViewModel
    
    // Text State
    @State private var displayedText: String = ""
    @State private var textOpacity: Double = 1.0
    @State private var textBlur: CGFloat = 0.0
    @State private var textScale: CGFloat = 1.0
    @State private var textWeight: Font.Weight = .medium
    
    // Final Scene State
    @State private var showFinalLine: Bool = false
    @State private var finalLineBlur: CGFloat = 20.0
    @State private var finalLineOpacity: Double = 0.0
    @State private var finalLineScale: CGFloat = 0.95
    
    // Button State
    @State private var showButton: Bool = false
    @State private var buttonScale: CGFloat = 0.85
    @State private var buttonOpacity: Double = 0.0
    @State private var isButtonPressed: Bool = false
    @State private var buttonGlow: CGFloat = 0
    
    // Progress Bar State
    @State private var progress: Double = 0.0
    @State private var showProgress: Bool = false
    @State private var autoTransitionTask: Task<Void, Never>? = nil
    
    // Screen exit
    @State private var screenBlur: CGFloat = 0.0
    @State private var screenOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Enhanced Cinematic Background
            CinematicPurposeBackground()
                .blur(radius: screenBlur)
                .opacity(screenOpacity)
            
            // Skip Button (Top Right) - Enhanced
            if !showFinalLine {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            completeIntro(isSkip: true)
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary.opacity(0.5))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.glassBackground)
                                        .shadow(color: .black.opacity(0.04), radius: 12)
                                )
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 24)
                    }
                    Spacer()
                }
                .zIndex(100)
                .transition(.asymmetric(insertion: .opacity, removal: .opacity.animation(.easeOut(duration: 0.3))))
            }
            
            // Content Layer
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                
                // Story Text Area
                if !showFinalLine {
                    Text(displayedText)
                        .font(.system(size: 26, weight: textWeight, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primary.opacity(0.75))
                        .lineSpacing(10)
                        .blur(radius: textBlur)
                        .opacity(textOpacity)
                        .scaleEffect(textScale)
                        .frame(maxWidth: 320, minHeight: 140, alignment: .center)
                        .transition(.opacity)
                }
                
                // Final Reveal Area - Enhanced
                if showFinalLine {
                    VStack(spacing: 28) {
                        Text("Breakpoint lets you see it.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "60A5FA"),
                                        Color(hex: "A78BFA"),
                                        Color(hex: "C084FC")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .blur(radius: finalLineBlur)
                            .opacity(finalLineOpacity)
                            .scaleEffect(finalLineScale)
                            .shadow(color: Color.blue.opacity(0.15), radius: 20, x: 0, y: 10)
                        
                        // Premium Progress Bar - Repositioned
                        if showProgress {
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.primary.opacity(0.1))
                                    .frame(width: 160, height: 4)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "4C6EF5"), Color(hex: "7C3AED")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 160 * CGFloat(progress), height: 4)
                                    .shadow(color: Color(hex: "4C6EF5").opacity(0.3), radius: 4)
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    }
                }
                
                Spacer(minLength: 60)
                
                // Refined Button
                if showButton {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        completeIntro(isSkip: false)
                    }) {
                        HStack(spacing: 10) {
                            Text("Start Exploring")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 44)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(Color(hex: "5B7FE8"))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
                    }
                    .scaleEffect(isButtonPressed ? 0.96 : buttonScale)
                    .opacity(buttonOpacity)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 64)
        }
        .task {
            await runStorySequence()
        }
    }
    
    // MARK: - Story Sequence
    
    private func runStorySequence() async {
        // Initial delay for smooth entry
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        
        // 1. "Code bugs are invisible."
        await typeWriter("Code bugs are invisible.")
        try? await Task.sleep(nanoseconds: 500_000_000)
        await fadeOutText()
        
        // 2. "But their effects are not."
        await typeWriter("But their effects are not.")
        try? await Task.sleep(nanoseconds: 500_000_000)
        await fadeOutText()
        
        // 3. List: "Apps freeze...", "Apps crash...", "Apps behave strangely."
        await typeWriter("Apps freeze.", clearPrevious: true)
        try? await Task.sleep(nanoseconds: 300_000_000)
        await typeWriter("\nApps crash.", clearPrevious: false)
        try? await Task.sleep(nanoseconds: 300_000_000)
        await typeWriter("\nApps behave strangely.", clearPrevious: false)
        try? await Task.sleep(nanoseconds: 600_000_000)
        await fadeOutText()
        
        // 4. MAIN LINE: "Your code feels the chaos."
        textScale = 1.12
        textWeight = .bold
        await typeWriter("Your code feels the chaos.", speed: 0.025)
        
        // Soft Highlight / Pause
        try? await Task.sleep(nanoseconds: 700_000_000)
        
        // Custom fade out for this big text
        withAnimation(.easeOut(duration: 0.4)) {
            textOpacity = 0
            textBlur = 12
            textScale = 1.25
        }
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // 5. FINAL LINE Reveal: "Breakpoint lets you see it."
        withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
            showFinalLine = true
            finalLineBlur = 0
            finalLineOpacity = 1.0
            finalLineScale = 1.0
        }
        
        // 6. Button Reveal with enhanced animation
        try? await Task.sleep(nanoseconds: 600_000_000)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showButton = true
            buttonOpacity = 1.0
            buttonScale = 1.0
        }
        
        // Subtle button pulse
        try? await Task.sleep(nanoseconds: 200_000_000)
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            buttonGlow = 1.0
        }
        
        // 7. Auto-Transition Sequence
        try? await Task.sleep(nanoseconds: 800_000_000)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            showProgress = true
        }
        
        autoTransitionTask = Task {
            // Smooth single animation over 4 seconds
            withAnimation(.linear(duration: 4.0)) {
                progress = 1.0
            }
            
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            
            if !Task.isCancelled {
                completeIntro(isSkip: false)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func typeWriter(_ text: String, speed: Double = 0.018, clearPrevious: Bool = true) async {
        if clearPrevious {
            displayedText = ""
            textOpacity = 1.0
            textBlur = 0
            textScale = 1.0
            textWeight = .medium
        }
        
        for char in text {
            displayedText.append(char)
            let randomVar = Double.random(in: 0.0...0.006)
            try? await Task.sleep(nanoseconds: UInt64((speed + randomVar) * 1_000_000_000))
        }
    }
    
    private func fadeOutText() async {
        withAnimation(.easeOut(duration: 0.35)) {
            textOpacity = 0
            textBlur = 6
            textScale = 0.94
        }
        try? await Task.sleep(nanoseconds: 250_000_000)
    }
    
    private func completeIntro(isSkip: Bool = false) {
        autoTransitionTask?.cancel()
        
        if isSkip {
            viewModel.advanceFlow()
        } else {
            // Button Press Visual
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                isButtonPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                viewModel.advanceFlow()
            }
        }
    }
}

// MARK: - Enhanced Cinematic Background

private struct CinematicPurposeBackground: View {
    @State private var animateBlob1 = false
    @State private var animateBlob2 = false
    @State private var animateBlob3 = false
    @State private var animateBlob4 = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // 1. Enhanced Gradient Base - Smoother & More Vibrant
            LinearGradient(
                colors: [
                    .backgroundGradientStart,
                    .loopBgCenter,
                    .loopBgEdge,
                    .backgroundGradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Starfield Overlay (Dark Mode only)
            Starfield()
            
            // 2. Enhanced Floating Blur Circles
            GeometryReader { geo in
                ZStack {
                    // Blob 1: Blue -> Nebula Blue
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(UIColor { traitCollection in
                                        traitCollection.userInterfaceStyle == .dark ? .systemBlue : UIColor(hex: "4C6EF5")
                                    }).opacity(0.12),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 220
                            )
                        )
                        .frame(width: 450, height: 450)
                        .blur(radius: 90)
                        .offset(
                            x: animateBlob1 ? -120 : 120,
                            y: animateBlob1 ? -60 : 60
                        )
                        .blendMode(colorScheme == .dark ? .screen : .normal)
                    
                    // Blob 2: Purple -> Nebula Purple
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(UIColor { traitCollection in
                                        traitCollection.userInterfaceStyle == .dark ? .systemPurple : UIColor(hex: "7C3AED")
                                    }).opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 175
                            )
                        )
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(
                            x: animateBlob2 ? 160 : -160,
                            y: animateBlob2 ? 120 : -120
                        )
                        .blendMode(colorScheme == .dark ? .screen : .normal)
                    
                    // Blob 3: Center glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.35 : 0.5),
                                    Color.white.opacity(0.01)
                                ],
                                center: .center,
                                startRadius: 100,
                                endRadius: 250
                            )
                        )
                        .frame(width: 550, height: 550)
                        .blur(radius: 110)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .scaleEffect(animateBlob3 ? 1.15 : 0.85)
                    
                    // Blob 4: Accent Cyan
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.fixCool.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 350, height: 350)
                        .blur(radius: 70)
                        .offset(
                            x: animateBlob4 ? -80 : 80,
                            y: animateBlob4 ? 150 : -150
                        )
                        .blendMode(colorScheme == .dark ? .screen : .normal)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                animateBlob1.toggle()
            }
            withAnimation(.easeInOut(duration: 11).repeatForever(autoreverses: true)) {
                animateBlob2.toggle()
            }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                animateBlob3.toggle()
            }
            withAnimation(.easeInOut(duration: 13).repeatForever(autoreverses: true)) {
                animateBlob4.toggle()
            }
        }
    }
}

#Preview {
    PurposeView(viewModel: AppViewModel())
}
