import Foundation

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: String
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    static let allBadges: [Badge] = [
        Badge(
            id: "quick_thinker",
            name: "Quick Thinker",
            description: "Complete a daily practice set in under 60 seconds",
            icon: "brain.head.profile",
            requirement: "Complete daily set < 60s"
        ),
        Badge(
            id: "thermo_tamer",
            name: "Thermo Tamer",
            description: "Master temperature conversions with 100% accuracy",
            icon: "thermometer",
            requirement: "100% accuracy on temperature tasks"
        ),
        Badge(
            id: "speed_devil",
            name: "Speed Devil",
            description: "Complete a daily practice set in under 90 seconds",
            icon: "speedometer",
            requirement: "Complete daily set < 90s"
        ),
        Badge(
            id: "volume_virtuoso",
            name: "Volume Virtuoso",
            description: "Perfect score on 5 volume conversion tasks",
            icon: "drop.fill",
            requirement: "5 perfect volume conversions"
        ),
        Badge(
            id: "streak_starter",
            name: "Streak Starter",
            description: "Maintain a 3-day practice streak",
            icon: "flame.fill",
            requirement: "3-day streak"
        ),
        Badge(
            id: "streak_master",
            name: "Streak Master",
            description: "Maintain a 7-day practice streak",
            icon: "flame.circle.fill",
            requirement: "7-day streak"
        ),
        Badge(
            id: "game_champion",
            name: "Game Champion",
            description: "Score 15+ points in Unit Dash",
            icon: "trophy.fill",
            requirement: "Score 15+ in Unit Dash"
        ),
        Badge(
            id: "precision_pro",
            name: "Precision Pro",
            description: "Get 10 conversions correct in a row",
            icon: "target",
            requirement: "10 correct in a row"
        )
    ]
    
    mutating func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
}

enum BadgeType {
    case speed(TimeInterval)
    case accuracy(Double, UnitCategory?)
    case streak(Int)
    case gameScore(Int)
    case consecutiveCorrect(Int)
    case categoryMastery(UnitCategory, Int)
}
