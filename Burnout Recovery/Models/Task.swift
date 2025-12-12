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
}

struct SliderConfig: Codable {
    let question: String?
    let min: Int?
    let max: Int?
    let minLabel: String?
    let maxLabel: String?
    let options: [String]?
}

struct FollowUpConfig: Codable {
    let question: String?
    let options: [String]?
}

struct RecoveryTask: Codable, Identifiable {
    let id: String
    let category: TaskCategory
    let title: String
    let description: String
    let uiType: TaskUIType
    let stardust: Int
    let duration: Int?
    let content: TaskContent?

    var stardustReward: Int { stardust }

    var options: [TaskOption]? {
        guard let opts = content?.options else { return nil }
        return opts.enumerated().map { TaskOption(id: "\(id)_\($0.offset)", text: $0.element) }
    }
}

struct DailyTask: Identifiable, Hashable {
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

    static func == (lhs: DailyTask, rhs: DailyTask) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
