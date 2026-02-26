import SwiftUI

struct StateMismatchWorld: View {
    @ObservedObject var viewModel: AppViewModel
    
    // MARK: - States
    @State private var phase = 0 // 0: Running (Mismatch starting), 1: Mismatch Detected, 2: Fixed
    @State private var showDialog = false
    
    // UI/State Simulation
    @State private var toggleIsOn = false
    @State private var lightIsOn = false
    
    // Animations
    @State private var pulseToggle = false
    @State private var lightShake: CGFloat = 0
    @State private var contentScale: CGFloat = 1.0
    
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
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(phase == 1 ? .orange : .primary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("title-\(phase)")
                        .animation(.easeInOut(duration: 0.5), value: phase)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    Text(subtitleText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("sub-\(phase)")
                        .animation(.easeInOut(duration: 0.5).delay(0.1), value: phase)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                
                Spacer()
               
                // MARK: 3. Visualization (Toggle & Light)
                HStack {
                    Spacer()
                    
                    HStack(spacing: 60) {
                        // LEFT: The UI (Switch)
                        VStack(spacing: 16) {
                            ZStack {
                                // Switch Track
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(toggleIsOn ? Color.successGreen : Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 60)
                                    .animation(.easeInOut(duration: 0.3), value: toggleIsOn)
                                    .shadow(color: toggleIsOn ? Color.successGreen.opacity(0.4) : .clear, radius: 10)
                                
                                // Switch Knob
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 52, height: 52)
                                    .shadow(radius: 2)
                                    .offset(x: toggleIsOn ? 20 : -20)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: toggleIsOn)
                            }
                            .fixedSize()
                            .scaleEffect(pulseToggle ? 1.05 : 1.0)
                            .animation(phase == 0 ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: pulseToggle)
                            
                            Text("UI (Switch)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .fixedSize()
                        
                        // Connection Line (Broken or Solid)
                        Rectangle()
                            .fill(phase == 2 ? Color.successGreen : Color.gray.opacity(0.2))
                            .frame(width: 40, height: 4)
                            .overlay(
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .background(Color.white.clipShape(Circle()))
                                    .opacity(phase == 1 ? 1 : 0)
                                    .scaleEffect(phase == 1 ? 1 : 0.5)
                                    .animation(.spring, value: phase)
                                    .fixedSize()
                            )
                            .fixedSize()
                        
                        // RIGHT: The State (Light)
                        VStack(spacing: 16) {
                            Image(systemName: lightIsOn ? "lightbulb.fill" : "lightbulb")
                                .font(.system(size: 70))
                                .foregroundColor(lightIsOn ? .yellow : .gray.opacity(0.3))
                                .shadow(color: lightIsOn ? .yellow.opacity(0.6) : .clear, radius: 20)
                                .scaleEffect(lightIsOn ? 1.1 : 1.0)
                                .offset(x: lightShake) // Shake animation
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: lightIsOn)
                                .fixedSize()
                            
                            Text("State (Data)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .fixedSize()
                    }
                    .frame(maxWidth: 320)
                    
                    Spacer()
                }

                .scaleEffect(contentScale)
                .padding(.top, 24)
                .padding(.bottom, 40)
                
                Spacer()
                
                // MARK: 4. Interaction Button
                Group {
                    if phase > 0 {
                        Button(action: handleButtonTap) {
                            Text(phase == 2 ? "Continue" : "Sync State")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 32)
                                .frame(maxWidth: 260)
                                .background(
                                    Capsule()
                                        .fill(buttonGradient)
                                )
                                .shadow(color: buttonShadowColor.opacity(0.4), radius: 10, y: 4)
                                .scaleEffect(phase == 2 ? 1.0 : 0.98)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        Color.clear.frame(height: 52)
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .blur(radius: showDialog ? 10 : 0)

            
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
                        
                        Text("When your UI changes without updating the source of truth, the interface and data fall out of sync.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "switch.2")
                                .font(.system(size: 40))
                                .foregroundColor(.blue.opacity(0.5))
                                .padding(.bottom, 8)
                                
                            Text("\"Like flipping a switch that isn’t connected to the light.\"")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundColor(.primary.opacity(0.8))
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        Text("Always bind UI to real state.")
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
        switch phase {
        case 0: return "State updating..."
        case 1: return "State mismatch detected"
        case 2: return "System consistent"
        default: return ""
        }
    }
    
    var subtitleText: String {
        switch phase {
        case 0: return "UI and data are trying to sync."
        case 1: return "UI changed, but state didn’t."
        case 2: return "UI and state are aligned."
        default: return ""
        }
    }
    
    var buttonGradient: LinearGradient {
        switch phase {
        case 2:
            return LinearGradient(colors: [.successGreen, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var buttonShadowColor: Color {
        phase == 2 ? .successGreen : .orange
    }
    
    // MARK: - Logic
    
    func runSimulation() {
        // Initial clean state
        toggleIsOn = false
        lightIsOn = false
        phase = 0
        
        // 1. User Toggles Switch (UI updates, State doesn't)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                toggleIsOn = true
            }
            pulseToggle = true // Start pulsing to show activity/waiting
        }
        
        // 2. Mismatch Logic kicks in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut) {
                phase = 1
                pulseToggle = false
            }
            startShake()
        }
    }
    
    func startShake() {
        // Subtle shake of the lightbulb to indicate it SHOULD have turned on
        let shakeAnimation = Animation.linear(duration: 0.1).repeatCount(3, autoreverses: true)
        withAnimation(shakeAnimation) {
            lightShake = 5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(shakeAnimation) {
                lightShake = 0
            }
        }
    }
    
    func handleButtonTap() {
        if phase == 1 {
            // Apply Fix
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                phase = 2
                lightIsOn = true
                contentScale = 1.05 // Subtle joyous pop
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                contentScale = 1.0 // Settle back
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                 let success = UINotificationFeedbackGenerator()
                 success.notificationOccurred(.success)
            }
        } else {
            // Show Dialog
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showDialog = true
            }
        }
    }
}

#Preview {
    StateMismatchWorld(viewModel: AppViewModel())
}
