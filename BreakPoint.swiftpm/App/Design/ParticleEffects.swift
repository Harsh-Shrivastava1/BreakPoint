import SwiftUI

struct ParticleSystem: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    var contextCopy = context
                    contextCopy.opacity = particle.opacity
                    contextCopy.fill(
                        Path(ellipseIn: CGRect(x: particle.x * size.width, y: particle.y * size.height, width: particle.size, height: particle.size)),
                        with: .color(.white)
                    )
                }
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    func generateParticles() {
        for _ in 0..<50 {
            particles.append(Particle(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                size: Double.random(in: 1...3),
                opacity: Double.random(in: 0.1...0.5)
            ))
        }
    }
}

struct Particle: Hashable {
    var x: Double
    var y: Double
    var size: Double
    var opacity: Double
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ParticleSystem()
    }
}
