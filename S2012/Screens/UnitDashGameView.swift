import SwiftUI

struct UnitDashGameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBackground.ignoresSafeArea()
                
                if !viewModel.gameEngine.isGameActive && !viewModel.showEndScreen {
                    GameStartView(viewModel: viewModel)
                } else if viewModel.showEndScreen {
                    GameEndView(viewModel: viewModel)
                } else {
                    GamePlayView(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct GameStartView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Game Logo/Icon
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppColors.yolkYellow.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    
                    Circle()
                        .fill(AppColors.yolkYellow.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "speedometer")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(AppColors.yolkYellow)
                }
                
                VStack(spacing: 8) {
                    Text("Unit Dash")
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("60-second conversion challenge")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            // Game Rules
            VStack(spacing: 16) {
                GameRuleCard(
                    icon: "timer",
                    title: "60 Seconds",
                    description: "Answer as many questions as possible"
                )
                
                GameRuleCard(
                    icon: "target",
                    title: "Multiple Choice",
                    description: "Pick the correct conversion from 4 options"
                )
                
                GameRuleCard(
                    icon: "trophy.fill",
                    title: "Beat Your Best",
                    description: "Current best: \(viewModel.stats.bestGameScore) points"
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Start Button
            VStack(spacing: 16) {
                PrimaryButton(title: "Start") {
                    viewModel.startGame()
                }
                
                Text("Get ready to think fast!")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Game Header
            HStack {
                // Timer
                VStack(spacing: 4) {
                    Text("Time")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("\(viewModel.gameEngine.timeRemaining)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.getTimerColor())
                }
                
                Spacer()
                
                // Score
                VStack(spacing: 4) {
                    Text("Score")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("\(viewModel.gameEngine.score)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.yolkYellow)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Question Card
            if let question = viewModel.gameEngine.currentQuestion {
                QuestionCard(
                    question: question,
                    viewModel: viewModel
                )
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // End Game Button
            SecondaryButton(title: "End Game") {
                viewModel.endGame()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onReceive(viewModel.gameEngine.$gameEnded) { gameEnded in
            if gameEnded {
                viewModel.endGame()
            }
        }
    }
}

struct QuestionCard: View {
    let question: GameQuestion
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Question
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: question.category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.yolkYellow)
                    
                    Text(question.category.rawValue)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("Question \(viewModel.currentQuestionNumber)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                HStack {
                    Text(question.question)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            
            // Answer Options
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    AnswerOptionButton(
                        option: option,
                        formattedOption: question.formattedOptions[index],
                        isSelected: viewModel.selectedAnswer != nil && abs(viewModel.selectedAnswer! - option) < 0.001,
                        backgroundColor: viewModel.getOptionColor(for: option),
                        textColor: viewModel.getOptionTextColor(for: option),
                        isDisabled: viewModel.selectedAnswer != nil
                    ) {
                        if viewModel.selectedAnswer == nil {
                            viewModel.selectAnswer(option)
                        }
                    }
                }
            }
            
            // Result Feedback
            if viewModel.showResult {
                HStack {
                    Image(systemName: viewModel.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(viewModel.lastAnswerCorrect ? AppColors.yolkYellow : AppColors.chickenRed)
                    
                    Text(viewModel.lastAnswerCorrect ? "Correct!" : "Incorrect")
                        .font(AppTypography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.lastAnswerCorrect ? AppColors.yolkYellow : AppColors.chickenRed)
                    
                    if !viewModel.lastAnswerCorrect {
                        Text("• \(question.formattedCorrectAnswer)")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .cardStyle()
    }
}

struct AnswerOptionButton: View {
    let option: Double
    let formattedOption: String
    let isSelected: Bool
    let backgroundColor: Color
    let textColor: Color
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(formattedOption)
                .font(AppTypography.body)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? AppColors.yolkYellow : AppColors.cardBorder,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
        }
        .disabled(isDisabled)
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

struct GameEndView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Result Icon and Message
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(viewModel.newBestScore ? AppColors.yolkYellow.opacity(0.2) : AppColors.cardBackground)
                        .frame(width: 100, height: 100)
                        .blur(radius: viewModel.newBestScore ? 20 : 0)
                    
                    Image(systemName: viewModel.newBestScore ? "trophy.fill" : "flag.checkered")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(viewModel.newBestScore ? AppColors.yolkYellow : AppColors.secondaryText)
                }
                
                VStack(spacing: 8) {
                    Text(viewModel.getEndScreenMessage())
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    if viewModel.newBestScore {
                        Text("New personal best!")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.yolkYellow)
                    }
                }
            }
            
            // Game Stats
            VStack(spacing: 16) {
                StatRow(label: "Final Score", value: "\(viewModel.gameEngine.score) points")
                StatRow(label: "Accuracy", value: "\(viewModel.accuracyPercentage)%")
                StatRow(label: "Questions", value: "\(viewModel.gameEngine.totalQuestions)")
                
                if !viewModel.newBestScore && viewModel.stats.bestGameScore > 0 {
                    StatRow(label: "Best Score", value: "\(viewModel.stats.bestGameScore) points")
                }
            }
            .padding(20)
            .cardStyle()
            .padding(.horizontal, 24)
            
            // Quick Tip
            VStack(spacing: 8) {
                Text("Quick Tip")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                Text(viewModel.getQuickTip())
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                PrimaryButton(title: "Play Again") {
                    viewModel.playAgain()
                }
                
                SecondaryButton(title: "Back to Home") {
                    viewModel.showEndScreen = false
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct GameRuleCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppColors.yolkYellow)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppColors.yolkYellow.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(16)
        .cardStyle()
    }
}

#Preview {
    UnitDashGameView()
}
