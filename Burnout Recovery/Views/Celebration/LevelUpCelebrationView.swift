import SwiftUI

struct LevelUpCelebrationView: View {
    let levelInfo: LevelInfo
    let onDismiss: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.cosmosBackground.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Level badge
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.softLavender.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)

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

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
