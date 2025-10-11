import SwiftUI

struct SettingsStatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(AppColors.yolkYellow)
                            
                            Text("Stats & Badges")
                                .font(AppTypography.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                        }
                        
                        Text("Track your progress and achievements")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Current Streak
                    StreakCard(
                        streakCount: viewModel.stats.currentStreak,
                        streakText: viewModel.streakText
                    )
                    .padding(.horizontal, 24)
                    
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatsCard(
                            title: "Best Game Score",
                            value: viewModel.bestScoreText,
                            icon: "trophy.fill",
                            color: AppColors.yolkYellow
                        )
                        
                        StatsCard(
                            title: "Fastest Time",
                            value: viewModel.fastestTimeText,
                            icon: "stopwatch.fill",
                            color: AppColors.chickenRed
                        )
                        
                        StatsCard(
                            title: "Overall Accuracy",
                            value: viewModel.overallAccuracyText,
                            icon: "target",
                            color: AppColors.yolkYellow
                        )
                        
                        StatsCard(
                            title: "Total Tasks",
                            value: viewModel.totalTasksText,
                            icon: "checkmark.circle.fill",
                            color: AppColors.yolkYellow
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Badge Progress
                    BadgeProgressCard(
                        progress: viewModel.badgeProgress,
                        progressText: viewModel.badgeProgressText
                    )
                    .padding(.horizontal, 24)
                    
                    // Badges Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Badges")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                            
                            Text("\(viewModel.stats.unlockedBadges.count)/\(Badge.allBadges.count)")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(.horizontal, 24)
                        
                        BadgeGridView(viewModel: viewModel)
                            .padding(.horizontal, 24)
                    }
                    
                    // Reset Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Danger Zone")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.chickenRed)
                            Spacer()
                        }
                        
                        DestructiveButton(title: "Reset Progress") {
                            viewModel.showResetConfirmation()
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom spacing
                    Spacer(minLength: 100)
                }
                .padding(.vertical, 16)
            }
            .background(AppColors.primaryBackground)
            .navigationBarHidden(true)
        }
        .alert("Reset All Progress?", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) {
                viewModel.cancelReset()
            }
            Button("Reset", role: .destructive) {
                viewModel.resetProgress()
            }
        } message: {
            Text("This will clear your streak, badges, and stats.")
        }
    }
}

struct StreakCard: View {
    let streakCount: Int
    let streakText: String
    
    var body: some View {
        HStack(spacing: 20) {
            // Flame icon with animation
            ZStack {
                Circle()
                    .fill(AppColors.chickenRed.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(streakCount > 0 ? AppColors.chickenRed : AppColors.secondaryText)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current streak")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                Text(streakText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                if streakCount > 0 {
                    Text("Keep it up!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.chickenRed)
                } else {
                    Text("Start practicing to begin a streak")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .cardStyle()
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 90)
        .cardStyle()
    }
}

struct BadgeProgressCard: View {
    let progress: Double
    let progressText: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "rosette")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.yolkYellow)
                
                Text("Badge Progress")
                    .font(AppTypography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text(progressText)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            ProgressBar(progress: progress, height: 8)
        }
        .padding(20)
        .cardStyle()
    }
}

struct BadgeGridView: View {
    @ObservedObject var viewModel: StatsViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(Badge.allBadges) { badge in
                BadgeItemCard(
                    badge: badge,
                    isUnlocked: viewModel.getBadgeState(badge) == .unlocked,
                    opacity: viewModel.getBadgeOpacity(badge),
                    backgroundColor: viewModel.getBadgeBackgroundColor(badge),
                    iconColor: viewModel.getBadgeIconColor(badge),
                    unlockedDate: viewModel.getFormattedUnlockDate(badge)
                )
            }
        }
    }
}

struct BadgeItemCard: View {
    let badge: Badge
    let isUnlocked: Bool
    let opacity: Double
    let backgroundColor: Color
    let iconColor: Color
    let unlockedDate: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(
                                isUnlocked ? AppColors.yolkYellow.opacity(0.5) : AppColors.cardBorder,
                                lineWidth: 2
                            )
                    )
                
                Image(systemName: badge.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isUnlocked ? AppColors.primaryText : AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.requirement)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if isUnlocked && !unlockedDate.isEmpty {
                    Text(unlockedDate)
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(AppColors.yolkYellow)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isUnlocked ? AppColors.yolkYellow.opacity(0.3) : AppColors.cardBorder,
                            lineWidth: 1
                        )
                )
        )
        .opacity(opacity)
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
    }
}

#Preview {
    SettingsStatsView()
}
