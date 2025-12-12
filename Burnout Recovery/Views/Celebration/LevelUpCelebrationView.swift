import SwiftUI

struct LevelUpCelebrationView: View {
    let levelInfo: LevelInfo
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var glowPulse = false
    @State private var particles: [StarParticle] = []

    var body: some View {
        ZStack {
            Color.cosmosBackground.opacity(0.95)
                .ignoresSafeArea()

            // Star particles
            ForEach(particles) { particle in
                Image(systemName: "sparkle")
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }

            VStack(spacing: 32) {
                Spacer()

                // Level badge with glow
                ZStack {
                    // Pulsing outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.softLavender.opacity(0.5), .softPink.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 40,
                                endRadius: 120
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(glowPulse ? 1.15 : 1.0)
                        .opacity(glowPulse ? 0.6 : 0.9)

                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.softPeach.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)

                    VStack(spacing: 8) {
                        Text("Level \(levelInfo.level)")
                            .font(.title3)
                            .foregroundColor(.softLavender)

                        Text(levelInfo.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.starWhite)
                    }
                }
                .scaleEffect(showContent ? 1 : 0.3)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 12) {
                    Text("Level Up!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.softPeach)

                    Text("You're making real progress.")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                }
                .opacity(showContent ? 1 : 0)

                Spacer()

                PrimaryButton(title: "Continue", action: onDismiss)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showContent = true
            }

            // Start glow pulse
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }

            // Spawn star particles
            spawnParticles()

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    private func spawnParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerY = screenHeight * 0.35

        for i in 0..<20 {
            let delay = Double(i) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let particle = StarParticle(
                    position: CGPoint(x: screenWidth / 2, y: centerY),
                    size: CGFloat.random(in: 8...20),
                    color: [Color.softLavender, .softPink, .softPeach, .softBlue].randomElement()!
                )
                particles.append(particle)

                // Animate particle outward
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 100...200)
                let targetX = screenWidth / 2 + cos(angle) * distance
                let targetY = centerY + sin(angle) * distance - 50

                withAnimation(.easeOut(duration: Double.random(in: 1.0...1.8))) {
                    if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                        particles[index].position = CGPoint(x: targetX, y: targetY)
                        particles[index].opacity = 0
                    }
                }
            }
        }
    }
}

struct StarParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var opacity: Double = 1.0
}
