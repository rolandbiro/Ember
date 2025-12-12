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
