import SwiftUI

struct ResultsView: View {
    let name: String
    let pace: Pace
    let burnoutLevel: BurnoutLevel
    let personalizedMessage: String
    let onStart: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // Celebration badge
                    VStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.softPeach)

                        Text("First Step Complete!")
                            .font(.headline)
                            .foregroundColor(.softPeach)
                    }
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                    // Burnout level
                    VStack(spacing: 12) {
                        Text(burnoutLevel.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.starWhite)

                        Text(burnoutLevel.message)
                            .font(.body)
                            .foregroundColor(.starWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cosmosPurple)
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)

                    // Personalized message
                    Text(personalizedMessage)
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)

                    // What's next
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's next")
                            .font(.headline)
                            .foregroundColor(.starWhite)

                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.softLavender)
                            Text("\(pace.dailyTaskCount) small task\(pace.dailyTaskCount > 1 ? "s" : "") per day")
                                .foregroundColor(.starWhite.opacity(0.8))
                        }

                        Text("You can adjust your pace anytime.")
                            .font(.caption)
                            .foregroundColor(.starWhite.opacity(0.5))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cosmosPurple.opacity(0.5))
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)

                    Spacer().frame(height: 100)
                }
            }

            // CTA
            VStack {
                Spacer()
                PrimaryButton(title: "Begin Your Journey", action: onStart)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}
