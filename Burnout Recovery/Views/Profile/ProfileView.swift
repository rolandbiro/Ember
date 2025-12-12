import SwiftUI

struct ProfileView: View {
    @ObservedObject var userService = UserService.shared
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeader(user: userService.user)
                    StatsGrid(user: userService.user)
                        .padding(.horizontal, 20)
                    BadgesSection(earnedBadgeIds: userService.user.earnedBadgeIds)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.visible)
            .background(Color.cosmosBackground)
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
