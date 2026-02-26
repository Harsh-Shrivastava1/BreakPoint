import SwiftUI

struct Bug: Identifiable, Hashable {
    let id: UUID = UUID()
    let type: BugType
    let name: String
    let description: String
    let iconName: String
    var isFixed: Bool = false
    
    // For grid layout
    var color: Color {
        isFixed ? .fixCool : .bugWarm
    }
}

enum BugType: String, CaseIterable {
    case infiniteLoop = "Infinite Loop"
    case stateMismatch = "State Mismatch"
    case retainCycle = "Retain Cycle"
    case raceCondition = "Race Condition"
    case offByOne = "Off By One"
    case deadlock = "Deadlock"
    case logicError = "Logic Error"
    case missingValue = "Missing Value"
    case optionalNil = "Optional Nil"
}
