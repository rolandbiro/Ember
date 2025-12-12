import Foundation
import Combine

class TaskService: ObservableObject {
    static let shared = TaskService()

    @Published var allTasks: [RecoveryTask] = []
    @Published var dailyTasks: [DailyTask] = []

    private let lastGeneratedKey = "ember_last_generated"
    private let dailyTaskIdsKey = "ember_daily_task_ids"

    private init() {
        loadTasksFromBundle()
        loadOrGenerateDailyTasks()
    }

    private func loadTasksFromBundle() {
        guard let url = Bundle.main.url(forResource: "Tasks", withExtension: "json") else {
            print("❌ Tasks.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(TasksContainer.self, from: data)
            self.allTasks = decoded.tasks
            print("✅ Loaded \(decoded.tasks.count) tasks")
        } catch {
            print("❌ Failed to decode tasks: \(error)")
        }
    }

    private struct TasksContainer: Codable {
        let version: String?
        let tasks: [RecoveryTask]
    }

    func loadOrGenerateDailyTasks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastGenerated = UserDefaults.standard.object(forKey: lastGeneratedKey) as? Date,
           calendar.isDate(lastGenerated, inSameDayAs: today),
           let savedIds = UserDefaults.standard.array(forKey: dailyTaskIdsKey) as? [String] {
            dailyTasks = savedIds.compactMap { id in
                guard let task = allTasks.first(where: { $0.id == id }) else { return nil }
                return DailyTask(task: task)
            }
            if !dailyTasks.isEmpty { return }
        }

        generateDailyTasks()
    }

    func generateDailyTasks() {
        let pace = UserService.shared.user.pace
        let count = pace.dailyTaskCount

        var selectedTasks: [RecoveryTask] = []
        var usedCategories: Set<TaskCategory> = []
        let shuffledTasks = allTasks.shuffled()

        for task in shuffledTasks {
            if selectedTasks.count >= count { break }
            if !usedCategories.contains(task.category) {
                selectedTasks.append(task)
                usedCategories.insert(task.category)
            }
        }

        // Fill remaining if needed
        if selectedTasks.count < count {
            for task in shuffledTasks {
                if selectedTasks.count >= count { break }
                if !selectedTasks.contains(where: { $0.id == task.id }) {
                    selectedTasks.append(task)
                }
            }
        }

        dailyTasks = selectedTasks.map { DailyTask(task: $0) }

        UserDefaults.standard.set(Date(), forKey: lastGeneratedKey)
        UserDefaults.standard.set(selectedTasks.map { $0.id }, forKey: dailyTaskIdsKey)
    }

    func completeTask(_ dailyTask: DailyTask, selectedOptions: [String], note: String?) {
        guard let index = dailyTasks.firstIndex(where: { $0.id == dailyTask.id }) else { return }

        dailyTasks[index].isCompleted = true
        dailyTasks[index].completedAt = Date()
        dailyTasks[index].selectedOptionIds = selectedOptions
        dailyTasks[index].note = note

        let reward = dailyTask.task.stardustReward
        UserService.shared.addStardust(reward)
        UserService.shared.recordTaskCompletion(hasNote: note != nil)
        UserService.shared.updateStreak()

        if dailyTasks.allSatisfy({ $0.isCompleted }) {
            UserService.shared.addStardust(StardustReward.allDailyTasksBonus)
        }

        BadgeService.shared.checkBadges(for: dailyTask)
    }

    var completedCount: Int {
        dailyTasks.filter { $0.isCompleted }.count
    }

    var allCompleted: Bool {
        dailyTasks.allSatisfy { $0.isCompleted }
    }

    func addBonusTask() {
        let currentIds = Set(dailyTasks.map { $0.task.id })
        let available = allTasks.filter { !currentIds.contains($0.id) }
        guard let bonus = available.randomElement() else { return }
        dailyTasks.append(DailyTask(task: bonus))
    }
}
