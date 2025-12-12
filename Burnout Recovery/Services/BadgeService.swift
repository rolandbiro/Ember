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

            if checkCondition(badge, user: user, task: completedTask) {
                UserService.shared.earnBadge(badge.id)
                newlyEarnedBadge = badge
                return // Show one badge at a time
            }
        }
    }

    private func checkCondition(_ badge: Badge, user: User, task: DailyTask?) -> Bool {
        switch badge.conditionType {
        case "firstTask":
            return user.totalTasksCompleted >= badge.conditionValue

        case "streakDays":
            return user.currentStreak >= badge.conditionValue

        case "taskAfterHour":
            guard let completedAt = task?.completedAt else { return false }
            let hour = Calendar.current.component(.hour, from: completedAt)
            return hour >= badge.conditionValue

        case "taskBeforeHour":
            guard let completedAt = task?.completedAt else { return false }
            let hour = Calendar.current.component(.hour, from: completedAt)
            return hour < badge.conditionValue

        case "notesWritten":
            return user.notesWritten >= badge.conditionValue

        case "levelReached":
            return user.level >= badge.conditionValue

        case "badgesEarned":
            return user.earnedBadgeIds.count >= badge.conditionValue

        default:
            return false
        }
    }

    func clearNewBadge() {
        newlyEarnedBadge = nil
    }
}
