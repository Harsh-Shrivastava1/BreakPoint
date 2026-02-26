import SwiftUI

struct SystemStatusText: View {
    let text: String
    let isWarning: Bool
    
    var body: some View {
        Text(text)
            .systemStatus(isWarning: isWarning)
            .id(text) // Identity helps SwiftUI trigger transition on change
            .transition(.opacity.animation(.easeInOut(duration: 0.5)))
    }
}
