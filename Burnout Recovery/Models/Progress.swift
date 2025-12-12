import Foundation

struct LevelInfo {
    let level: Int
    let name: String
    let stardustRequired: Int

    static let levels: [LevelInfo] = [
        LevelInfo(level: 1, name: "Spark", stardustRequired: 0),
        LevelInfo(level: 2, name: "Flicker", stardustRequired: 200),
        LevelInfo(level: 3, name: "Glow", stardustRequired: 500),
        LevelInfo(level: 4, name: "Warmth", stardustRequired: 1000),
        LevelInfo(level: 5, name: "Radiance", stardustRequired: 2000),
        LevelInfo(level: 6, name: "Blaze", stardustRequired: 3500),
        LevelInfo(level: 7, name: "Brilliance", stardustRequired: 5500),
        LevelInfo(level: 8, name: "Ember Master", stardustRequired: 8000)
    ]

    static func level(for stardust: Int) -> LevelInfo {
        var result = levels[0]
        for level in levels {
            if stardust >= level.stardustRequired {
                result = level
            } else {
                break
            }
        }
        return result
    }

    static func progress(for stardust: Int) -> Double {
        let current = level(for: stardust)
        guard current.level < 8 else { return 1.0 }

        let next = levels[current.level]
        let progressInLevel = stardust - current.stardustRequired
        let levelRange = next.stardustRequired - current.stardustRequired
        return Double(progressInLevel) / Double(levelRange)
    }
}

struct StardustReward {
    static let taskCompletion = 30...75
    static let allDailyTasksBonus = 50
    static let dailyStreakBonus = 10
    static let weeklyAssessment = 100
}
