import SwiftUI

struct DeadlockWorld: View {
    @ObservedObject var viewModel: AppViewModel
    
    // MARK: - States
    @State private var phase = 0 // 0: Waiting, 1: Detected, 2: Resolving, 3: Resolved
    @State private var showDialog = false
    @State private var statusTextIndex = 0
    
    // Animation Values
    @State private var taskAOffset: CGFloat = -100
    @State private var taskBOffset: CGFloat = 100
    
    // Items
    @State private var keyAOffset: CGSize = .zero // Task A holds Blue Key initially
    @State private var keyBOffset: CGSize = .zero // Task B holds Red Key initially
    
    @State private var lockAShake: CGFloat = 0
    @State private var lockBShake: CGFloat = 0
    @State private var glowIntensity: CGFloat = 0
    
    // Logic
    @State private var isBlocked = false
    @State private var keysSwapped = false
    @State private var locksOpen = false
    
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
            
            VStack(spacing: 0) {
                // MARK: 2. Header Status
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 300)
                        .foregroundColor(titleColor)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("title-\(statusTextIndex)")
                        .animation(.easeInOut(duration: 0.5), value: statusTextIndex)
                    
                    Text(subtitleText)
                        .font(.body)
                        .foregroundColor(.secondary.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 280)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("sub-\(statusTextIndex)")
                        .animation(.easeInOut(duration: 0.5).delay(0.1), value: statusTextIndex)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // MARK: 3. Visualization
                ZStack {
                    // Lock Icons (Center)
                    if !locksOpen && phase < 3 {
                         HStack(spacing: 40) {
                            Spacer()

                            Image(systemName: "lock.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary.opacity(0.3))
                                .scaleEffect(isBlocked ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBlocked)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary.opacity(0.3))
                                .scaleEffect(isBlocked ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.5), value: isBlocked)
                            Spacer()
                        }
                    }
                    
                    // Task A (Left)
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 88, height: 88)
                                .overlay(
                                    Circle().stroke(Color.blue, lineWidth: 3)
                                )
                                .shadow(color: isBlocked ? .bugWarm.opacity(glowIntensity) : .clear, radius: 15)
                            
                            Text("A")
                                .font(.title.bold())
                                .foregroundColor(.blue)
                            
                            // Held Key Indicator
                            Image(systemName: "key.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Circle().fill(Color.blue))
                                .offset(x: 32, y: 32)
                                .offset(keyAOffset)
                                .opacity(phase == 3 ? 0 : 1)
                        }
                        
                        Text("Has A • Needs B")
                            .font(.caption2.bold())
                            .foregroundColor(.secondary)
                            .opacity(phase == 3 ? 0 : 1)
                    }
                    .offset(x: taskAOffset)
                    // Bounce animation
                    .offset(x: isBlocked ? 5 : 0)
                    .animation(isBlocked ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isBlocked)
                    
                    // Task B (Right)
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.bugWarm.opacity(0.15))
                                .frame(width: 88, height: 88)
                                .overlay(
                                    Circle().stroke(Color.bugWarm, lineWidth: 3)
                                )
                                .shadow(color: isBlocked ? .bugWarm.opacity(glowIntensity) : .clear, radius: 15)
                            
                            Text("B")
                                .font(.title.bold())
                                .foregroundColor(.bugWarm)
                            
                            // Held Key Indicator
                            Image(systemName: "key.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Circle().fill(Color.bugWarm))
                                .offset(x: -32, y: 32)
                                .offset(keyBOffset)
                                .opacity(phase == 3 ? 0 : 1)
                        }
                        
                        Text("Has B • Needs A")
                            .font(.caption2.bold())
                            .foregroundColor(.secondary)
                            .opacity(phase == 3 ? 0 : 1)
                    }
                    .offset(x: taskBOffset)
                    // Bounce animation
                    .offset(x: isBlocked ? -5 : 0)
                    .animation(isBlocked ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isBlocked)
                    
                }
                .frame(height: 180)
                .padding(.top, 24)
                
                // Explainer text below animation
                if phase < 2 {
                    Text("Task A holds Key A and needs Key B.\nTask B holds Key B and needs Key A.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .transition(.opacity)
                } else {
                    Spacer().frame(height: 16) // preserve layout
                }
                
                Spacer()
                
                // MARK: 4. Interaction Button
                Button(action: handleButtonTap) {
                    Text(phase == 3 ? "Continue" : "Resolve Deadlock")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 260, height: 52)
                        .background(
                            Capsule()
                                .fill(buttonGradient)
                        )
                        .shadow(color: buttonShadowColor.opacity(0.4), radius: 10, y: 4)
                        .scaleEffect(phase == 3 ? 1.0 : 0.98)
                }
                .disabled(showDialog || phase < 1)
                .opacity(phase < 1 ? 0.5 : 1.0)
                .padding(.top, 32)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity)
            .blur(radius: showDialog ? 10 : 0)

            
            // MARK: 5. Educational Dialog Overlay
            // MARK: 5. Educational Dialog Overlay
            if showDialog {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showDialog = false }
                    }
                    .zIndex(1)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("REFLECTION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        Text("Deadlock happens when tasks wait on each other forever.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 40))
                                .foregroundColor(.blue.opacity(0.5))
                                .padding(.bottom, 8)
                                
                            Text("\"Like two people holding each other's keys. Breaking the cycle lets work continue.\"")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundColor(.primary.opacity(0.8))
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        Text("Resource management prevents freezes.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            
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
                                .cornerRadius(14)
                        }
                        .padding(.top, 10)
                    }
                    .padding(30)
                    .padding(.bottom, 8) // Slight breathing space inside card
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 30, y: 15)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: 15) // Bias slightly downwards
                .transition(.scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 25)))
                .zIndex(2)
            }
        }
        .onAppear {
            runSimulation()
        }
    }
    
    // MARK: - Computed Properties
    
    var titleText: String {
        switch statusTextIndex {
        case 0: return "Tasks waiting on each other..."
        case 1: return "Deadlock detected."
        case 2: return "Resolution in progress..." // Brief
        default: return "Deadlock resolved."
        }
    }
    
    var titleColor: Color {
        switch statusTextIndex {
        case 1: return .bugWarm // Red for error
        case 3: return .successGreen
        default: return .primary
        }
    }
    
    var subtitleText: String {
        switch statusTextIndex {
        case 0: return "Both tasks need something from the other."
        case 1: return "Neither task can proceed."
        case 2: return "Swapping resources..."
        default: return "Resources were reassigned safely."
        }
    }
    
    var buttonGradient: LinearGradient {
        switch phase {
        case 3:
            return LinearGradient(colors: [.successGreen, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.bugWarm, .orange], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var buttonShadowColor: Color {
        phase == 3 ? .successGreen : .bugWarm
    }
    
    // MARK: - Logic
    
    func runSimulation() {
        // Reset
        phase = 0
        statusTextIndex = 0
        taskAOffset = -100 // Left
        taskBOffset = 100 // Right
        keyAOffset = .zero
        keyBOffset = .zero
        locksOpen = false
        isBlocked = false
        
        // Step 1: Wait State - Try to move forward
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                taskAOffset = -50 // Move closer to blockade
                taskBOffset = 50
            }
        }
        
        // Bounce Back (Blocked)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                taskAOffset = -70
                taskBOffset = 70
            }
        }
        
        // Step 2: Deadlock Detected
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            statusTextIndex = 1 // "Deadlock detected."
            phase = 1 // Enable button
            isBlocked = true
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.8
            }
            triggerShake()
        }
    }
    
    func triggerShake() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.warning)
        
        withAnimation(.linear(duration: 0.1).repeatCount(3, autoreverses: true)) {
            lockAShake = 5
            lockBShake = -5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                lockAShake = 0
                lockBShake = 0
            }
        }
    }
    
    func handleButtonTap() {
        if phase == 3 {
            // Show Dialog
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showDialog = true
            }
        } else {
            // Apply Fix
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation {
                phase = 2
                isBlocked = false // Stop warning glow
                glowIntensity = 0
            }
            
            // Swap Keys Animation
            // A (Left) holds Blue. needs Red (from B).
            // B (Right) holds Red. needs Blue (from A).
            // Blue Key moves Right. Red Key moves Left.
            
            // Coordinates relative to Task:
            // Task A is at x: -70. Task B is at x: 70.
            // Distance is 140.
            
            withAnimation(.easeInOut(duration: 1.0)) {
                keyAOffset = CGSize(width: 140, height: 0) // Blue moves to B
                keyBOffset = CGSize(width: -140, height: 0) // Red moves to A
                keysSwapped = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Unlock
                let unlock = UIImpactFeedbackGenerator(style: .light)
                unlock.impactOccurred()
                
                withAnimation {
                    locksOpen = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Pass Through
                withAnimation(.easeInOut(duration: 1.0)) {
                    taskAOffset = 150 // Move past right
                    taskBOffset = -150 // Move past left
                    statusTextIndex = 3 // Resolved
                    phase = 3
                }
                
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                
                // Show dialog automatically
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showDialog = true
                    }
                }
            }
        }
    }
}

#Preview {
    DeadlockWorld(viewModel: AppViewModel())
}
