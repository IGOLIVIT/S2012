import SwiftUI

struct ResultCard: View {
    let result: String
    let isVisible: Bool
    
    @State private var animatedValue: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "equal.circle.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppColors.yolkYellow)
            
            Text("Result")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            
            Text(result)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardStyle()
        .scaleEffect(scale)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: scale)
        .onChange(of: isVisible) { visible in
            if visible {
                scale = 1.0
            } else {
                scale = 0.8
            }
        }
    }
}

struct AnimatedResultCard: View {
    let finalValue: Double
    let unit: String
    let isVisible: Bool
    
    @State private var displayValue: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "equal.circle.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppColors.yolkYellow)
            
            Text("Result")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            
            Text(formatValue(displayValue) + " " + unit)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardStyle()
        .scaleEffect(scale)
        .opacity(isVisible ? 1 : 0)
        .onChange(of: isVisible) { visible in
            if visible {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.0
                }
                
                // Animate the number counting up
                withAnimation(.easeOut(duration: 0.6)) {
                    displayValue = finalValue
                }
            } else {
                scale = 0.8
                displayValue = 0
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else if abs(value) >= 1000 {
            return String(format: "%.1f", value)
        } else if abs(value) >= 10 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.3f", value)
        }
    }
}

struct TaskResultCard: View {
    let isCorrect: Bool
    let message: String
    let explanation: String
    let correctAnswer: String
    let isVisible: Bool
    
    @State private var scale: CGFloat = 0.8
    @State private var checkmarkScale: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Result icon with animation
            ZStack {
                Circle()
                    .fill(isCorrect ? AppColors.yolkYellow.opacity(0.2) : AppColors.chickenRed.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isCorrect ? AppColors.yolkYellow : AppColors.chickenRed)
                    .scaleEffect(checkmarkScale)
            }
            
            VStack(spacing: 8) {
                Text(message)
                    .font(AppTypography.headline)
                    .foregroundColor(isCorrect ? AppColors.yolkYellow : AppColors.chickenRed)
                
                if !isCorrect {
                    Text("Correct answer: \(correctAnswer)")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Text(explanation)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardStyle()
        .scaleEffect(scale)
        .opacity(isVisible ? 1 : 0)
        .onChange(of: isVisible) { visible in
            if visible {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                }
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                    checkmarkScale = 1.0
                }
                
                if !isCorrect {
                    // Add shake animation for wrong answers
                    withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                        // Shake effect would be implemented with offset
                    }
                }
            } else {
                scale = 0.8
                checkmarkScale = 0
            }
        }
    }
}

struct CompletionCard: View {
    let title: String
    let subtitle: String
    let stats: [(String, String)]
    let isVisible: Bool
    
    @State private var scale: CGFloat = 0.8
    @State private var confettiScale: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Celebration icon
            ZStack {
                Circle()
                    .fill(AppColors.yolkYellow.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(confettiScale)
                
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(AppColors.yolkYellow)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(AppTypography.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            // Stats
            VStack(spacing: 12) {
                ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                    HStack {
                        Text(stat.0)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                        
                        Text(stat.1)
                            .font(AppTypography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    if index < stats.count - 1 {
                        Divider()
                            .background(AppColors.cardBorder)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground.opacity(0.5))
            )
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .cardStyle()
        .scaleEffect(scale)
        .opacity(isVisible ? 1 : 0)
        .onChange(of: isVisible) { visible in
            if visible {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.0
                }
                
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    confettiScale = 1.0
                }
            } else {
                scale = 0.8
                confettiScale = 0
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ResultCard(result: "1000 m", isVisible: true)
            
            AnimatedResultCard(finalValue: 1609.34, unit: "m", isVisible: true)
            
            TaskResultCard(
                isCorrect: true,
                message: "Great job!",
                explanation: "1 km = 1000 m",
                correctAnswer: "1000 m",
                isVisible: true
            )
            
            TaskResultCard(
                isCorrect: false,
                message: "Not quite. Here's how:",
                explanation: "Remember: 1 inch = 2.54 cm",
                correctAnswer: "30.48 cm",
                isVisible: true
            )
            
            CompletionCard(
                title: "Daily set complete!",
                subtitle: "Great work on today's practice",
                stats: [
                    ("Accuracy", "87%"),
                    ("Time", "1m 23s"),
                    ("Streak", "5 days")
                ],
                isVisible: true
            )
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
