import Foundation

enum AnimationState {
    case running    // System is running normally (or buggy behavior loop)
    case paused     // Waiting for user interaction
    case fixing     // User triggered the fix
    case fixed      // Correct behavior running
}
