import SwiftUI

struct SplashView: View {
    @State private var flameScale: CGFloat = 0.5
    @State private var flameOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var sparkles: [Sparkle] = []

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            // Floating sparkles
            ForEach(sparkles) { sparkle in
                Circle()
                    .fill(sparkle.color)
                    .frame(width: sparkle.size, height: sparkle.size)
                    .position(sparkle.position)
                    .opacity(sparkle.opacity)
            }

            VStack(spacing: 24) {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .softPeach.opacity(0.4),
                                    .softPink.opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: glowRadius)

                    // Inner glow pulse
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .softPeach.opacity(0.6),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(flameScale * 1.2)

                    // Flame icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.softPeach, .softPink],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .scaleEffect(flameScale)
                        .opacity(flameOpacity)
                }

                // App name
                Text("Ember")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.starWhite, .softLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Generate sparkles
        generateSparkles()

        // Flame scale and fade in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            flameScale = 1.0
            flameOpacity = 1.0
        }

        // Glow effect
        withAnimation(.easeInOut(duration: 1.0)) {
            glowRadius = 20
        }

        // Text fade in (slightly delayed)
        withAnimation(.easeIn(duration: 0.5).delay(0.4)) {
            textOpacity = 1.0
        }

        // Pulse animation for glow
        withAnimation(.easeInOut(duration: 1.2).repeatCount(2, autoreverses: true).delay(0.5)) {
            glowRadius = 30
        }

        // Complete after animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                flameOpacity = 0
                textOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }

    private func generateSparkles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        for i in 0..<12 {
            let delay = Double(i) * 0.15

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let sparkle = Sparkle(
                    id: UUID(),
                    position: CGPoint(
                        x: CGFloat.random(in: 40...(screenWidth - 40)),
                        y: CGFloat.random(in: screenHeight * 0.2...screenHeight * 0.8)
                    ),
                    size: CGFloat.random(in: 3...8),
                    color: [Color.softLavender, .softPink, .softPeach, .softBlue].randomElement()!,
                    opacity: 0
                )

                sparkles.append(sparkle)

                // Animate sparkle in
                withAnimation(.easeIn(duration: 0.4)) {
                    if let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                        sparkles[index].opacity = Double.random(in: 0.4...0.8)
                    }
                }

                // Animate sparkle out
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        if let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                            sparkles[index].opacity = 0
                        }
                    }
                }
            }
        }
    }
}

struct Sparkle: Identifiable {
    let id: UUID
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}

#Preview {
    SplashView {
        print("Splash completed")
    }
}
