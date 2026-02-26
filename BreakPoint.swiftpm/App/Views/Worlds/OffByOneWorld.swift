import SwiftUI

struct OffByOneWorld: View {
    @ObservedObject var viewModel: AppViewModel
    
    // MARK: - States
    @State private var phase = 0 // 0: Running/Error, 1: Fixing/Fixed
    @State private var showDialog = false
    
    // Animation Values
    @State private var focusIndex: Int = -1
    @State private var errorShake: CGFloat = 0
    @State private var statusTextIndex = 0
    @State private var validRangeGlow = false
    
    // Data
    let items = ["0", "1", "2"]
    
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
                        .frame(maxWidth: 280)
                        .foregroundColor(titleColor)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("title-\(statusTextIndex)")
                        .animation(.easeInOut(duration: 0.5), value: statusTextIndex)
                    
                    Text(subtitleText)
                        .font(.body)
                        .foregroundColor(.secondary.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 260)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("sub-\(statusTextIndex)")
                        .animation(.easeInOut(duration: 0.5).delay(0.1), value: statusTextIndex)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // MARK: 3. Visualization
                HStack(spacing: 16) {
                    Spacer()

                    // Valid Indices [0, 1, 2]
                    ForEach(0..<3) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(focusIndex == index ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .shadow(color: validRangeGlow ? Color.successGreen.opacity(0.4) : .clear, radius: 10)
                                .scaleEffect(focusIndex == index ? 1.05 : 1.0)
                            
                            Text("\(index)")
                                .font(.title.bold())
                                .foregroundColor(.primary)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Invalid Index [3]
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(focusIndex == 3 ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 70, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(focusIndex == 3 ? Color.red : Color.gray.opacity(0.3), lineWidth: 3)
                                    .opacity(phase == 1 ? 0 : 1) // Hide border when fixed
                            )
                            .offset(x: errorShake)
                            .opacity(phase == 1 ? 0.3 : 1.0) // Dim heavily when fixed
                        
                        if focusIndex == 3 && phase == 0 {
                             Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        } else {
                            Text("3")
                                .font(.title.bold())
                                .foregroundColor(phase == 1 ? .gray.opacity(0.3) : .gray)
                        }
                    }
                    Spacer()
                }

                .padding(.bottom, 40)
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: 4. Interaction Button
                Button(action: handleButtonTap) {
                    Text(phase == 1 ? "Continue" : "Adjust Range")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 260, height: 52)
                        .background(
                            Capsule()
                                .fill(buttonGradient)
                        )
                        .shadow(color: buttonShadowColor.opacity(0.4), radius: 10, y: 4)
                        .scaleEffect(phase == 1 ? 1.0 : 0.98)
                }
                .disabled(showDialog)
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
                        
                        Text("Off-by-one errors happen when loops run one step too far.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "list.number")
                                .font(.system(size: 40))
                                .foregroundColor(.blue.opacity(0.5))
                                .padding(.bottom, 8)
                                
                            Text("\"Like counting 3 items but trying to grab the 4th.\"")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundColor(.primary.opacity(0.8))
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        Text("Small counting mistakes can crash apps.")
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
        case 0: return "Counting items…"
        case 1: return "Index out of range!"
        case 2: return "Adjusting loop limit…"
        default: return "Range corrected."
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
        case 0: return "Observe carefully."
        case 1: return "Tried to access beyond limit."
        case 2: return "Stopping before overflow."
        default: return "All indices valid."
        }
    }
    
    var buttonGradient: LinearGradient {
        switch phase {
        case 1:
            return LinearGradient(colors: [.successGreen, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var buttonShadowColor: Color {
        phase == 1 ? .successGreen : .blue
    }
    
    // MARK: - Logic
    
    func runSimulation() {
        // Reset
        focusIndex = -1
        phase = 0
        statusTextIndex = 0
        validRangeGlow = false
        
        // Start counting sequence
        let delayStep = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.35)) { focusIndex = 0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + delayStep) {
            withAnimation(.easeInOut(duration: 0.35)) { focusIndex = 1 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + delayStep * 2) {
            withAnimation(.easeInOut(duration: 0.35)) { focusIndex = 2 }
        }
        
        // Error Step
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + delayStep * 3) {
            withAnimation(.easeInOut(duration: 0.35)) {
                focusIndex = 3
                statusTextIndex = 1 // "Index out of range!"
            }
            triggerErrorShake()
        }
    }
    
    func triggerErrorShake() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.error)
        
        withAnimation(.linear(duration: 0.1).repeatCount(3, autoreverses: true)) {
            errorShake = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { errorShake = 0 }
        }
    }
    
    func handleButtonTap() {
        if phase == 1 {
            // Show Dialog
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showDialog = true
            }
        } else {
            // Apply Fix
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.5)) {
                phase = 1
                statusTextIndex = 2 // "Adjusting..."
                focusIndex = 2 // Snap back to valid range
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    statusTextIndex = 3 // "Range corrected."
                    validRangeGlow = true
                }
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                
                // Show dialog automatically
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showDialog = true
                    }
                }
            }
        }
    }
}

#Preview {
    OffByOneWorld(viewModel: AppViewModel())
}
