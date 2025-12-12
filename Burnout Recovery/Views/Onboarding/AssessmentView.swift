import SwiftUI

struct AssessmentView: View {
    @State private var currentQuestion = 0
    @State private var answers: [Int: Int] = [:]
    let onComplete: (Pace, [Int: Int]) -> Void

    private var questions: [AssessmentQuestion] {
        Assessment.questions
    }

    private var isLastQuestion: Bool {
        currentQuestion == questions.count - 1
    }

    private var lastQuestionAnswered: Bool {
        isLastQuestion && answers[questions[currentQuestion].id] != nil
    }

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Progress
                VStack(spacing: 8) {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))

                    ProgressBar(progress: Double(currentQuestion + 1) / Double(questions.count))
                        .frame(height: 4)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)

                // Question
                VStack(spacing: 16) {
                    Text("In the past month...")
                        .font(.subheadline)
                        .foregroundColor(.softLavender)

                    Text(questions[currentQuestion].text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 20)

                // Options
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<Assessment.answerOptions.count, id: \.self) { index in
                            ChoiceButton(
                                text: Assessment.answerOptions[index],
                                isSelected: answers[questions[currentQuestion].id] == index
                            ) {
                                selectAnswer(index)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.visible)

                // Navigation - only Back and See Results (no Next button)
                HStack(spacing: 16) {
                    if currentQuestion > 0 {
                        SecondaryButton(title: "Back") {
                            withAnimation {
                                currentQuestion -= 1
                            }
                        }
                    }

                    if lastQuestionAnswered {
                        PrimaryButton(title: "See Results") {
                            let pace = Assessment.calculatePace(answers: answers)
                            onComplete(pace, answers)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
                .animation(.easeOut(duration: 0.3), value: lastQuestionAnswered)
            }
        }
    }

    private func selectAnswer(_ index: Int) {
        answers[questions[currentQuestion].id] = index

        // Auto-advance after 0.6s (except last question)
        if !isLastQuestion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    currentQuestion += 1
                }
            }
        }
    }
}
