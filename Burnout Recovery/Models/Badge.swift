import Foundation

struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let conditionType: String
    let conditionValue: Int

    static let allBadges: [Badge] = [
        Badge(id: "first_light", name: "First Light", description: "Complete your first task", icon: "sparkle", conditionType: "firstTask", conditionValue: 1),
        Badge(id: "week_one", name: "Week One", description: "Maintain a 7-day streak", icon: "calendar", conditionType: "streakDays", conditionValue: 7),
        Badge(id: "night_owl", name: "Night Owl", description: "Complete a task after 9 PM", icon: "moon.stars", conditionType: "taskAfterHour", conditionValue: 21),
        Badge(id: "early_bird", name: "Early Bird", description: "Complete a task before 7 AM", icon: "sunrise", conditionType: "taskBeforeHour", conditionValue: 7),
        Badge(id: "storyteller", name: "Storyteller", description: "Write 10 optional notes", icon: "pencil.line", conditionType: "notesWritten", conditionValue: 10),
        Badge(id: "zen_mind", name: "Zen Mind", description: "Complete 10 breathing tasks", icon: "wind", conditionType: "categoryTasks", conditionValue: 10),
        Badge(id: "resilient", name: "Resilient", description: "Recover from a lost streak", icon: "arrow.counterclockwise", conditionType: "streakRecovered", conditionValue: 1),
        Badge(id: "focused", name: "Focused", description: "Complete all tasks 5 days in a row", icon: "target", conditionType: "allTasksDays", conditionValue: 5),
        Badge(id: "blooming", name: "Blooming", description: "Reach Level 3", icon: "leaf", conditionType: "levelReached", conditionValue: 3),
        Badge(id: "rising_star", name: "Rising Star", description: "Reach Level 5", icon: "star", conditionType: "levelReached", conditionValue: 5),
        Badge(id: "ember_master", name: "Ember Master", description: "Reach Level 8", icon: "flame", conditionType: "levelReached", conditionValue: 8),
        Badge(id: "monthly_hero", name: "Monthly Hero", description: "Maintain a 30-day streak", icon: "medal", conditionType: "streakDays", conditionValue: 30),
        Badge(id: "collector", name: "Collector", description: "Earn 5 badges", icon: "square.grid.2x2", conditionType: "badgesEarned", conditionValue: 5),
        Badge(id: "balanced", name: "Balanced", description: "Complete tasks in all 5 categories", icon: "circle.hexagongrid", conditionType: "allCategories", conditionValue: 5),
        Badge(id: "self_aware", name: "Self-Aware", description: "Complete 4 weekly assessments", icon: "brain.head.profile", conditionType: "assessments", conditionValue: 4)
    ]
}
