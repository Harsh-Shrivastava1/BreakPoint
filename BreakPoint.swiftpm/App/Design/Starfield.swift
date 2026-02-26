import SwiftUI

struct Starfield: View {
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if colorScheme == .dark {
                    ForEach(0..<50, id: \.self) { i in
                        Star(geo: geo)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct Star: View {
    let geo: GeometryProxy
    @State private var opacity: Double = Double.random(in: 0.1...0.4)
    @State private var scale: CGFloat = CGFloat.random(in: 0.5...1.0)
    
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let duration: Double
    
    init(geo: GeometryProxy) {
        self.geo = geo
        self.x = CGFloat.random(in: 0...geo.size.width)
        self.y = CGFloat.random(in: 0...geo.size.height)
        self.size = CGFloat.random(in: 1...3)
        self.duration = Double.random(in: 2...4)
    }
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.4...0.8)
                    scale = CGFloat.random(in: 1.0...1.5)
                }
            }
    }
}
