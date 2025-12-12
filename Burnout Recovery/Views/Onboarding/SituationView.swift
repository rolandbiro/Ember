import SwiftUI

struct SituationView: View {
    @Binding var selectedSituation: Situation?
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("What's been going on?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)

                    Text("This helps us personalize your experience")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                }
                .padding(.top, 40)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Situation.allCases, id: \.self) { situation in
                            ChoiceButton(
                                text: situation.rawValue,
                                isSelected: selectedSituation == situation
                            ) {
                                selectedSituation = situation
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.visible)

                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(selectedSituation == nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
    }
}
