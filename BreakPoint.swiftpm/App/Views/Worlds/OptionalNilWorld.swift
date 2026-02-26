import SwiftUI

struct OptionalNilWorld: View {
    @ObservedObject var viewModel: AppViewModel
    
    // MARK: - States
    @State private var phase = 0
    @State private var showDialog = false
    @State private var scanOffset: CGFloat = -200
    @State private var pulse = false
    @State private var shake = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: 1. Background
            RadialGradient(
                colors: [Color.loopBgCenter, Color.loopBgEdge], // Match Infinite Loop premium BG
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: 2. Header
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(phase == 1 ? .red : .primary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("title-\(phase)")
                        .animation(.easeInOut(duration: 0.5), value: phase)
                    
                    Text(subtitleText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("sub-\(phase)")
                        .animation(.easeInOut(duration: 0.5).delay(0.1), value: phase)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
                
                Spacer()
                
                // MARK: 3. Visualization (Scanning Bar)
                ZStack {
                    // Container Glow
                    RoundedRectangle(cornerRadius: 20)
                        .fill(glowColor.opacity(phase == 1 ? 0.3 : 0.1))
                        .frame(width: 300, height: 60)
                        .blur(radius: 15)
                        .scaleEffect(pulse ? 1.05 : 1.0)
                        .animation(phase == 1 ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: pulse)
                    
                    // The Bar Content
                    ZStack(alignment: .leading) {
                        // Background Track
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.cardBackground.opacity(0.8))
                            .frame(width: 300, height: 60)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(borderColor, lineWidth: 2)
                            )
                        
                        // Scanning Gradient
                        LinearGradient(
                            colors: scanColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Rectangle()
                                .frame(width: 60, height: 60)
                                .blur(radius: 10)
                                .offset(x: scanOffset)
                        )
                        .frame(width: 300, height: 60)
                        .cornerRadius(20)
                        .overlay(
                            // Highlight Line
                            Rectangle()
                                .fill(Color.yellow.opacity(0.6))
                                .frame(width: 2, height: 60)
                                .offset(x: scanOffset)
                                .blendMode(.plusLighter)
                                .mask(RoundedRectangle(cornerRadius: 20))
                        )
                        
                        // Nil Icon / Safe Icon
                        HStack {
                            Spacer()
                            if phase == 1 {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.red.opacity(0.8))
                                    .transition(.scale)
                            } else if phase == 2 {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.successGreen)
                                    .transition(.scale)
                            }
                            Spacer()
                        }
                        .frame(width: 300)
                    }
                    .offset(x: shake ? -2 : 0) // Shake Effect
                }
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: 4. Interaction
                Button(action: handleButtonTap) {
                    Text(phase == 2 ? "Handled Safely ✓" : "Check Value First")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 280)
                        .background(
                            Capsule()
                                .fill(buttonGradient)
                        )
                        .shadow(color: buttonShadowColor.opacity(0.4), radius: 10, y: 4)
                        .scaleEffect(phase == 2 ? 1.0 : 0.98)
                }
                .disabled(phase == 2 || showDialog)
                .padding(.top, 32)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity)
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
                        
                        Text("Force unwrapping nil crashes apps because no value exists in memory.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "gift.fill") // Analogy Icon
                                .font(.system(size: 40))
                                .foregroundColor(.blue.opacity(0.5))
                                .padding(.bottom, 8)
                                
                            Text("\"Like opening a gift box without checking if anything is inside.\"")
                                .font(.system(size: 16, weight: .medium, design: .serif)) // Quote style
                                .foregroundColor(.primary.opacity(0.8))
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        Text("Safe optional handling prevents crashes.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            
                        Button(action: {
                            withAnimation { showDialog = false }
                             viewModel.clearSelection() // Exit to dashboard
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
                            .fill(.regularMaterial) // Glass material
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
            startScan()
            // Auto transition to phase 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if phase == 0 {
                    withAnimation {
                        phase = 1
                        pulse = true
                    }
                    startShake()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var titleText: String {
        switch phase {
        case 0: return "Looking for value..."
        case 1: return "Value is nil"
        case 2: return "Value found safely!"
        default: return ""
        }
    }
    
    var subtitleText: String {
        switch phase {
        case 0: return "Trying to unwrap an Optional."
        case 1: return "Force unwrapping now would crash."
        case 2: return "Optional checked before use."
        default: return ""
        }
    }
    
    var scanColors: [Color] {
        switch phase {
        case 0: return [.blue, .purple, .pink]
        case 1: return [.red.opacity(0.8), .orange] // Warning
        case 2: return [.blue, .successGreen] // Safe
        default: return [.blue, .purple]
        }
    }
    
    var glowColor: Color {
        switch phase {
        case 1: return .red
        case 2: return .successGreen
        default: return .blue
        }
    }
    
    var borderColor: Color {
        switch phase {
        case 1: return .red.opacity(0.5)
        case 2: return .successGreen.opacity(0.5)
        default: return .blue.opacity(0.2)
        }
    }
    
    var buttonGradient: LinearGradient {
        switch phase {
        case 2:
            return LinearGradient(colors: [.successGreen, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        }
    }
     
    var buttonShadowColor: Color {
        phase == 2 ? .successGreen : .blue
    }
    
    // MARK: - Logic
    
    func startScan() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            scanOffset = 300
        }
    }
    
    func startShake() {
        // Shake continuously while in phase 1
        // We can use a timer or repeat animation on offset?
        withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: true)) {
            shake = true // Toggle state that drives offset
        }
    }
    
    func handleButtonTap() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            phase = 2
            pulse = false // Stop warning pulse
            shake = false // Stop shake
        }
        
        // Show dialog after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showDialog = true
            }
        }
    }
}

#Preview {
    OptionalNilWorld(viewModel: AppViewModel())
}
