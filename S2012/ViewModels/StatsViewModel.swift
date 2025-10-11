import Foundation
import SwiftUI
import Combine

class StatsViewModel: ObservableObject {
    @Published var stats = Stats()
    @Published var showResetAlert: Bool = false
    
    var streakText: String {
        if stats.currentStreak == 0 {
            return "No current streak"
        } else if stats.currentStreak == 1 {
            return "1 day"
        } else {
            return "\(stats.currentStreak) days"
        }
    }
    
    var bestScoreText: String {
        if stats.bestGameScore == 0 {
            return "No games played"
        } else {
            return "\(stats.bestGameScore) points"
        }
    }
    
    var fastestTimeText: String {
        if stats.fastestDailySetTime == 0 {
            return "No practice completed"
        } else {
            let minutes = Int(stats.fastestDailySetTime) / 60
            let seconds = Int(stats.fastestDailySetTime) % 60
            
            if minutes > 0 {
                return String(format: "%dm %ds", minutes, seconds)
            } else {
                return String(format: "%ds", seconds)
            }
        }
    }
    
    var overallAccuracyText: String {
        if stats.totalTasksCompleted == 0 {
            return "No tasks completed"
        } else {
            let percentage = Int(stats.overallAccuracy * 100)
            return "\(percentage)%"
        }
    }
    
    var totalTasksText: String {
        if stats.totalTasksCompleted == 0 {
            return "No tasks completed"
        } else if stats.totalTasksCompleted == 1 {
            return "1 task completed"
        } else {
            return "\(stats.totalTasksCompleted) tasks completed"
        }
    }
    
    var badgeProgress: Double {
        let total = Badge.allBadges.count
        let unlocked = stats.unlockedBadges.count
        return total > 0 ? Double(unlocked) / Double(total) : 0
    }
    
    var badgeProgressText: String {
        let unlocked = stats.unlockedBadges.count
        let total = Badge.allBadges.count
        return "\(unlocked)/\(total) badges earned"
    }
    
    func showResetConfirmation() {
        showResetAlert = true
    }
    
    func resetProgress() {
        stats.resetAllStats()
        showResetAlert = false
        
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func cancelReset() {
        showResetAlert = false
    }
    
    func getBadgeRows() -> [[Badge]] {
        let allBadges = Badge.allBadges
        var rows: [[Badge]] = []
        
        for i in stride(from: 0, to: allBadges.count, by: 2) {
            let endIndex = min(i + 2, allBadges.count)
            let row = Array(allBadges[i..<endIndex])
            rows.append(row)
        }
        
        return rows
    }
    
    func getBadgeState(_ badge: Badge) -> BadgeState {
        if let userBadge = stats.badges.first(where: { $0.id == badge.id }) {
            return userBadge.isUnlocked ? .unlocked : .locked
        }
        return .locked
    }
    
    func getBadgeOpacity(_ badge: Badge) -> Double {
        return getBadgeState(badge) == .unlocked ? 1.0 : 0.4
    }
    
    func getBadgeBackgroundColor(_ badge: Badge) -> Color {
        return getBadgeState(badge) == .unlocked ? AppColors.yolkYellow.opacity(0.2) : AppColors.cardBackground
    }
    
    func getBadgeIconColor(_ badge: Badge) -> Color {
        return getBadgeState(badge) == .unlocked ? AppColors.yolkYellow : AppColors.secondaryText
    }
    
    func getFormattedUnlockDate(_ badge: Badge) -> String {
        guard let userBadge = stats.badges.first(where: { $0.id == badge.id }),
              let unlockDate = userBadge.unlockedDate else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Unlocked \(formatter.string(from: unlockDate))"
    }
}

enum BadgeState {
    case locked, unlocked
}
