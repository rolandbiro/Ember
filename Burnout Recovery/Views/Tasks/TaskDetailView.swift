import SwiftUI

struct TaskDetailView: View {
    let dailyTask: DailyTask
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOptions: Set<String> = []
    @State private var note: String = ""
    @State private var showCelebration = false
    @State private var sliderValue: Double = 3

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.cosmosPurple)
                                .frame(width: 64, height: 64)

                            Image(systemName: dailyTask.task.category.icon)
                                .font(.title)
                                .foregroundColor(.softLavender)
                        }

                        Text(dailyTask.task.category.displayName)
                            .font(.caption)
                            .foregroundColor(.softLavender)

                        Text(dailyTask.task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.starWhite)

                        Text(dailyTask.task.description)
                            .font(.body)
                            .foregroundColor(.starWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                    taskContent
                        .padding(.horizontal, 24)

                    if dailyTask.task.uiType == .choiceWithNote {
                        noteField
                            .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 100)
                }
            }

            VStack {
                Spacer()
                PrimaryButton(title: "Complete Task", action: completeTask)
                    .disabled(!canComplete)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(
                            colors: [.clear, .cosmosBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    )
            }

            if showCelebration {
                CelebrationView(stardust: dailyTask.task.stardustReward) {
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.starWhite)
                }
            }
        }
    }

    @ViewBuilder
    private var taskContent: some View {
        switch dailyTask.task.uiType {
        case .simpleChoice, .choiceWithNote:
            if let options = dailyTask.task.options {
                VStack(spacing: 12) {
                    ForEach(options) { option in
                        ChoiceButton(
                            text: option.text,
                            isSelected: selectedOptions.contains(option.id)
                        ) {
                            selectedOptions = [option.id]
                        }
                    }
                }
            }

        case .multiSelect:
            if let options = dailyTask.task.options {
                VStack(spacing: 12) {
                    ForEach(options) { option in
                        MultiChoiceButton(
                            text: option.text,
                            isSelected: selectedOptions.contains(option.id)
                        ) {
                            if selectedOptions.contains(option.id) {
                                selectedOptions.remove(option.id)
                            } else {
                                selectedOptions.insert(option.id)
                            }
                        }
                    }
                }
            }

        case .sliderChoice:
            VStack(spacing: 24) {
                Slider(value: $sliderValue, in: 1...7, step: 1)
                    .accentColor(.softLavender)

                if let options = dailyTask.task.options {
                    let index = min(Int(sliderValue) - 1, options.count - 1)
                    Text(options[max(0, index)].text)
                        .font(.headline)
                        .foregroundColor(.softLavender)
                }
            }

        case .timedActivity:
            TimedActivityView(
                duration: dailyTask.task.duration ?? 60,
                onComplete: {
                    selectedOptions = ["completed"]
                }
            )
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add a note (optional)")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))

            TextField("", text: $note, axis: .vertical)
                .foregroundColor(.starWhite)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cosmosPurple)
                )
                .lineLimit(3...6)
        }
    }

    private var canComplete: Bool {
        switch dailyTask.task.uiType {
        case .simpleChoice, .choiceWithNote, .multiSelect:
            return !selectedOptions.isEmpty
        case .sliderChoice:
            return true
        case .timedActivity:
            return selectedOptions.contains("completed")
        }
    }

    private func completeTask() {
        let noteText = note.isEmpty ? nil : note
        TaskService.shared.completeTask(dailyTask, selectedOptions: Array(selectedOptions), note: noteText)

        withAnimation {
            showCelebration = true
        }
    }
}
