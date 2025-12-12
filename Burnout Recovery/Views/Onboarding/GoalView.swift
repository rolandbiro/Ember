import SwiftUI

struct GoalView: View {
    @Binding var selectedGoal: Goal?
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("What do you hope to achieve?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)

                    Text("Your goal guides your journey")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                }
                .padding(.top, 40)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            ChoiceButton(
                                text: goal.rawValue,
                                isSelected: selectedGoal == goal
                            ) {
                                selectedGoal = goal
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.visible)

                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(selectedGoal == nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
    }
}
