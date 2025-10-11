import SwiftUI

struct BadgeGrid: View {
    let badges: [Badge]
    let unlockedBadges: [Badge]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(badges) { badge in
                BadgeCard(
                    badge: badge,
                    isUnlocked: unlockedBadges.contains { $0.id == badge.id }
                )
            }
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge icon
            Image(systemName: badge.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(isUnlocked ? AppColors.yolkYellow : AppColors.secondaryText)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(isUnlocked ? AppColors.yolkYellow.opacity(0.2) : AppColors.cardBackground)
                        .overlay(
                            Circle()
                                .stroke(
                                    isUnlocked ? AppColors.yolkYellow.opacity(0.5) : AppColors.cardBorder,
                                    lineWidth: 2
                                )
                        )
                )
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(AppTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? AppColors.primaryText : AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text(badge.requirement)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isUnlocked ? AppColors.yolkYellow.opacity(0.3) : AppColors.cardBorder,
                            lineWidth: 1
                        )
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
}

struct BadgeUnlockAnimation: View {
    let badge: Badge
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated badge icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(AppColors.yolkYellow.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .scaleEffect(scale * 1.2)
                
                // Badge background
                Circle()
                    .fill(AppColors.yolkYellow.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                
                // Badge icon
                Image(systemName: badge.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(AppColors.yolkYellow)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
            }
            
            VStack(spacing: 8) {
                Text("Badge Unlocked!")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.yolkYellow)
                    .opacity(opacity)
                
                Text(badge.name)
                    .font(AppTypography.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                    .opacity(opacity)
                
                Text(badge.description)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate badge appearance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Text("Badge Grid")
                .font(AppTypography.title)
                .foregroundColor(AppColors.primaryText)
            
            BadgeGrid(
                badges: Badge.allBadges,
                unlockedBadges: Array(Badge.allBadges.prefix(3))
            )
            .padding(.horizontal)
            
            Divider()
                .background(AppColors.cardBorder)
            
            Text("Badge Unlock Animation")
                .font(AppTypography.title)
                .foregroundColor(AppColors.primaryText)
            
            BadgeUnlockAnimation(badge: Badge.allBadges[0])
                .padding()
        }
    }
    .background(AppColors.primaryBackground)
}
