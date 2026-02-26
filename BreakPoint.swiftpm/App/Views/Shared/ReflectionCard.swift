import SwiftUI

struct ReflectionCard: View {
    let title: String = "Reflection"
    let insight: String
    let analogy: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.fixCool)
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.textSecondary)
                Spacer()
            }
            
            Text(insight)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
                    .padding(.top, 2)
                    
                Text(analogy)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .italic()
                    .lineSpacing(4)
            }
            .padding(.top, 4)
            
            Button(action: onContinue) {
                Text("Continue Exploring")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.fixCool)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            
            Text("Understanding bugs builds better developers.")
                .font(.caption2)
                .foregroundColor(.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .padding(24)
        .glassPanel()
        .padding(20)
    }
}
