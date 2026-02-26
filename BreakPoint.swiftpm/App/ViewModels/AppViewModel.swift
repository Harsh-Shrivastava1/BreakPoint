import SwiftUI

class AppViewModel: ObservableObject {
    enum FlowState {
        case intro
        case purpose
        case dashboard
    }
    
    @Published var flowState: FlowState = .intro
    @Published var isNavigatingBack: Bool = false
    @Published var selectedBugId: UUID? = nil
    @Published var bugs: [Bug] = []
    
    init() {
        self.bugs = BugType.allCases.map { type in
            Bug(
                type: type,
                name: type.rawValue,
                description: self.description(for: type),
                iconName: self.icon(for: type)
            )
        }
    }
    
    func selectBug(_ bug: Bug) {
        withAnimation(AnimationSystem.springBounce) {
            selectedBugId = bug.id
        }
    }
    
    func advanceFlow() {
        isNavigatingBack = false
        withAnimation(.easeInOut(duration: 0.5)) {
            switch flowState {
            case .intro: flowState = .purpose
            case .purpose: flowState = .dashboard
            case .dashboard: break
            }
        }
    }
    
    func goBack() {
        isNavigatingBack = true
        withAnimation(.easeInOut(duration: 0.5)) {
            switch flowState {
            case .purpose: flowState = .intro
            case .dashboard: flowState = .purpose
            default: break
            }
        }
    }
    
    func clearSelection() {
        withAnimation(.easeInOut(duration: 0.4)) {
            selectedBugId = nil
        }
    }
    
    var selectedBug: Bug? {
        bugs.first { $0.id == selectedBugId }
    }
    
    func markFixed(bugId: UUID) {
        if let index = bugs.firstIndex(where: { $0.id == bugId }) {
            bugs[index].isFixed = true
        }
    }
    
    // MARK: - Data Helpers
    
    private func description(for type: BugType) -> String {
        switch type {
        case .optionalNil: return "Force unwrapping a missing value."
        case .infiniteLoop: return "A loop that never finds an exit."
        case .stateMismatch: return "When UI doesn't match the data."
        case .retainCycle: return "Two objects holding onto each other."
        case .raceCondition: return "Tasks fighting for the same resource."
        case .offByOne: return "Missing the target by just one."
        case .deadlock: return "Two tasks waiting for each other forever."
        case .logicError: return "Code runs, but the answer is wrong."
        case .missingValue: return "Sometimes data is missing."
        }
    }
    
    private func icon(for type: BugType) -> String {
        switch type {
        case .optionalNil: return "questionmark.square.dashed"
        case .infiniteLoop: return "arrow.triangle.2.circlepath"
        case .stateMismatch: return "switch.2"
        case .retainCycle: return "arrow.triangle.pull"
        case .raceCondition: return "figure.run"
        case .offByOne: return "1.square"
        case .deadlock: return "lock.circle"
        case .logicError: return "exclamationmark.bubble"
        case .missingValue: return "shippingbox.fill"
        }
    }
}
