# Assessment UX Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix assessment UX issues and empty Home screen bug based on user testing feedback.

**Architecture:** Modify existing SwiftUI views with improved animations, add BurnoutLevel enum to Assessment model, fix TaskService initialization timing.

**Tech Stack:** SwiftUI, Combine, UserDefaults

---

## Task 1: Fix ChoiceButton Selection Animation

**Files:**
- Modify: `Components/ChoiceButton.swift`

**Step 1: Add scale animation state to ChoiceButton**

```swift
import SwiftUI

struct ChoiceButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
            action()
        }) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(isSelected ? .cosmosBackground : .starWhite)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cosmosBackground)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.softLavender : Color.cosmosPurple)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.softLavender.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 1.03 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
```

**Step 2: Test visually in simulator**

Run the app, go through onboarding to Assessment, tap an option.
Expected: Button scales up briefly (1.03x), checkmark fades in smoothly.

**Step 3: Commit**

```bash
git add Components/ChoiceButton.swift
git commit -m "feat: add subtle scale animation to ChoiceButton selection"
```

---

## Task 2: Update AssessmentView Transitions

**Files:**
- Modify: `Views/Onboarding/AssessmentView.swift`

**Step 1: Update selectAnswer delay and remove Next button**

Replace the entire AssessmentView with:

```swift
import SwiftUI

struct AssessmentView: View {
    @State private var currentQuestion = 0
    @State private var answers: [Int: Int] = [:]
    @State private var showResults = false
    let onComplete: (Pace) -> Void

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
                // Progress header
                VStack(spacing: 8) {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))

                    ProgressBar(progress: Double(currentQuestion + 1) / Double(questions.count))
                        .frame(height: 4)
                        .padding(.horizontal, 40)
                        .animation(.easeInOut(duration: 0.3), value: currentQuestion)
                }
                .padding(.top, 20)

                // Question content with transition
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
                        .id(currentQuestion) // Force view refresh for transition
                }
                .padding(.top, 20)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                // Answer options
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
                }

                // Navigation
                HStack(spacing: 16) {
                    if currentQuestion > 0 {
                        SecondaryButton(title: "Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentQuestion -= 1
                            }
                        }
                    }

                    // See Results button - only shows after last question answered
                    if lastQuestionAnswered {
                        PrimaryButton(title: "See Results") {
                            let pace = Assessment.calculatePace(answers: answers)
                            onComplete(pace)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: lastQuestionAnswered)
            }
        }
    }

    private func selectAnswer(_ index: Int) {
        answers[questions[currentQuestion].id] = index

        // Auto-advance after delay (except on last question)
        if !isLastQuestion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentQuestion += 1
                }
            }
        }
    }
}
```

**Step 2: Test in simulator**

Run the app, go through Assessment:
- Expected: No Next button, auto-advances after 0.6s
- Expected: Last question shows "See Results" after selecting answer
- Expected: Smooth slide transitions between questions

**Step 3: Commit**

```bash
git add Views/Onboarding/AssessmentView.swift
git commit -m "feat: improve assessment transitions, remove Next button"
```

---

## Task 3: Add BurnoutLevel to Assessment Model

**Files:**
- Modify: `Models/Assessment.swift`

**Step 1: Add BurnoutLevel enum and calculation**

Add after the existing code:

```swift
enum BurnoutLevel: String {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"

    var title: String {
        switch self {
        case .mild: return "Mild Signs"
        case .moderate: return "Moderate Signs"
        case .severe: return "Strong Signs"
        }
    }

    var message: String {
        switch self {
        case .mild: return "You're on the right track - prevention mode"
        case .moderate: return "Pay attention to yourself - time to slow down"
        case .severe: return "You need support - we'll go step by step"
        }
    }

    var icon: String {
        switch self {
        case .mild: return "leaf.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .severe: return "heart.fill"
        }
    }

    var color: String {
        switch self {
        case .mild: return "softLavender"
        case .moderate: return "softPeach"
        case .severe: return "softPeach"
        }
    }
}

extension Assessment {
    static func calculateBurnoutLevel(answers: [Int: Int]) -> BurnoutLevel {
        var exhaustionScore = 0
        var cynicismScore = 0
        var efficacyScore = 0

        for (questionId, answerIndex) in answers {
            guard let question = questions.first(where: { $0.id == questionId }) else { continue }

            switch question.dimension {
            case .exhaustion:
                exhaustionScore += answerIndex
            case .cynicism:
                cynicismScore += answerIndex
            case .efficacy:
                efficacyScore += (6 - answerIndex)
            }
        }

        let totalScore = exhaustionScore + cynicismScore + efficacyScore

        if totalScore >= 36 {
            return .severe
        } else if totalScore >= 18 {
            return .moderate
        } else {
            return .mild
        }
    }

    static func personalizedMessage(situation: Situation?, goal: Goal?) -> String {
        guard let situation = situation, let goal = goal else {
            return "We'll take it step by step together."
        }

        let situationText: String
        switch situation {
        case .overwhelmed:
            situationText = "work is overwhelming you"
        case .exhausted:
            situationText = "you feel emotionally exhausted"
        case .lostMotivation:
            situationText = "you've lost motivation for things you enjoyed"
        case .alwaysTired:
            situationText = "you're always tired"
        case .prevention:
            situationText = "you want to prevent burnout"
        }

        let goalText: String
        switch goal {
        case .recoverEnergy:
            goalText = "recover your energy"
        case .findBalance:
            goalText = "find balance"
        case .feelMyself:
            goalText = "feel like yourself again"
        case .healthyHabits:
            goalText = "build healthier habits"
        }

        return "You said that \(situationText), and you want to \(goalText). We'll take small steps together."
    }
}
```

**Step 2: Commit**

```bash
git add Models/Assessment.swift
git commit -m "feat: add BurnoutLevel enum and personalized messaging"
```

---

## Task 4: Create Enhanced ResultsView

**Files:**
- Create: `Views/Onboarding/ResultsView.swift`
- Modify: `Views/Onboarding/OnboardingCoordinator.swift`

**Step 1: Create ResultsView**

```swift
import SwiftUI

struct ResultsView: View {
    let name: String
    let pace: Pace
    let burnoutLevel: BurnoutLevel
    let personalizedMessage: String
    let onStart: () -> Void

    @State private var showContent = false
    @State private var showBadge = false
    @State private var showSparkles = false

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            // Sparkle effect
            if showSparkles {
                SparkleOverlay()
                    .transition(.opacity)
            }

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    // First Step Badge
                    if showBadge {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.softPeach.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "star.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.softPeach)
                            }
                            .scaleEffect(showBadge ? 1 : 0.5)

                            Text("First Step Complete!")
                                .font(.headline)
                                .foregroundColor(.softPeach)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    if showContent {
                        // Burnout Level Card
                        VStack(spacing: 16) {
                            Image(systemName: burnoutLevel.icon)
                                .font(.system(size: 32))
                                .foregroundColor(burnoutLevel == .mild ? .softLavender : .softPeach)

                            Text(burnoutLevel.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.starWhite)

                            Text(burnoutLevel.message)
                                .font(.body)
                                .foregroundColor(.starWhite.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cosmosPurple)
                        )
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                        // Personalized Message
                        Text(personalizedMessage)
                            .font(.body)
                            .foregroundColor(.starWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity)

                        // What's Next Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What's next")
                                .font(.headline)
                                .foregroundColor(.starWhite)

                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.softLavender)
                                Text("\(pace.dailyTaskCount) small task\(pace.dailyTaskCount > 1 ? "s" : "") per day")
                                    .foregroundColor(.starWhite.opacity(0.8))
                            }

                            HStack(spacing: 12) {
                                CategoryIcon(icon: "wind", label: "Breathe")
                                CategoryIcon(icon: "bubble.left.and.bubble.right", label: "Reflect")
                                CategoryIcon(icon: "leaf", label: "Gratitude")
                                CategoryIcon(icon: "figure.walk", label: "Move")
                                CategoryIcon(icon: "eye", label: "Mindful")
                            }

                            Text("You can adjust your pace anytime in settings.")
                                .font(.caption)
                                .foregroundColor(.starWhite.opacity(0.5))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cosmosPurple.opacity(0.5))
                        )
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 20)
                }
            }

            // Bottom CTA
            VStack {
                Spacer()

                if showContent {
                    PrimaryButton(title: "Begin Your Journey", action: onStart)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            showSparkles = true
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            showBadge = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            showContent = true
        }

        // Hide sparkles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSparkles = false
            }
        }
    }
}

struct CategoryIcon: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.softLavender)
            Text(label)
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SparkleOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<20, id: \.self) { index in
                    SparkleParticle()
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.5)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct SparkleParticle: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 8...16)))
            .foregroundColor(.softPeach)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 0.5...1.5)).repeatForever(autoreverses: true)) {
                    opacity = Double.random(in: 0.3...1.0)
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}
```

**Step 2: Update OnboardingCoordinator to use ResultsView**

Replace OnboardingCoordinator.swift:

```swift
import SwiftUI

enum OnboardingStep {
    case name
    case situation
    case goal
    case assessment
    case results
}

struct OnboardingCoordinator: View {
    @State private var step: OnboardingStep = .name
    @State private var name: String = ""
    @State private var situation: Situation?
    @State private var goal: Goal?
    @State private var pace: Pace = .steady
    @State private var burnoutLevel: BurnoutLevel = .moderate

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
                    burnoutLevel = Assessment.calculateBurnoutLevel(answers: [:]) // Will be updated
                    withAnimation { step = .results }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .results:
                ResultsView(
                    name: name,
                    pace: pace,
                    burnoutLevel: burnoutLevel,
                    personalizedMessage: Assessment.personalizedMessage(situation: situation, goal: goal),
                    onStart: saveAndComplete
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }

    private func saveAndComplete() {
        guard let situation = situation, let goal = goal else { return }
        UserService.shared.completeOnboarding(name: name, situation: situation, goal: goal)
        UserService.shared.completeAssessment(pace: pace)

        // Force task generation after onboarding
        TaskService.shared.generateDailyTasks()

        onComplete()
    }
}
```

**Step 3: Test in simulator**

Run app, complete onboarding:
- Expected: After Assessment, see ResultsView with sparkles
- Expected: Badge animation, burnout level, personalized message
- Expected: "Begin Your Journey" button at bottom

**Step 4: Commit**

```bash
git add Views/Onboarding/ResultsView.swift Views/Onboarding/OnboardingCoordinator.swift
git commit -m "feat: add enhanced ResultsView with celebration animation"
```

---

## Task 5: Pass Assessment Answers to ResultsView

**Files:**
- Modify: `Views/Onboarding/AssessmentView.swift`
- Modify: `Views/Onboarding/OnboardingCoordinator.swift`

**Step 1: Update AssessmentView to pass answers**

Change the onComplete closure signature:

```swift
// In AssessmentView, change:
let onComplete: (Pace) -> Void

// To:
let onComplete: (Pace, [Int: Int]) -> Void

// And update the See Results action:
PrimaryButton(title: "See Results") {
    let pace = Assessment.calculatePace(answers: answers)
    onComplete(pace, answers)
}
```

**Step 2: Update OnboardingCoordinator**

```swift
// Add state for answers
@State private var assessmentAnswers: [Int: Int] = [:]

// Update assessment case:
case .assessment:
    AssessmentView { calculatedPace, answers in
        pace = calculatedPace
        assessmentAnswers = answers
        burnoutLevel = Assessment.calculateBurnoutLevel(answers: answers)
        withAnimation { step = .results }
    }
    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
```

**Step 3: Commit**

```bash
git add Views/Onboarding/AssessmentView.swift Views/Onboarding/OnboardingCoordinator.swift
git commit -m "fix: pass assessment answers to calculate burnout level"
```

---

## Task 6: Fix TaskService JSON Loading

**Files:**
- Modify: `Services/TaskService.swift`
- Modify: `Models/Task.swift`

**Step 1: Add missing JSON fields to TaskContent**

In `Models/Task.swift`, update TaskContent:

```swift
struct TaskContent: Codable {
    let instruction: String?
    let question: String?
    let options: [String]?
    let rounds: Int?
    let duration: Int?
    let slider: SliderConfig?
    let followUp: FollowUpConfig?
    let notePrompt: String?
    let notePlaceholder: String?
    let completion: String?
    let multiSelect: Bool?
    let maxSelect: Int?
    let exactSelect: Int?
    // Add missing fields from JSON
    let phases: [BreathingPhase]?
    let freeform: Bool?
    let backgroundSound: String?
    let guided: Bool?
    let sections: [String]?
    let checkIn: CheckInConfig?
}

struct BreathingPhase: Codable {
    let name: String
    let duration: Int
}

struct CheckInConfig: Codable {
    let question: String?
    let options: [String]?
}

// Update SliderConfig to include type
struct SliderConfig: Codable {
    let question: String?
    let min: Int?
    let max: Int?
    let minLabel: String?
    let maxLabel: String?
    let options: [String]?
    let type: String?
}

// Update FollowUpConfig
struct FollowUpConfig: Codable {
    let question: String?
    let options: [String]?
    let condition: String?
    let message: String?
}
```

**Step 2: Add evidence field to RecoveryTask**

```swift
struct RecoveryTask: Codable, Identifiable {
    let id: String
    let category: TaskCategory
    let title: String
    let description: String
    let uiType: TaskUIType
    let stardust: Int
    let duration: Int?
    let content: TaskContent?
    let evidence: String? // Add this field

    var stardustReward: Int { stardust }
    // ... rest unchanged
}
```

**Step 3: Update TaskService with better error handling**

```swift
private func loadTasksFromBundle() {
    guard let url = Bundle.main.url(forResource: "Tasks", withExtension: "json") else {
        print("❌ Tasks.json not found in bundle")
        return
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(TasksContainer.self, from: data)
        self.allTasks = decoded.tasks
        print("✅ Loaded \(decoded.tasks.count) tasks from JSON")
    } catch {
        print("❌ Failed to decode tasks: \(error)")
    }
}

private struct TasksContainer: Codable {
    let version: String? // Add version field
    let tasks: [RecoveryTask]
}
```

**Step 4: Test in simulator**

Run app, complete onboarding:
- Check Xcode console for "✅ Loaded XX tasks"
- Expected: Home screen shows tasks (not 0/0)

**Step 5: Commit**

```bash
git add Services/TaskService.swift Models/Task.swift
git commit -m "fix: add missing JSON fields to Task model for proper decoding"
```

---

## Task 7: Add Welcome Banner to HomeView

**Files:**
- Modify: `Views/Home/HomeView.swift`

**Step 1: Add welcome state and empty state handling**

Replace HomeView:

```swift
import SwiftUI

struct HomeView: View {
    @ObservedObject var userService = UserService.shared
    @ObservedObject var taskService = TaskService.shared
    @State private var selectedTask: DailyTask?
    @State private var showWelcome = true
    @State private var showBonusTaskOffer = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmosBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        HeaderView(name: userService.user.name, streak: userService.user.currentStreak)

                        ProgressCard(
                            stardust: userService.user.stardust,
                            level: userService.user.level
                        )
                        .padding(.horizontal, 20)

                        // Welcome banner for first time
                        if showWelcome && userService.user.totalTasksCompleted == 0 {
                            WelcomeBanner(name: userService.user.name) {
                                withAnimation {
                                    showWelcome = false
                                }
                            }
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Tasks section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Today's Tasks")
                                    .font(.headline)
                                    .foregroundColor(.starWhite)

                                Spacer()

                                Text("\(taskService.completedCount)/\(taskService.dailyTasks.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.softLavender)
                            }

                            if taskService.dailyTasks.isEmpty {
                                // Empty state - should not happen normally
                                EmptyTasksView {
                                    taskService.generateDailyTasks()
                                }
                            } else if taskService.allCompleted {
                                // All tasks done - offer bonus task
                                AllDoneView(showBonusOffer: $showBonusTaskOffer) {
                                    taskService.addBonusTask()
                                }
                            } else {
                                ForEach(taskService.dailyTasks) { dailyTask in
                                    TaskCard(dailyTask: dailyTask) {
                                        selectedTask = dailyTask
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailView(dailyTask: task)
            }
        }
    }
}

struct WelcomeBanner: View {
    let name: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome, \(name)!")
                    .font(.headline)
                    .foregroundColor(.starWhite)
                Text("Here's your first task.")
                    .font(.subheadline)
                    .foregroundColor(.starWhite.opacity(0.7))
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.starWhite.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.softLavender.opacity(0.2))
        )
    }
}

struct EmptyTasksView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.starWhite.opacity(0.3))

            Text("Loading your tasks...")
                .font(.body)
                .foregroundColor(.starWhite.opacity(0.7))

            Button(action: onRetry) {
                Text("Retry")
                    .font(.subheadline)
                    .foregroundColor(.softLavender)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

struct AllDoneView: View {
    @Binding var showBonusOffer: Bool
    let onBonusTask: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 40))
                .foregroundColor(.softPeach)

            Text("You're done for today!")
                .font(.headline)
                .foregroundColor(.starWhite)

            Text("Great job taking care of yourself.")
                .font(.subheadline)
                .foregroundColor(.starWhite.opacity(0.7))

            if !showBonusOffer {
                Button(action: { showBonusOffer = true }) {
                    Text("Want to try one more?")
                        .font(.subheadline)
                        .foregroundColor(.softLavender)
                }
            } else {
                HStack(spacing: 16) {
                    SecondaryButton(title: "Rest") {
                        showBonusOffer = false
                    }

                    PrimaryButton(title: "Show me one") {
                        onBonusTask()
                        showBonusOffer = false
                    }
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cosmosPurple.opacity(0.5))
        )
    }
}
```

**Step 2: Commit**

```bash
git add Views/Home/HomeView.swift
git commit -m "feat: add welcome banner and empty/done states to HomeView"
```

---

## Task 8: Add Bonus Task Method to TaskService

**Files:**
- Modify: `Services/TaskService.swift`

**Step 1: Add addBonusTask method**

```swift
func addBonusTask() {
    // Get a random task not in today's list
    let currentTaskIds = Set(dailyTasks.map { $0.task.id })
    let availableTasks = allTasks.filter { !currentTaskIds.contains($0.id) }

    guard let bonusTask = availableTasks.randomElement() else { return }

    let newDailyTask = DailyTask(task: bonusTask)
    dailyTasks.append(newDailyTask)
}
```

**Step 2: Commit**

```bash
git add Services/TaskService.swift
git commit -m "feat: add bonus task functionality"
```

---

## Task 9: Final Integration Test

**Step 1: Clean install test**

1. Delete app from simulator
2. Run fresh install
3. Complete onboarding flow
4. Verify:
   - Assessment transitions are smooth (0.6s delay)
   - No Next button, only Back
   - See Results appears after last answer
   - ResultsView shows sparkles, badge, burnout level
   - Home screen has tasks (not 0/0)
   - Welcome banner shows

**Step 2: Complete tasks test**

1. Complete all daily tasks
2. Verify "All Done" state appears
3. Test bonus task offer

**Step 3: Final commit**

```bash
git add -A
git commit -m "test: verify assessment UX and home screen improvements"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | ChoiceButton animation | Components/ChoiceButton.swift |
| 2 | AssessmentView transitions | Views/Onboarding/AssessmentView.swift |
| 3 | BurnoutLevel model | Models/Assessment.swift |
| 4 | ResultsView creation | Views/Onboarding/ResultsView.swift, OnboardingCoordinator.swift |
| 5 | Pass answers to results | AssessmentView.swift, OnboardingCoordinator.swift |
| 6 | Fix JSON loading | Services/TaskService.swift, Models/Task.swift |
| 7 | HomeView states | Views/Home/HomeView.swift |
| 8 | Bonus task feature | Services/TaskService.swift |
| 9 | Integration test | - |
