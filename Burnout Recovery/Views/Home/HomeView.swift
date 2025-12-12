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
                        HeaderView(name: userService.user.name, streak: userService.user.currentStreak)

                        ProgressCard(
                            stardust: userService.user.stardust,
                            level: userService.user.level
                        )
                        .padding(.horizontal, 20)

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
