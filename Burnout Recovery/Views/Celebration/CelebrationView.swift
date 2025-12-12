import SwiftUI

struct CelebrationView: View {
    let stardust: Int
    let onDismiss: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.cosmosBackground.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
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

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.softPeach)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 16) {
                    Text("Well done!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)

                    StardustRewardView(amount: stardust)
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
