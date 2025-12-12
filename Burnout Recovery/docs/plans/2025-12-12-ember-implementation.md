# Ember — Burnout Recovery Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an iOS SwiftUI burnout recovery app with gamified micro-tasks, assessments, and progress tracking.

**Architecture:** MVVM pattern with SwiftUI, UserDefaults for persistence, JSON bundles for static content. State management via ObservableObject and @Published properties.

**Tech Stack:** SwiftUI, UserDefaults, UserNotifications, AVFoundation, UIImpactFeedbackGenerator

---

## Phase 1: Project Foundation & Core Models

### Task 1.1: Create Xcode Project Structure

**Files:**
- Create: `Ember/App/EmberApp.swift`
- Create: `Ember/Resources/Assets.xcassets`

**Step 1: Create new Xcode project**

Open Xcode → New Project → iOS App
- Product Name: Ember
- Interface: SwiftUI
- Language: Swift
- Storage: None
- Bundle ID: com.yourname.ember

**Step 2: Create folder structure**

Create these folders in Xcode:
```
Ember/
├── App/
├── Models/
├── Views/
│   ├── Onboarding/
│   ├── Home/
│   ├── Tasks/
│   ├── Celebration/
│   └── Profile/
├── Components/
├── Services/
├── Data/
└── Resources/
```

**Step 3: Commit**

```bash
git add .
git commit -m "feat: initialize Ember project structure"
```

---

### Task 1.2: Define Color Extensions

**Files:**
- Create: `Ember/Resources/Colors.swift`

**Step 1: Create Colors.swift**

```swift
import SwiftUI

extension Color {
    static let cosmosBackground = Color(hex: "0B0B1A")
    static let cosmosPurple = Color(hex: "1E1B4B")
    static let softLavender = Color(hex: "A78BFA")
    static let softPink = Color(hex: "F0ABFC")
    static let softBlue = Color(hex: "7DD3FC")
    static let softPeach = Color(hex: "FED7AA")
    static let starWhite = Color(hex: "F5F5F7")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Resources/Colors.swift
git commit -m "feat: add Cosmos color palette"
```

---

### Task 1.3: Create User Model

**Files:**
- Create: `Ember/Models/User.swift`

**Step 1: Create User.swift**

```swift
import Foundation

enum Pace: String, Codable, CaseIterable {
    case gentle = "gentle"
    case steady = "steady"
    case active = "active"

    var dailyTaskCount: Int {
        switch self {
        case .gentle: return 1
        case .steady: return 2
        case .active: return 3
        }
    }

    var displayName: String {
        switch self {
        case .gentle: return "Gentle"
        case .steady: return "Steady"
        case .active: return "Active"
        }
    }
}

enum Situation: String, Codable, CaseIterable {
    case overwhelmed = "Work is overwhelming me"
    case exhausted = "I feel emotionally exhausted"
    case lostMotivation = "I lost motivation for things I enjoyed"
    case alwaysTired = "I'm always tired, no matter how much I rest"
    case prevention = "I want to prevent burnout"
}

enum Goal: String, Codable, CaseIterable {
    case recoverEnergy = "Recover my energy"
    case findBalance = "Find balance"
    case feelMyself = "Feel like myself again"
    case healthyHabits = "Build healthier habits"
}

struct User: Codable {
    var name: String
    var situation: Situation?
    var goal: Goal?
    var pace: Pace
    var stardust: Int
    var currentStreak: Int
    var longestStreak: Int
    var streakFreezeAvailable: Bool
    var streakFreezeUsedThisWeek: Bool
    var level: Int
    var completedTaskIds: [String]
    var earnedBadgeIds: [String]
    var totalTasksCompleted: Int
    var notesWritten: Int
    var onboardingCompleted: Bool
    var assessmentCompleted: Bool
    var lastActiveDate: Date?
    var notificationTime: Date?
    var notificationsEnabled: Bool
    var streakAlertsEnabled: Bool

    init() {
        self.name = ""
        self.situation = nil
        self.goal = nil
        self.pace = .steady
        self.stardust = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.streakFreezeAvailable = true
        self.streakFreezeUsedThisWeek = false
        self.level = 1
        self.completedTaskIds = []
        self.earnedBadgeIds = []
        self.totalTasksCompleted = 0
        self.notesWritten = 0
        self.onboardingCompleted = false
        self.assessmentCompleted = false
        self.lastActiveDate = nil
        self.notificationTime = nil
        self.notificationsEnabled = true
        self.streakAlertsEnabled = true
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Models/User.swift
git commit -m "feat: add User model with pace, situation, and goal enums"
```

---

### Task 1.4: Create Task Model

**Files:**
- Create: `Ember/Models/Task.swift`

**Step 1: Create Task.swift**

```swift
import Foundation

enum TaskCategory: String, Codable, CaseIterable {
    case breathe = "breathe"
    case reflect = "reflect"
    case gratitude = "gratitude"
    case move = "move"
    case mindful = "mindful"

    var displayName: String {
        switch self {
        case .breathe: return "Breathe"
        case .reflect: return "Reflect"
        case .gratitude: return "Gratitude"
        case .move: return "Move"
        case .mindful: return "Mindful"
        }
    }

    var icon: String {
        switch self {
        case .breathe: return "wind"
        case .reflect: return "bubble.left.and.bubble.right"
        case .gratitude: return "leaf"
        case .move: return "figure.walk"
        case .mindful: return "eye"
        }
    }
}

enum TaskUIType: String, Codable {
    case simpleChoice = "simple_choice"
    case multiSelect = "multi_select"
    case sliderChoice = "slider_choice"
    case timedActivity = "timed_activity"
    case choiceWithNote = "choice_with_note"
}

struct TaskOption: Codable, Identifiable {
    let id: String
    let text: String
}

struct RecoveryTask: Codable, Identifiable {
    let id: String
    let category: TaskCategory
    let title: String
    let description: String
    let uiType: TaskUIType
    let options: [TaskOption]?
    let duration: Int? // seconds, for timed activities
    let stardustReward: Int

    static let placeholder = RecoveryTask(
        id: "placeholder",
        category: .breathe,
        title: "Loading...",
        description: "",
        uiType: .simpleChoice,
        options: nil,
        duration: nil,
        stardustReward: 0
    )
}

struct DailyTask: Identifiable {
    let id: String
    let task: RecoveryTask
    var isCompleted: Bool
    var completedAt: Date?
    var selectedOptionIds: [String]
    var note: String?

    init(task: RecoveryTask) {
        self.id = UUID().uuidString
        self.task = task
        self.isCompleted = false
        self.completedAt = nil
        self.selectedOptionIds = []
        self.note = nil
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Models/Task.swift
git commit -m "feat: add Task and DailyTask models"
```

---

### Task 1.5: Create Badge Model

**Files:**
- Create: `Ember/Models/Badge.swift`

**Step 1: Create Badge.swift**

```swift
import Foundation

enum BadgeCondition: Codable {
    case firstTask
    case streakDays(Int)
    case taskAfterHour(Int)
    case taskBeforeHour(Int)
    case notesWritten(Int)
    case categoryTasksCompleted(TaskCategory, Int)
    case streakRecovered
    case allTasksDays(Int)
    case levelReached(Int)
    case badgesEarned(Int)
    case allCategoriesCompleted
    case assessmentsCompleted(Int)
}

struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let condition: BadgeCondition

    static let allBadges: [Badge] = [
        Badge(id: "first_light", name: "First Light", description: "Complete your first task", icon: "sparkle", condition: .firstTask),
        Badge(id: "week_one", name: "Week One", description: "Maintain a 7-day streak", icon: "calendar", condition: .streakDays(7)),
        Badge(id: "night_owl", name: "Night Owl", description: "Complete a task after 9 PM", icon: "moon.stars", condition: .taskAfterHour(21)),
        Badge(id: "early_bird", name: "Early Bird", description: "Complete a task before 7 AM", icon: "sunrise", condition: .taskBeforeHour(7)),
        Badge(id: "storyteller", name: "Storyteller", description: "Write 10 optional notes", icon: "pencil.line", condition: .notesWritten(10)),
        Badge(id: "zen_mind", name: "Zen Mind", description: "Complete 10 breathing tasks", icon: "wind", condition: .categoryTasksCompleted(.breathe, 10)),
        Badge(id: "resilient", name: "Resilient", description: "Recover from a lost streak", icon: "arrow.counterclockwise", condition: .streakRecovered),
        Badge(id: "focused", name: "Focused", description: "Complete all tasks 5 days in a row", icon: "target", condition: .allTasksDays(5)),
        Badge(id: "blooming", name: "Blooming", description: "Reach Level 3", icon: "leaf", condition: .levelReached(3)),
        Badge(id: "rising_star", name: "Rising Star", description: "Reach Level 5", icon: "star", condition: .levelReached(5)),
        Badge(id: "ember_master", name: "Ember Master", description: "Reach Level 8", icon: "flame", condition: .levelReached(8)),
        Badge(id: "monthly_hero", name: "Monthly Hero", description: "Maintain a 30-day streak", icon: "medal", condition: .streakDays(30)),
        Badge(id: "collector", name: "Collector", description: "Earn 5 badges", icon: "square.grid.2x2", condition: .badgesEarned(5)),
        Badge(id: "balanced", name: "Balanced", description: "Complete tasks in all 5 categories", icon: "circle.hexagongrid", condition: .allCategoriesCompleted),
        Badge(id: "self_aware", name: "Self-Aware", description: "Complete 4 weekly assessments", icon: "brain.head.profile", condition: .assessmentsCompleted(4))
    ]
}
```

**Step 2: Commit**

```bash
git add Ember/Models/Badge.swift
git commit -m "feat: add Badge model with 15 starter badges"
```

---

### Task 1.6: Create Progress Model

**Files:**
- Create: `Ember/Models/Progress.swift`

**Step 1: Create Progress.swift**

```swift
import Foundation

struct LevelInfo {
    let level: Int
    let name: String
    let stardustRequired: Int

    static let levels: [LevelInfo] = [
        LevelInfo(level: 1, name: "Spark", stardustRequired: 0),
        LevelInfo(level: 2, name: "Flicker", stardustRequired: 200),
        LevelInfo(level: 3, name: "Glow", stardustRequired: 500),
        LevelInfo(level: 4, name: "Warmth", stardustRequired: 1000),
        LevelInfo(level: 5, name: "Radiance", stardustRequired: 2000),
        LevelInfo(level: 6, name: "Blaze", stardustRequired: 3500),
        LevelInfo(level: 7, name: "Brilliance", stardustRequired: 5500),
        LevelInfo(level: 8, name: "Ember Master", stardustRequired: 8000)
    ]

    static func level(for stardust: Int) -> LevelInfo {
        var result = levels[0]
        for level in levels {
            if stardust >= level.stardustRequired {
                result = level
            } else {
                break
            }
        }
        return result
    }

    static func progress(for stardust: Int) -> Double {
        let current = level(for: stardust)
        guard current.level < 8 else { return 1.0 }

        let next = levels[current.level]
        let progressInLevel = stardust - current.stardustRequired
        let levelRange = next.stardustRequired - current.stardustRequired
        return Double(progressInLevel) / Double(levelRange)
    }
}

struct StardustReward {
    static let taskCompletion = 30...75
    static let allDailyTasksBonus = 50
    static let dailyStreakBonus = 10
    static let weeklyAssessment = 100
}
```

**Step 2: Commit**

```bash
git add Ember/Models/Progress.swift
git commit -m "feat: add Progress model with level system"
```

---

## Phase 2: Services Layer

### Task 2.1: Create UserService

**Files:**
- Create: `Ember/Services/UserService.swift`

**Step 1: Create UserService.swift**

```swift
import Foundation
import Combine

class UserService: ObservableObject {
    static let shared = UserService()

    @Published var user: User

    private let userDefaultsKey = "ember_user"

    private init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: data) {
            self.user = savedUser
        } else {
            self.user = User()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func addStardust(_ amount: Int) {
        user.stardust += amount
        checkLevelUp()
        save()
    }

    func checkLevelUp() {
        let newLevel = LevelInfo.level(for: user.stardust).level
        if newLevel > user.level {
            user.level = newLevel
        }
    }

    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastActive = user.lastActiveDate else {
            user.currentStreak = 1
            user.lastActiveDate = today
            save()
            return
        }

        let lastActiveDay = calendar.startOfDay(for: lastActive)
        let daysDifference = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0

        switch daysDifference {
        case 0:
            // Same day, no change
            break
        case 1:
            // Consecutive day
            user.currentStreak += 1
            user.lastActiveDate = today
            if user.currentStreak > user.longestStreak {
                user.longestStreak = user.currentStreak
            }
        case 2:
            // Missed one day - use freeze if available
            if user.streakFreezeAvailable && !user.streakFreezeUsedThisWeek {
                user.streakFreezeUsedThisWeek = true
                user.currentStreak += 1
                user.lastActiveDate = today
            } else {
                user.currentStreak = 1
                user.lastActiveDate = today
            }
        default:
            // Missed multiple days
            user.currentStreak = 1
            user.lastActiveDate = today
        }

        save()
    }

    func resetWeeklyStreakFreeze() {
        user.streakFreezeUsedThisWeek = false
        user.streakFreezeAvailable = true
        save()
    }

    func completeOnboarding(name: String, situation: Situation, goal: Goal) {
        user.name = name
        user.situation = situation
        user.goal = goal
        user.onboardingCompleted = true
        save()
    }

    func completeAssessment(pace: Pace) {
        user.pace = pace
        user.assessmentCompleted = true
        save()
    }

    func recordTaskCompletion(hasNote: Bool) {
        user.totalTasksCompleted += 1
        if hasNote {
            user.notesWritten += 1
        }
        save()
    }

    func earnBadge(_ badgeId: String) {
        if !user.earnedBadgeIds.contains(badgeId) {
            user.earnedBadgeIds.append(badgeId)
            save()
        }
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Services/UserService.swift
git commit -m "feat: add UserService with persistence and streak management"
```

---

### Task 2.2: Create TaskService

**Files:**
- Create: `Ember/Services/TaskService.swift`
- Create: `Ember/Data/Tasks.json`

**Step 1: Create Tasks.json**

```json
{
  "tasks": [
    {
      "id": "breathe_1",
      "category": "breathe",
      "title": "Box Breathing",
      "description": "A calming technique used by Navy SEALs",
      "uiType": "timed_activity",
      "duration": 120,
      "stardustReward": 50
    },
    {
      "id": "breathe_2",
      "category": "breathe",
      "title": "4-7-8 Breathing",
      "description": "Inhale for 4, hold for 7, exhale for 8",
      "uiType": "timed_activity",
      "duration": 90,
      "stardustReward": 45
    },
    {
      "id": "reflect_1",
      "category": "reflect",
      "title": "Energy Check",
      "description": "How is your energy level right now?",
      "uiType": "slider_choice",
      "options": [
        {"id": "r1_low", "text": "Running on empty"},
        {"id": "r1_medium", "text": "Getting by"},
        {"id": "r1_high", "text": "Feeling energized"}
      ],
      "stardustReward": 40
    },
    {
      "id": "reflect_2",
      "category": "reflect",
      "title": "Today's Win",
      "description": "What's one small win from today?",
      "uiType": "choice_with_note",
      "options": [
        {"id": "r2_work", "text": "Something at work"},
        {"id": "r2_personal", "text": "Personal accomplishment"},
        {"id": "r2_health", "text": "Health/self-care"},
        {"id": "r2_social", "text": "Connection with someone"}
      ],
      "stardustReward": 45
    },
    {
      "id": "gratitude_1",
      "category": "gratitude",
      "title": "Three Good Things",
      "description": "Name three things you're grateful for today",
      "uiType": "multi_select",
      "options": [
        {"id": "g1_health", "text": "My health"},
        {"id": "g1_people", "text": "Someone in my life"},
        {"id": "g1_home", "text": "My home/comfort"},
        {"id": "g1_nature", "text": "Something in nature"},
        {"id": "g1_opportunity", "text": "An opportunity"},
        {"id": "g1_simple", "text": "A simple pleasure"}
      ],
      "stardustReward": 40
    },
    {
      "id": "gratitude_2",
      "category": "gratitude",
      "title": "Appreciation Note",
      "description": "Think of someone who helped you recently",
      "uiType": "choice_with_note",
      "options": [
        {"id": "g2_family", "text": "Family member"},
        {"id": "g2_friend", "text": "Friend"},
        {"id": "g2_colleague", "text": "Colleague"},
        {"id": "g2_stranger", "text": "Stranger/acquaintance"}
      ],
      "stardustReward": 50
    },
    {
      "id": "move_1",
      "category": "move",
      "title": "Stretch Break",
      "description": "Take 2 minutes to stretch your body",
      "uiType": "timed_activity",
      "duration": 120,
      "stardustReward": 45
    },
    {
      "id": "move_2",
      "category": "move",
      "title": "Step Outside",
      "description": "Go outside for a brief moment",
      "uiType": "simple_choice",
      "options": [
        {"id": "m2_1min", "text": "1 minute fresh air"},
        {"id": "m2_5min", "text": "5 minute walk"},
        {"id": "m2_longer", "text": "Longer exploration"}
      ],
      "stardustReward": 55
    },
    {
      "id": "mindful_1",
      "category": "mindful",
      "title": "5 Senses Check",
      "description": "Ground yourself in the present moment",
      "uiType": "simple_choice",
      "options": [
        {"id": "mf1_see", "text": "Something I see"},
        {"id": "mf1_hear", "text": "Something I hear"},
        {"id": "mf1_feel", "text": "Something I feel"},
        {"id": "mf1_smell", "text": "Something I smell"}
      ],
      "stardustReward": 40
    },
    {
      "id": "mindful_2",
      "category": "mindful",
      "title": "Mindful Moment",
      "description": "Pause and observe your thoughts",
      "uiType": "choice_with_note",
      "options": [
        {"id": "mf2_calm", "text": "Feeling calm"},
        {"id": "mf2_busy", "text": "Mind is busy"},
        {"id": "mf2_anxious", "text": "Some anxiety"},
        {"id": "mf2_neutral", "text": "Neutral/observing"}
      ],
      "stardustReward": 45
    }
  ]
}
```

**Step 2: Create TaskService.swift**

```swift
import Foundation
import Combine

class TaskService: ObservableObject {
    static let shared = TaskService()

    @Published var allTasks: [RecoveryTask] = []
    @Published var dailyTasks: [DailyTask] = []

    private let dailyTasksKey = "ember_daily_tasks"
    private let lastGeneratedKey = "ember_last_generated"

    private init() {
        loadTasksFromBundle()
        loadOrGenerateDailyTasks()
    }

    private func loadTasksFromBundle() {
        guard let url = Bundle.main.url(forResource: "Tasks", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load Tasks.json")
            return
        }

        do {
            let decoded = try JSONDecoder().decode(TasksContainer.self, from: data)
            self.allTasks = decoded.tasks
        } catch {
            print("Failed to decode tasks: \(error)")
        }
    }

    private struct TasksContainer: Codable {
        let tasks: [RecoveryTask]
    }

    func loadOrGenerateDailyTasks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastGenerated = UserDefaults.standard.object(forKey: lastGeneratedKey) as? Date,
           calendar.isDate(lastGenerated, inSameDayAs: today) {
            loadSavedDailyTasks()
        } else {
            generateDailyTasks()
        }
    }

    private func loadSavedDailyTasks() {
        // For simplicity, regenerate if no saved state found
        // In production, implement proper persistence
        generateDailyTasks()
    }

    func generateDailyTasks() {
        let pace = UserService.shared.user.pace
        let count = pace.dailyTaskCount

        var selectedTasks: [RecoveryTask] = []
        var usedCategories: Set<TaskCategory> = []

        // Try to get variety by using different categories
        let shuffledTasks = allTasks.shuffled()

        for task in shuffledTasks {
            if selectedTasks.count >= count { break }

            if !usedCategories.contains(task.category) || selectedTasks.count < count {
                selectedTasks.append(task)
                usedCategories.insert(task.category)
            }
        }

        dailyTasks = selectedTasks.map { DailyTask(task: $0) }

        UserDefaults.standard.set(Date(), forKey: lastGeneratedKey)
        saveDailyTasks()
    }

    private func saveDailyTasks() {
        // Simplified - in production, encode and save to UserDefaults
    }

    func completeTask(_ dailyTask: DailyTask, selectedOptions: [String], note: String?) {
        guard let index = dailyTasks.firstIndex(where: { $0.id == dailyTask.id }) else { return }

        dailyTasks[index].isCompleted = true
        dailyTasks[index].completedAt = Date()
        dailyTasks[index].selectedOptionIds = selectedOptions
        dailyTasks[index].note = note

        // Award stardust
        let reward = dailyTask.task.stardustReward
        UserService.shared.addStardust(reward)

        // Record completion
        UserService.shared.recordTaskCompletion(hasNote: note != nil)

        // Update streak
        UserService.shared.updateStreak()

        // Check for all tasks completed bonus
        if dailyTasks.allSatisfy({ $0.isCompleted }) {
            UserService.shared.addStardust(StardustReward.allDailyTasksBonus)
        }

        // Check for badges
        BadgeService.shared.checkBadges(for: dailyTask)

        saveDailyTasks()
    }

    var completedCount: Int {
        dailyTasks.filter { $0.isCompleted }.count
    }

    var allCompleted: Bool {
        dailyTasks.allSatisfy { $0.isCompleted }
    }
}
```

**Step 3: Commit**

```bash
git add Ember/Services/TaskService.swift Ember/Data/Tasks.json
git commit -m "feat: add TaskService with JSON-based task loading"
```

---

### Task 2.3: Create BadgeService

**Files:**
- Create: `Ember/Services/BadgeService.swift`

**Step 1: Create BadgeService.swift**

```swift
import Foundation
import Combine

class BadgeService: ObservableObject {
    static let shared = BadgeService()

    @Published var newlyEarnedBadge: Badge?

    private init() {}

    func checkBadges(for completedTask: DailyTask) {
        let user = UserService.shared.user

        for badge in Badge.allBadges {
            if user.earnedBadgeIds.contains(badge.id) { continue }

            if checkCondition(badge.condition, user: user, task: completedTask) {
                UserService.shared.earnBadge(badge.id)
                newlyEarnedBadge = badge
            }
        }
    }

    func checkAllBadges() {
        let user = UserService.shared.user

        for badge in Badge.allBadges {
            if user.earnedBadgeIds.contains(badge.id) { continue }

            if checkCondition(badge.condition, user: user, task: nil) {
                UserService.shared.earnBadge(badge.id)
                newlyEarnedBadge = badge
            }
        }
    }

    private func checkCondition(_ condition: BadgeCondition, user: User, task: DailyTask?) -> Bool {
        switch condition {
        case .firstTask:
            return user.totalTasksCompleted >= 1

        case .streakDays(let days):
            return user.currentStreak >= days

        case .taskAfterHour(let hour):
            guard let completedAt = task?.completedAt else { return false }
            let taskHour = Calendar.current.component(.hour, from: completedAt)
            return taskHour >= hour

        case .taskBeforeHour(let hour):
            guard let completedAt = task?.completedAt else { return false }
            let taskHour = Calendar.current.component(.hour, from: completedAt)
            return taskHour < hour

        case .notesWritten(let count):
            return user.notesWritten >= count

        case .categoryTasksCompleted(_, let count):
            // Simplified - would need to track per-category
            return user.totalTasksCompleted >= count

        case .streakRecovered:
            // Track when streak was lost and recovered
            return false

        case .allTasksDays(let days):
            // Would need to track consecutive all-task completion days
            return false

        case .levelReached(let level):
            return user.level >= level

        case .badgesEarned(let count):
            return user.earnedBadgeIds.count >= count

        case .allCategoriesCompleted:
            // Would need to track categories completed
            return false

        case .assessmentsCompleted(let count):
            // Would need to track assessments
            return false
        }
    }

    func clearNewBadge() {
        newlyEarnedBadge = nil
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Services/BadgeService.swift
git commit -m "feat: add BadgeService with condition checking"
```

---

### Task 2.4: Create NotificationService

**Files:**
- Create: `Ember/Services/NotificationService.swift`

**Step 1: Create NotificationService.swift**

```swift
import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleDailyReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Your daily reflection is waiting"
        content.body = "Take a moment to nurture your spark"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleStreakWarning() {
        guard UserService.shared.user.streakAlertsEnabled else { return }

        let content = UNMutableNotificationContent()
        let streak = UserService.shared.user.currentStreak
        content.title = "Don't let your \(streak)-day streak slip away"
        content.body = "You still have time to complete today's task"
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "streak_warning", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streak_warning"])
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelStreakWarning() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streak_warning"])
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Services/NotificationService.swift
git commit -m "feat: add NotificationService for daily reminders"
```

---

## Phase 3: Reusable Components

### Task 3.1: Create ChoiceButton Component

**Files:**
- Create: `Ember/Components/ChoiceButton.swift`

**Step 1: Create ChoiceButton.swift**

```swift
import SwiftUI

struct ChoiceButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(isSelected ? .cosmosBackground : .starWhite)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cosmosBackground)
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MultiChoiceButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .softLavender : .starWhite.opacity(0.6))
                Text(text)
                    .font(.body)
                    .foregroundColor(.starWhite)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.softLavender.opacity(0.2) : Color.cosmosPurple)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.softLavender : Color.softLavender.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        ChoiceButton(text: "Option 1", isSelected: false, action: {})
        ChoiceButton(text: "Option 2", isSelected: true, action: {})
        MultiChoiceButton(text: "Multi option", isSelected: false, action: {})
        MultiChoiceButton(text: "Multi selected", isSelected: true, action: {})
    }
    .padding()
    .background(Color.cosmosBackground)
}
```

**Step 2: Commit**

```bash
git add Ember/Components/ChoiceButton.swift
git commit -m "feat: add ChoiceButton and MultiChoiceButton components"
```

---

### Task 3.2: Create StardustCounter Component

**Files:**
- Create: `Ember/Components/StardustCounter.swift`

**Step 1: Create StardustCounter.swift**

```swift
import SwiftUI

struct StardustCounter: View {
    let amount: Int
    var showLabel: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundColor(.softPeach)
            Text("\(amount)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)
            if showLabel {
                Text("stardust")
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.cosmosPurple)
        )
    }
}

struct StardustRewardView: View {
    let amount: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: 4) {
            Text("+\(amount)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.softPeach)
            Image(systemName: "sparkles")
                .foregroundColor(.softPeach)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StardustCounter(amount: 1250)
        StardustCounter(amount: 50, showLabel: false)
        StardustRewardView(amount: 45)
    }
    .padding()
    .background(Color.cosmosBackground)
}
```

**Step 2: Commit**

```bash
git add Ember/Components/StardustCounter.swift
git commit -m "feat: add StardustCounter and reward animation"
```

---

### Task 3.3: Create ProgressBar Component

**Files:**
- Create: `Ember/Components/ProgressBar.swift`

**Step 1: Create ProgressBar.swift**

```swift
import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = .cosmosPurple
    var foregroundColor: Color = .softLavender

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [foregroundColor, foregroundColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(min(progress, 1.0))))
            }
        }
        .frame(height: height)
    }
}

struct LevelProgressView: View {
    let stardust: Int

    var body: some View {
        let levelInfo = LevelInfo.level(for: stardust)
        let progress = LevelInfo.progress(for: stardust)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(levelInfo.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.softLavender)
                Text(levelInfo.name)
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.7))
                Spacer()
                if levelInfo.level < 8 {
                    let next = LevelInfo.levels[levelInfo.level]
                    Text("\(stardust)/\(next.stardustRequired)")
                        .font(.caption2)
                        .foregroundColor(.starWhite.opacity(0.5))
                }
            }

            ProgressBar(progress: progress)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        ProgressBar(progress: 0.3)
        ProgressBar(progress: 0.7, foregroundColor: .softPink)
        LevelProgressView(stardust: 350)
        LevelProgressView(stardust: 1500)
    }
    .padding()
    .background(Color.cosmosBackground)
}
```

**Step 2: Commit**

```bash
git add Ember/Components/ProgressBar.swift
git commit -m "feat: add ProgressBar and LevelProgressView"
```

---

### Task 3.4: Create StreakBadge Component

**Files:**
- Create: `Ember/Components/StreakBadge.swift`

**Step 1: Create StreakBadge.swift**

```swift
import SwiftUI

struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundColor(.softPeach)
            Text("\(days)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)
            Text(days == 1 ? "day" : "days")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.softPeach.opacity(0.3), Color.softPink.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(Color.softPeach.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(days: 1)
        StreakBadge(days: 7)
        StreakBadge(days: 30)
    }
    .padding()
    .background(Color.cosmosBackground)
}
```

**Step 2: Commit**

```bash
git add Ember/Components/StreakBadge.swift
git commit -m "feat: add StreakBadge component"
```

---

### Task 3.5: Create PrimaryButton Component

**Files:**
- Create: `Ember/Components/PrimaryButton.swift`

**Step 1: Create PrimaryButton.swift**

```swift
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cosmosBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isEnabled ?
                            LinearGradient(
                                colors: [.softLavender, .softPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(!isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.softLavender)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.softLavender.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Get Started", action: {})
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
        SecondaryButton(title: "Skip for now", action: {})
    }
    .padding()
    .background(Color.cosmosBackground)
}
```

**Step 2: Commit**

```bash
git add Ember/Components/PrimaryButton.swift
git commit -m "feat: add PrimaryButton and SecondaryButton"
```

---

## Phase 4: Onboarding Views

### Task 4.1: Create WelcomeView

**Files:**
- Create: `Ember/Views/Onboarding/WelcomeView.swift`

**Step 1: Create WelcomeView.swift**

```swift
import SwiftUI

struct WelcomeView: View {
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo/Icon area
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

#Preview {
    WelcomeView(showOnboarding: .constant(false))
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Onboarding/WelcomeView.swift
git commit -m "feat: add WelcomeView for first launch"
```

---

### Task 4.2: Create NameInputView

**Files:**
- Create: `Ember/Views/Onboarding/NameInputView.swift`

**Step 1: Create NameInputView.swift**

```swift
import SwiftUI

struct NameInputView: View {
    @Binding var name: String
    let onContinue: () -> Void

    @FocusState private var isNameFocused: Bool

    var body: some View {
        ZStack {
            Color.cosmosBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Text("What should we call you?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)

                    Text("Just a first name is perfect")
                        .font(.body)
                        .foregroundColor(.starWhite.opacity(0.7))
                }

                TextField("", text: $name, prompt: Text("Your name").foregroundColor(.starWhite.opacity(0.4)))
                    .font(.title2)
                    .foregroundColor(.starWhite)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cosmosPurple)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.softLavender.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
                    .focused($isNameFocused)
                    .onSubmit {
                        if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                            onContinue()
                        }
                    }

                Spacer()

                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            isNameFocused = true
        }
    }
}

#Preview {
    NameInputView(name: .constant(""), onContinue: {})
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Onboarding/NameInputView.swift
git commit -m "feat: add NameInputView for onboarding"
```

---

### Task 4.3: Create SituationView

**Files:**
- Create: `Ember/Views/Onboarding/SituationView.swift`

**Step 1: Create SituationView.swift**

```swift
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
                }

                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(selectedSituation == nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    SituationView(selectedSituation: .constant(nil), onContinue: {})
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Onboarding/SituationView.swift
git commit -m "feat: add SituationView for onboarding"
```

---

### Task 4.4: Create GoalView

**Files:**
- Create: `Ember/Views/Onboarding/GoalView.swift`

**Step 1: Create GoalView.swift**

```swift
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
                }

                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(selectedGoal == nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    GoalView(selectedGoal: .constant(nil), onContinue: {})
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Onboarding/GoalView.swift
git commit -m "feat: add GoalView for onboarding"
```

---

### Task 4.5: Create AssessmentView

**Files:**
- Create: `Ember/Views/Onboarding/AssessmentView.swift`
- Create: `Ember/Models/Assessment.swift`

**Step 1: Create Assessment.swift**

```swift
import Foundation

struct AssessmentQuestion: Identifiable {
    let id: Int
    let text: String
    let dimension: AssessmentDimension
}

enum AssessmentDimension {
    case exhaustion
    case cynicism
    case efficacy
}

struct Assessment {
    static let questions: [AssessmentQuestion] = [
        // Exhaustion
        AssessmentQuestion(id: 1, text: "I feel emotionally drained from my work", dimension: .exhaustion),
        AssessmentQuestion(id: 2, text: "I feel used up at the end of the workday", dimension: .exhaustion),
        AssessmentQuestion(id: 3, text: "I feel tired when I get up to face another day", dimension: .exhaustion),

        // Cynicism
        AssessmentQuestion(id: 4, text: "I have become less interested in my work", dimension: .cynicism),
        AssessmentQuestion(id: 5, text: "I have become less enthusiastic about my work", dimension: .cynicism),
        AssessmentQuestion(id: 6, text: "I doubt the significance of my work", dimension: .cynicism),

        // Efficacy (reverse scored)
        AssessmentQuestion(id: 7, text: "I can effectively solve problems that arise", dimension: .efficacy),
        AssessmentQuestion(id: 8, text: "I feel I'm making an effective contribution", dimension: .efficacy),
        AssessmentQuestion(id: 9, text: "I feel good about accomplishing things", dimension: .efficacy)
    ]

    static let answerOptions = [
        "Never",
        "A few times a year",
        "Once a month",
        "A few times a month",
        "Once a week",
        "A few times a week",
        "Every day"
    ]

    static func calculatePace(answers: [Int: Int]) -> Pace {
        // Calculate scores for each dimension
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
                // Reverse score for efficacy (higher = better)
                efficacyScore += (6 - answerIndex)
            }
        }

        // Total score ranges from 0 to 54 (9 questions * 6 max each)
        let totalScore = exhaustionScore + cynicismScore + efficacyScore

        // Determine pace based on total score
        if totalScore >= 36 {
            return .gentle // High burnout
        } else if totalScore >= 18 {
            return .steady // Medium burnout
        } else {
            return .active // Low/prevention
        }
    }
}
```

**Step 2: Create AssessmentView.swift**

```swift
import SwiftUI

struct AssessmentView: View {
    @State private var currentQuestion = 0
    @State private var answers: [Int: Int] = [:]
    let onComplete: (Pace) -> Void

    private var questions: [AssessmentQuestion] {
        Assessment.questions
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
                            withAnimation {
                                currentQuestion -= 1
                            }
                        }
                    }

                    if currentQuestion < questions.count - 1 {
                        PrimaryButton(title: "Next") {
                            withAnimation {
                                currentQuestion += 1
                            }
                        }
                        .disabled(answers[questions[currentQuestion].id] == nil)
                    } else {
                        PrimaryButton(title: "See Results") {
                            completeAssessment()
                        }
                        .disabled(answers[questions[currentQuestion].id] == nil)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }

    private func selectAnswer(_ index: Int) {
        answers[questions[currentQuestion].id] = index

        // Auto-advance after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentQuestion < questions.count - 1 {
                withAnimation {
                    currentQuestion += 1
                }
            }
        }
    }

    private func completeAssessment() {
        let pace = Assessment.calculatePace(answers: answers)
        onComplete(pace)
    }
}

#Preview {
    AssessmentView { pace in
        print("Pace: \(pace)")
    }
}
```

**Step 3: Commit**

```bash
git add Ember/Models/Assessment.swift Ember/Views/Onboarding/AssessmentView.swift
git commit -m "feat: add Assessment model and AssessmentView"
```

---

### Task 4.6: Create OnboardingCoordinator

**Files:**
- Create: `Ember/Views/Onboarding/OnboardingCoordinator.swift`

**Step 1: Create OnboardingCoordinator.swift**

```swift
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
                    withAnimation {
                        step = .situation
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .situation:
                SituationView(selectedSituation: $situation) {
                    withAnimation {
                        step = .goal
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .goal:
                GoalView(selectedGoal: $goal) {
                    withAnimation {
                        step = .assessment
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .assessment:
                AssessmentView { calculatedPace in
                    pace = calculatedPace
                    withAnimation {
                        step = .ready
                    }
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

#Preview {
    OnboardingCoordinator(onComplete: {})
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Onboarding/OnboardingCoordinator.swift
git commit -m "feat: add OnboardingCoordinator with step navigation"
```

---

## Phase 5: Home View

### Task 5.1: Create HomeView

**Files:**
- Create: `Ember/Views/Home/HomeView.swift`

**Step 1: Create HomeView.swift**

```swift
import SwiftUI

struct HomeView: View {
    @ObservedObject var userService = UserService.shared
    @ObservedObject var taskService = TaskService.shared
    @State private var selectedTask: DailyTask?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmosBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HeaderView(name: userService.user.name, streak: userService.user.currentStreak)

                        // Progress card
                        ProgressCard(
                            stardust: userService.user.stardust,
                            level: userService.user.level
                        )
                        .padding(.horizontal, 20)

                        // Daily tasks
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

                            ForEach(taskService.dailyTasks) { dailyTask in
                                TaskCard(dailyTask: dailyTask) {
                                    selectedTask = dailyTask
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

struct HeaderView: View {
    let name: String
    let streak: Int

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting),")
                    .font(.subheadline)
                    .foregroundColor(.starWhite.opacity(0.7))
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)
            }

            Spacer()

            if streak > 0 {
                StreakBadge(days: streak)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ProgressCard: View {
    let stardust: Int
    let level: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                StardustCounter(amount: stardust)
                Spacer()
            }

            LevelProgressView(stardust: stardust)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cosmosPurple)
        )
    }
}

struct TaskCard: View {
    let dailyTask: DailyTask
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(dailyTask.isCompleted ? Color.softLavender.opacity(0.3) : Color.cosmosPurple)
                        .frame(width: 44, height: 44)

                    if dailyTask.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.softLavender)
                    } else {
                        Image(systemName: dailyTask.task.category.icon)
                            .foregroundColor(.softLavender)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(dailyTask.task.title)
                        .font(.headline)
                        .foregroundColor(dailyTask.isCompleted ? .starWhite.opacity(0.5) : .starWhite)

                    Text(dailyTask.task.category.displayName)
                        .font(.caption)
                        .foregroundColor(.softLavender.opacity(0.7))
                }

                Spacer()

                if !dailyTask.isCompleted {
                    Text("+\(dailyTask.task.stardustReward)")
                        .font(.caption)
                        .foregroundColor(.softPeach)

                    Image(systemName: "chevron.right")
                        .foregroundColor(.starWhite.opacity(0.5))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(dailyTask.isCompleted ? Color.cosmosPurple.opacity(0.5) : Color.cosmosPurple)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(dailyTask.isCompleted)
    }
}

#Preview {
    HomeView()
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Home/HomeView.swift
git commit -m "feat: add HomeView with header, progress, and task cards"
```

---

## Phase 6: Task Detail & Completion

### Task 6.1: Create TaskDetailView

**Files:**
- Create: `Ember/Views/Tasks/TaskDetailView.swift`

**Step 1: Create TaskDetailView.swift**

```swift
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
                    // Header
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

                    // Task content based on type
                    taskContent
                        .padding(.horizontal, 24)

                    // Note field for choice_with_note
                    if dailyTask.task.uiType == .choiceWithNote {
                        noteField
                            .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 100)
                }
            }

            // Complete button
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

            // Celebration overlay
            if showCelebration {
                CelebrationView(
                    stardust: dailyTask.task.stardustReward,
                    onDismiss: {
                        dismiss()
                    }
                )
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
        case .simpleChoice, .choiceWithNote:
            return !selectedOptions.isEmpty
        case .multiSelect:
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

#Preview {
    NavigationStack {
        TaskDetailView(dailyTask: DailyTask(task: RecoveryTask(
            id: "test",
            category: .breathe,
            title: "Box Breathing",
            description: "A calming technique",
            uiType: .simpleChoice,
            options: [
                TaskOption(id: "1", text: "Option 1"),
                TaskOption(id: "2", text: "Option 2")
            ],
            duration: nil,
            stardustReward: 45
        )))
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Tasks/TaskDetailView.swift
git commit -m "feat: add TaskDetailView with all UI types"
```

---

### Task 6.2: Create TimedActivityView

**Files:**
- Create: `Ember/Views/Tasks/TimedActivityView.swift`

**Step 1: Create TimedActivityView.swift**

```swift
import SwiftUI

struct TimedActivityView: View {
    let duration: Int
    let onComplete: () -> Void

    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var isComplete = false
    @State private var timer: Timer?

    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 32) {
            // Timer circle
            ZStack {
                Circle()
                    .stroke(Color.cosmosPurple, lineWidth: 8)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.softLavender, .softPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(.starWhite)

                    if isComplete {
                        Text("Complete!")
                            .font(.caption)
                            .foregroundColor(.softLavender)
                    }
                }
            }

            // Controls
            if !isComplete {
                Button(action: toggleTimer) {
                    ZStack {
                        Circle()
                            .fill(Color.softLavender)
                            .frame(width: 64, height: 64)

                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.cosmosBackground)
                    }
                }
            }
        }
    }

    private var progress: Double {
        1.0 - (Double(timeRemaining) / Double(duration))
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeTimer()
            }
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func completeTimer() {
        pauseTimer()
        isComplete = true
        onComplete()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    ZStack {
        Color.cosmosBackground
            .ignoresSafeArea()

        TimedActivityView(duration: 10, onComplete: {})
    }
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Tasks/TimedActivityView.swift
git commit -m "feat: add TimedActivityView with circular progress"
```

---

### Task 6.3: Create CelebrationView

**Files:**
- Create: `Ember/Views/Celebration/CelebrationView.swift`

**Step 1: Create CelebrationView.swift**

```swift
import SwiftUI

struct CelebrationView: View {
    let stardust: Int
    let badge: Badge?
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var particles: [Particle] = []

    init(stardust: Int, badge: Badge? = nil, onDismiss: @escaping () -> Void) {
        self.stardust = stardust
        self.badge = badge
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            Color.cosmosBackground.opacity(0.95)
                .ignoresSafeArea()

            // Particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }

            VStack(spacing: 32) {
                Spacer()

                // Success icon
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

                // Badge earned (if any)
                if let badge = badge {
                    VStack(spacing: 12) {
                        Text("Badge Earned!")
                            .font(.headline)
                            .foregroundColor(.softLavender)

                        HStack(spacing: 12) {
                            Image(systemName: badge.icon)
                                .font(.title)
                                .foregroundColor(.softPink)

                            VStack(alignment: .leading) {
                                Text(badge.name)
                                    .font(.headline)
                                    .foregroundColor(.starWhite)
                                Text(badge.description)
                                    .font(.caption)
                                    .foregroundColor(.starWhite.opacity(0.7))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cosmosPurple)
                        )
                    }
                    .opacity(showContent ? 1 : 0)
                }

                Spacer()

                PrimaryButton(title: "Continue", action: onDismiss)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }

            // Haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    private func generateParticles() {
        let colors: [Color] = [.softLavender, .softPink, .softPeach, .softBlue]

        for _ in 0..<30 {
            let particle = Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.3...0.8)
            )
            particles.append(particle)
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let opacity: Double
}

#Preview {
    CelebrationView(stardust: 45, onDismiss: {})
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Celebration/CelebrationView.swift
git commit -m "feat: add CelebrationView with particles and animations"
```

---

## Phase 7: Profile & Settings

### Task 7.1: Create ProfileView

**Files:**
- Create: `Ember/Views/Profile/ProfileView.swift`

**Step 1: Create ProfileView.swift**

```swift
import SwiftUI

struct ProfileView: View {
    @ObservedObject var userService = UserService.shared
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmosBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile header
                        ProfileHeader(user: userService.user)

                        // Stats
                        StatsGrid(user: userService.user)
                            .padding(.horizontal, 20)

                        // Badges
                        BadgesSection(earnedBadgeIds: userService.user.earnedBadgeIds)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.starWhite)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct ProfileHeader: View {
    let user: User

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.softLavender, .softPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Text(String(user.name.prefix(1)).uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.cosmosBackground)
            }

            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                let levelInfo = LevelInfo.level(for: user.stardust)
                Text("Level \(levelInfo.level) · \(levelInfo.name)")
                    .font(.subheadline)
                    .foregroundColor(.softLavender)
            }
        }
        .padding(.top, 20)
    }
}

struct StatsGrid: View {
    let user: User

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Total Stardust", value: "\(user.stardust)", icon: "sparkles", color: .softPeach)
            StatCard(title: "Current Streak", value: "\(user.currentStreak)", icon: "flame.fill", color: .softPink)
            StatCard(title: "Tasks Completed", value: "\(user.totalTasksCompleted)", icon: "checkmark.circle", color: .softLavender)
            StatCard(title: "Longest Streak", value: "\(user.longestStreak)", icon: "trophy", color: .softBlue)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.starWhite)

            Text(title)
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmosPurple)
        )
    }
}

struct BadgesSection: View {
    let earnedBadgeIds: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Badges")
                    .font(.headline)
                    .foregroundColor(.starWhite)

                Spacer()

                Text("\(earnedBadgeIds.count)/\(Badge.allBadges.count)")
                    .font(.caption)
                    .foregroundColor(.softLavender)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 16) {
                ForEach(Badge.allBadges) { badge in
                    BadgeItem(badge: badge, isEarned: earnedBadgeIds.contains(badge.id))
                }
            }
        }
    }
}

struct BadgeItem: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color.cosmosPurple : Color.cosmosPurple.opacity(0.3))
                    .frame(width: 56, height: 56)

                Image(systemName: badge.icon)
                    .font(.title2)
                    .foregroundColor(isEarned ? .softLavender : .gray.opacity(0.5))
            }

            Text(badge.name)
                .font(.caption2)
                .foregroundColor(isEarned ? .starWhite : .gray.opacity(0.5))
                .lineLimit(1)
        }
    }
}

#Preview {
    ProfileView()
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Profile/ProfileView.swift
git commit -m "feat: add ProfileView with stats and badges"
```

---

### Task 7.2: Create SettingsView

**Files:**
- Create: `Ember/Views/Profile/SettingsView.swift`

**Step 1: Create SettingsView.swift**

```swift
import SwiftUI

struct SettingsView: View {
    @ObservedObject var userService = UserService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPace: Pace
    @State private var notificationsEnabled: Bool
    @State private var streakAlertsEnabled: Bool
    @State private var notificationTime: Date

    init() {
        let user = UserService.shared.user
        _selectedPace = State(initialValue: user.pace)
        _notificationsEnabled = State(initialValue: user.notificationsEnabled)
        _streakAlertsEnabled = State(initialValue: user.streakAlertsEnabled)
        _notificationTime = State(initialValue: user.notificationTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmosBackground
                    .ignoresSafeArea()

                List {
                    // Pace section
                    Section {
                        ForEach(Pace.allCases, id: \.self) { pace in
                            Button(action: { selectedPace = pace }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(pace.displayName)
                                            .foregroundColor(.starWhite)
                                        Text("\(pace.dailyTaskCount) task\(pace.dailyTaskCount > 1 ? "s" : "") per day")
                                            .font(.caption)
                                            .foregroundColor(.starWhite.opacity(0.6))
                                    }
                                    Spacer()
                                    if selectedPace == pace {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.softLavender)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Daily Pace")
                            .foregroundColor(.softLavender)
                    }
                    .listRowBackground(Color.cosmosPurple)

                    // Notifications section
                    Section {
                        Toggle("Daily Reminders", isOn: $notificationsEnabled)
                            .tint(.softLavender)

                        if notificationsEnabled {
                            DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        }

                        Toggle("Streak Alerts", isOn: $streakAlertsEnabled)
                            .tint(.softLavender)
                    } header: {
                        Text("Notifications")
                            .foregroundColor(.softLavender)
                    }
                    .listRowBackground(Color.cosmosPurple)

                    // About section
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.starWhite.opacity(0.6))
                        }
                    } header: {
                        Text("About")
                            .foregroundColor(.softLavender)
                    }
                    .listRowBackground(Color.cosmosPurple)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.softLavender)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveSettings() }
                        .foregroundColor(.softLavender)
                }
            }
        }
    }

    private func saveSettings() {
        userService.user.pace = selectedPace
        userService.user.notificationsEnabled = notificationsEnabled
        userService.user.streakAlertsEnabled = streakAlertsEnabled
        userService.user.notificationTime = notificationTime
        userService.save()

        // Update notifications
        if notificationsEnabled {
            NotificationService.shared.scheduleDailyReminder(at: notificationTime)
        } else {
            NotificationService.shared.cancelAllNotifications()
        }

        // Regenerate daily tasks if pace changed
        TaskService.shared.generateDailyTasks()

        dismiss()
    }
}

#Preview {
    SettingsView()
}
```

**Step 2: Commit**

```bash
git add Ember/Views/Profile/SettingsView.swift
git commit -m "feat: add SettingsView with pace and notification settings"
```

---

## Phase 8: Main App Integration

### Task 8.1: Create MainTabView

**Files:**
- Create: `Ember/Views/MainTabView.swift`

**Step 1: Create MainTabView.swift**

```swift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .tint(.softLavender)
    }
}

#Preview {
    MainTabView()
}
```

**Step 2: Commit**

```bash
git add Ember/Views/MainTabView.swift
git commit -m "feat: add MainTabView with Home and Profile tabs"
```

---

### Task 8.2: Update EmberApp Entry Point

**Files:**
- Modify: `Ember/App/EmberApp.swift`

**Step 1: Update EmberApp.swift**

```swift
import SwiftUI

@main
struct EmberApp: App {
    @StateObject private var userService = UserService.shared
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !userService.user.onboardingCompleted {
                    if showOnboarding {
                        OnboardingCoordinator {
                            // Onboarding complete
                        }
                    } else {
                        WelcomeView(showOnboarding: $showOnboarding)
                    }
                } else {
                    MainTabView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
```

**Step 2: Commit**

```bash
git add Ember/App/EmberApp.swift
git commit -m "feat: configure EmberApp entry point with onboarding flow"
```

---

## Phase 9: Final Testing & Polish

### Task 9.1: Build and Run

**Step 1: Build project**

Run: `Cmd+B` in Xcode
Expected: Build succeeds with no errors

**Step 2: Run on simulator**

Run: `Cmd+R` in Xcode
Expected: App launches, shows Welcome screen

**Step 3: Test complete flow**

1. Tap "Get Started"
2. Enter name, tap Continue
3. Select situation, tap Continue
4. Select goal, tap Continue
5. Complete 9-question assessment
6. See pace recommendation, tap "Begin Your Journey"
7. Home screen shows daily tasks
8. Complete a task
9. See celebration screen
10. Check Profile tab

**Step 4: Commit final state**

```bash
git add .
git commit -m "feat: complete Ember MVP implementation"
```

---

## Summary

**Total Tasks:** 22 tasks across 9 phases

**Phase 1:** Project structure, colors, models (6 tasks)
**Phase 2:** Services layer (4 tasks)
**Phase 3:** Reusable components (5 tasks)
**Phase 4:** Onboarding views (6 tasks)
**Phase 5:** Home view (1 task)
**Phase 6:** Task detail & completion (3 tasks)
**Phase 7:** Profile & settings (2 tasks)
**Phase 8:** Main app integration (2 tasks)
**Phase 9:** Final testing (1 task)

**Key Architecture Decisions:**
- MVVM with ObservableObject
- UserDefaults for simple persistence
- JSON bundle for static task content
- Singleton services for shared state
- SwiftUI-native animations
