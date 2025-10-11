import Foundation
import Combine

class Stats: ObservableObject, Codable {
    @Published var currentStreak: Int = 0
    @Published var lastPracticeDate: Date?
    @Published var totalTasksCompleted: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var bestGameScore: Int = 0
    @Published var fastestDailySetTime: TimeInterval = 0
    @Published var badges: [Badge] = Badge.allBadges
    @Published var consecutiveCorrect: Int = 0
    @Published var categoryStats: [String: CategoryStats] = [:]
    
    enum CodingKeys: CodingKey {
        case currentStreak, lastPracticeDate, totalTasksCompleted, totalCorrectAnswers
        case bestGameScore, fastestDailySetTime, badges, consecutiveCorrect, categoryStats
    }
    
    init() {
        loadStats()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        lastPracticeDate = try container.decodeIfPresent(Date.self, forKey: .lastPracticeDate)
        totalTasksCompleted = try container.decode(Int.self, forKey: .totalTasksCompleted)
        totalCorrectAnswers = try container.decode(Int.self, forKey: .totalCorrectAnswers)
        bestGameScore = try container.decode(Int.self, forKey: .bestGameScore)
        fastestDailySetTime = try container.decode(TimeInterval.self, forKey: .fastestDailySetTime)
        badges = try container.decode([Badge].self, forKey: .badges)
        consecutiveCorrect = try container.decode(Int.self, forKey: .consecutiveCorrect)
        categoryStats = try container.decode([String: CategoryStats].self, forKey: .categoryStats)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(lastPracticeDate, forKey: .lastPracticeDate)
        try container.encode(totalTasksCompleted, forKey: .totalTasksCompleted)
        try container.encode(totalCorrectAnswers, forKey: .totalCorrectAnswers)
        try container.encode(bestGameScore, forKey: .bestGameScore)
        try container.encode(fastestDailySetTime, forKey: .fastestDailySetTime)
        try container.encode(badges, forKey: .badges)
        try container.encode(consecutiveCorrect, forKey: .consecutiveCorrect)
        try container.encode(categoryStats, forKey: .categoryStats)
    }
    
    var overallAccuracy: Double {
        guard totalTasksCompleted > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalTasksCompleted)
    }
    
    var unlockedBadges: [Badge] {
        badges.filter { $0.isUnlocked }
    }
    
    var lockedBadges: [Badge] {
        badges.filter { !$0.isUnlocked }
    }
    
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastPracticeDate {
            let lastPracticeDay = Calendar.current.startOfDay(for: lastDate)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastPracticeDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // If daysBetween == 0, same day, don't change streak
        } else {
            // First practice
            currentStreak = 1
        }
        
        lastPracticeDate = Date()
        checkBadgeUnlocks()
        saveStats()
    }
    
    func recordTaskCompletion(isCorrect: Bool, category: UnitCategory) {
        totalTasksCompleted += 1
        
        if isCorrect {
            totalCorrectAnswers += 1
            consecutiveCorrect += 1
        } else {
            consecutiveCorrect = 0
        }
        
        // Update category stats
        let categoryKey = category.rawValue
        if categoryStats[categoryKey] == nil {
            categoryStats[categoryKey] = CategoryStats()
        }
        categoryStats[categoryKey]?.recordTask(isCorrect: isCorrect)
        
        checkBadgeUnlocks()
        saveStats()
    }
    
    func recordGameScore(_ score: Int) {
        if score > bestGameScore {
            bestGameScore = score
        }
        checkBadgeUnlocks()
        saveStats()
    }
    
    func recordDailySetTime(_ time: TimeInterval) {
        if fastestDailySetTime == 0 || time < fastestDailySetTime {
            fastestDailySetTime = time
        }
        checkBadgeUnlocks()
        saveStats()
    }
    
    private func checkBadgeUnlocks() {
        for i in badges.indices {
            if !badges[i].isUnlocked {
                if shouldUnlockBadge(badges[i]) {
                    badges[i].unlock()
                }
            }
        }
    }
    
    private func shouldUnlockBadge(_ badge: Badge) -> Bool {
        switch badge.id {
        case "quick_thinker":
            return fastestDailySetTime > 0 && fastestDailySetTime < 60
        case "speed_devil":
            return fastestDailySetTime > 0 && fastestDailySetTime < 90
        case "thermo_tamer":
            let tempStats = categoryStats["Temperature"]
            return tempStats?.accuracy == 1.0 && (tempStats?.totalTasks ?? 0) >= 3
        case "volume_virtuoso":
            let volumeStats = categoryStats["Volume"]
            return (volumeStats?.correctTasks ?? 0) >= 5
        case "streak_starter":
            return currentStreak >= 3
        case "streak_master":
            return currentStreak >= 7
        case "game_champion":
            return bestGameScore >= 15
        case "precision_pro":
            return consecutiveCorrect >= 10
        default:
            return false
        }
    }
    
    func resetAllStats() {
        currentStreak = 0
        lastPracticeDate = nil
        totalTasksCompleted = 0
        totalCorrectAnswers = 0
        bestGameScore = 0
        fastestDailySetTime = 0
        consecutiveCorrect = 0
        categoryStats = [:]
        
        for i in badges.indices {
            badges[i].isUnlocked = false
            badges[i].unlockedDate = nil
        }
        
        saveStats()
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "YardYolkStats")
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: "YardYolkStats"),
           let decoded = try? JSONDecoder().decode(Stats.self, from: data) {
            self.currentStreak = decoded.currentStreak
            self.lastPracticeDate = decoded.lastPracticeDate
            self.totalTasksCompleted = decoded.totalTasksCompleted
            self.totalCorrectAnswers = decoded.totalCorrectAnswers
            self.bestGameScore = decoded.bestGameScore
            self.fastestDailySetTime = decoded.fastestDailySetTime
            self.badges = decoded.badges
            self.consecutiveCorrect = decoded.consecutiveCorrect
            self.categoryStats = decoded.categoryStats
        }
    }
}

struct CategoryStats: Codable {
    var totalTasks: Int = 0
    var correctTasks: Int = 0
    
    var accuracy: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(correctTasks) / Double(totalTasks)
    }
    
    mutating func recordTask(isCorrect: Bool) {
        totalTasks += 1
        if isCorrect {
            correctTasks += 1
        }
    }
}
