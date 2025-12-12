import SwiftUI

enum OnboardingStep {
    case name
    case situation
    case goal
    case assessment
    case ready
}

struct OnboardingCoordinator: View {
    @State private var step: OnboardingStep = .name
    @State private var name: String = ""
    @State private var situation: Situation?
    @State private var goal: Goal?
    @State private var pace: Pace = .steady

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            switch step {
            case .name:
                NameInputView(name: $name) {
                    withAnimation { step = .situation }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .situation:
                SituationView(selectedSituation: $situation) {
                    withAnimation { step = .goal }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .goal:
                GoalView(selectedGoal: $goal) {
                    withAnimation { step = .assessment }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .assessment:
                AssessmentView { calculatedPace in
                    pace = calculatedPace
                    withAnimation { step = .ready }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .ready:
                ReadyView(name: name, pace: pace) {
                    saveAndComplete()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }

    private func saveAndComplete() {
        guard let situation = situation, let goal = goal else { return }
        UserService.shared.completeOnboarding(name: name, situation: situation, goal: goal)
        UserService.shared.completeAssessment(pace: pace)
        onComplete()
    }
}

struct ReadyView: View {
    let name: String
    let pace: Pace
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.softPeach)

                VStack(spacing: 16) {
                    Text("Your path is ready, \(name)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)

                    Text("We've set you up with a \(pace.displayName.lowercased()) pace — \(pace.dailyTaskCount) task\(pace.dailyTaskCount > 1 ? "s" : "") per day.")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Text("You can adjust this anytime in settings.")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.5))
                }

                Spacer()

                PrimaryButton(title: "Begin Your Journey", action: onStart)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
    }
}
