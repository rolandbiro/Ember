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
    let duration: Int?
    let stardustReward: Int
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
