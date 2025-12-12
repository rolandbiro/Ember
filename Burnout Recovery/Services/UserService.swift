import Foundation
import Combine

class UserService: ObservableObject {
    static let shared = UserService()

    @Published var user: User
    @Published var levelUpInfo: LevelInfo? = nil  // Set when user levels up

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
        let newLevelInfo = LevelInfo.level(for: user.stardust)
        if newLevelInfo.level > user.level {
            user.level = newLevelInfo.level
            levelUpInfo = newLevelInfo  // Trigger celebration
        }
    }

    func clearLevelUp() {
        levelUpInfo = nil
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
            break
        case 1:
            user.currentStreak += 1
            user.lastActiveDate = today
            if user.currentStreak > user.longestStreak {
                user.longestStreak = user.currentStreak
            }
        case 2:
            if user.streakFreezeAvailable && !user.streakFreezeUsedThisWeek {
                user.streakFreezeUsedThisWeek = true
                user.currentStreak += 1
                user.lastActiveDate = today
            } else {
                user.currentStreak = 1
                user.lastActiveDate = today
            }
        default:
            user.currentStreak = 1
            user.lastActiveDate = today
        }

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
