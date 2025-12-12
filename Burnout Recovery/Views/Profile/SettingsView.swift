import SwiftUI

struct SettingsView: View {
    @ObservedObject var userService = UserService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPace: Pace
    @State private var notificationsEnabled: Bool
    @State private var streakAlertsEnabled: Bool

    init() {
        let user = UserService.shared.user
        _selectedPace = State(initialValue: user.pace)
        _notificationsEnabled = State(initialValue: user.notificationsEnabled)
        _streakAlertsEnabled = State(initialValue: user.streakAlertsEnabled)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmosBackground
                    .ignoresSafeArea()

                List {
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

                    Section {
                        Toggle("Daily Reminders", isOn: $notificationsEnabled)
                            .tint(.softLavender)

                        Toggle("Streak Alerts", isOn: $streakAlertsEnabled)
                            .tint(.softLavender)
                    } header: {
                        Text("Notifications")
                            .foregroundColor(.softLavender)
                    }
                    .listRowBackground(Color.cosmosPurple)

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
        userService.save()

        TaskService.shared.generateDailyTasks()
        dismiss()
    }
}
