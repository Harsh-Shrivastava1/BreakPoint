import SwiftUI

struct RaceConditionWorld: View {
    @ObservedObject var viewModel: AppViewModel
    
    // MARK: - States
    @State private var phase = 0 // 0: Race Condition, 1: Fixed/Synchronized
    @State private var showDialog = false
    
    // Animation Values
    @State private var taskAOffset: CGFloat = -150
    @State private var taskBOffset: CGFloat = 150
    @State private var dataScale: CGFloat = 1.0
    @State private var dataColor: Color = .blue
    @State private var lockOffset: CGFloat = -200 // Starts above screen
    @State private var isColliding = false
    @State private var statusTextIndex = 0
    
    // Timers
    let collisionTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
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
                        .foregroundColor(phase == 0 ? .orange : .successGreen)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("title-\(phase)-\(statusTextIndex)")
                        .animation(.easeInOut(duration: 0.5), value: statusTextIndex)
                    
                    Text(subtitleText)
                        .font(.body)
                        .foregroundColor(.secondary.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 260)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id("sub-\(phase)")
                        .animation(.easeInOut(duration: 0.5).delay(0.1), value: phase)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // MARK: 3. Visualization
                ZStack {
                    // Central Data Node
                    Circle()
                        .fill(dataColor)
                        .frame(width: 96, height: 96)
                        .overlay(
                            Text("Data")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
                        .scaleEffect(dataScale)
                        .overlay(
                            // Collision Pulse Ring
                            Circle()
                                .stroke(Color.red.opacity(isColliding ? 0.6 : 0), lineWidth: 4)
                                .scaleEffect(isColliding ? 1.4 : 1.0)
                                .opacity(isColliding ? 0 : 1)
                                .animation(isColliding ? .easeOut(duration: 0.6) : .default, value: isColliding)
                        )
                    
                    // The Lock (Initially hidden/high)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.successGreen)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .offset(y: lockOffset) // Drops to 0 (center)
                        .zIndex(2)
                    
                    // Task A (Left)
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 48, height: 48)
                            .overlay(Text("A").bold().foregroundColor(.white))
                        Text("Task A")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .offset(x: taskAOffset)
                    
                    // Task B (Right)
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 48, height: 48)
                            .overlay(Text("B").bold().foregroundColor(.white))
                        Text("Task B")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .offset(x: taskBOffset)
                }
                .frame(height: 150)
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: 4. Interaction Button
                Button(action: handleButtonTap) {
                    Text(phase == 1 ? "Continue" : "Add Lock")
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
                        
                        Text("Race conditions cause unpredictable results. When multiple tasks modify the same data at once, the outcome depends on timing.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "figure.run.square.stack")
                                .font(.system(size: 40))
                                .foregroundColor(.blue.opacity(0.5))
                                .padding(.bottom, 8)
                                
                            Text("\"Like two people writing on the same paper at the same time. Locks ensure one task accesses data at a time.\"")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundColor(.primary.opacity(0.8))
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        Text("Understanding concurrency leads to stable apps.")
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
            startRace()
        }
        .onReceive(collisionTimer) { _ in
            if phase == 0 {
                cycleRaceStatus()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var titleText: String {
        if phase == 0 {
            switch statusTextIndex {
            case 0: return "Multiple tasks accessing data…"
            case 1: return "Simultaneous writes detected…"
            default: return "Race condition risk rising…"
            }
        } else {
            switch statusTextIndex {
            case 0: return "Applying lock…" // Briefly shown
            case 1: return "Access synchronized…" // Tasks taking turns
            default: return "System stable." // Final state
            }
        }
    }
    
    var subtitleText: String {
        phase == 0 ? "Both tasks try to modify the same data at once." : "Locks ensure one task accesses data at a time."
    }
    
    var buttonGradient: LinearGradient {
        switch phase {
        case 1:
            return LinearGradient(colors: [.successGreen, Color(hex: "34C759")], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.blue, .orange], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var buttonShadowColor: Color {
        phase == 1 ? .successGreen : .blue
    }
    
    // MARK: - Logic
    
    func startRace() {
        // Continuous cycle of colliding
        // Tasks move in
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            taskAOffset = -55 // Close to center
            taskBOffset = 55
        }
        
        // Data shakes/colors when they are close
        // Since we can't easily sync exact frame in pure SwiftUI with repeat, 
        // we'll use a visual simulation that distinctively shows conflict.
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            dataColor = .red
            dataScale = 0.95
        }
        
        // Trigger pulse manually on timer to sync somewhat
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            guard phase == 0 else { timer.invalidate(); return }
            isColliding = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isColliding = false
            }
        }
    }
    
    func cycleRaceStatus() {
        withAnimation {
            statusTextIndex = (statusTextIndex + 1) % 3
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
            
            // 1. Reset text index for fix flow
            statusTextIndex = 0 
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                phase = 1
                lockOffset = 0 // Drop Lock
                dataColor = .blue // Reset data color
                dataScale = 1.0
                isColliding = false
                
                // Reset tasks to start
                taskAOffset = -150
                taskBOffset = 150
            }
            
            // 2. Demonstration of Synchronized Access
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { statusTextIndex = 1 } // "Access synchronized..."
                
                // Task A enters
                withAnimation(.easeInOut(duration: 0.8)) {
                    taskAOffset = -55
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                // Task A leaves
                withAnimation(.easeInOut(duration: 0.8)) {
                    taskAOffset = -150
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                // Task B enters
                withAnimation(.easeInOut(duration: 0.8)) {
                    taskBOffset = 55
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
                // Task B leaves
                withAnimation(.easeInOut(duration: 0.8)) {
                    taskBOffset = 150
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                 withAnimation { statusTextIndex = 2 } // "System stable."
                 let success = UINotificationFeedbackGenerator()
                 success.notificationOccurred(.success)
                
                // Show dialog automatically
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showDialog = true
                    }
                }
            }
        }
    }
}

#Preview {
    RaceConditionWorld(viewModel: AppViewModel())
}
