import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let height: CGFloat
    let showPercentage: Bool
    
    init(progress: Double, height: CGFloat = 8, showPercentage: Bool = false) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(AppColors.cardBackground)
                        .frame(height: height)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.yolkYellow, AppColors.yolkYellow.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: height)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: height)
        }
    }
}

struct CircularProgressBar: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool
    
    init(progress: Double, size: CGFloat = 60, lineWidth: CGFloat = 6, showPercentage: Bool = true) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(AppColors.cardBackground, lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.yolkYellow,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.2, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
        }
    }
}

struct AnimatedProgressBar: View {
    let progress: Double
    let height: CGFloat
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, height: CGFloat = 8) {
        self.progress = max(0, min(1, progress))
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(AppColors.cardBackground)
                    .frame(height: height)
                
                // Progress fill with shimmer effect
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.yolkYellow.opacity(0.6),
                                AppColors.yolkYellow,
                                AppColors.yolkYellow.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress, height: height)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newProgress in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newProgress
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basic Progress Bar")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            ProgressBar(progress: 0.7)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress Bar with Percentage")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            ProgressBar(progress: 0.45, showPercentage: true)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Circular Progress")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            HStack {
                CircularProgressBar(progress: 0.8)
                Spacer()
            }
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Animated Progress")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            AnimatedProgressBar(progress: 0.6)
        }
    }
    .padding()
    .background(AppColors.primaryBackground)
}
