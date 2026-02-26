import SwiftUI

@main
struct BreakpointApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background
                // Background
                Color.adaptiveBackground.ignoresSafeArea()
                
                switch viewModel.flowState {
                case .intro:
                    IntroView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                case .purpose:
                    PurposeView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                case .dashboard:
                    DashboardContent(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewModel.flowState)
        }
    }
}

// Extracted Dashboard logic to keep main clean and allow easy transition
struct DashboardContent: View {
    @ObservedObject var viewModel: AppViewModel
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            // Background
            BlobBackground()
            
            if let selectedBug = viewModel.selectedBug {
                // World View
                ZStack(alignment: .topLeading) {
                    // World Background (full-screen, each World controls its own canvas)
                    Color.cardBackground.opacity(0.95)
                        .ignoresSafeArea()
                        .matchedGeometryEffect(id: selectedBug.id, in: namespace)
                    
                    // Routing to specific worlds
                    ZStack {
                        switch selectedBug.type {
                        case .optionalNil:
                            OptionalNilWorld(viewModel: viewModel)
                        case .infiniteLoop:
                            InfiniteLoopWorld(viewModel: viewModel)
                        case .stateMismatch:
                            StateMismatchWorld(viewModel: viewModel)
                        case .retainCycle:
                            RetainCycleWorld(viewModel: viewModel)
                        case .raceCondition:
                            RaceConditionWorld(viewModel: viewModel)
                        case .offByOne:
                            OffByOneWorld(viewModel: viewModel)
                        case .deadlock:
                            DeadlockWorld(viewModel: viewModel)
                        case .logicError:
                            LogicErrorWorld(viewModel: viewModel)
                        case .missingValue:
                            MissingValueWorld(viewModel: viewModel)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95).animation(.easeOut(duration: 0.3))))
                    
                    // ── Back Button (top-left, covers all worlds) ────────────
                    VStack {
                        HStack {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.clearSelection()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary.opacity(0.80))
                                    .frame(width: 34, height: 34)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 32)
                            .padding(.top, 60)
                            Spacer()
                        }
                        Spacer()
                    }
                    .zIndex(10) // always above world content
                }
                // ── Edge swipe to go back (mirrors the back button) ──
                .edgeSwipeBack { viewModel.clearSelection() }
                .zIndex(1)
            } else {
                // Dashboard
                DashboardView(viewModel: viewModel, namespace: namespace)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.animation(.easeOut(duration: 0.1)) // Fade out quick
                    ))
            }
        }
        // Use animation system for the layout change
        .animation(AnimationSystem.springSmooth, value: viewModel.selectedBugId)
    }
}
