import SwiftUI

struct WelcomeView: View {
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.softPeach.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.softPeach)
                }

                VStack(spacing: 16) {
                    Text("Welcome to Ember")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)

                    Text("Your spark is still there")
                        .font(.title3)
                        .foregroundColor(.softLavender)
                        .italic()
                }

                Spacer()

                PrimaryButton(title: "Get Started") {
                    showOnboarding = true
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}
