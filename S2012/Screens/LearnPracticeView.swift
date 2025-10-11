import SwiftUI

struct LearnPracticeView: View {
    @StateObject private var viewModel = PracticeViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBackground.ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.sessionCompleted {
                    CompletionView(viewModel: viewModel)
                } else if viewModel.currentSession != nil {
                    PracticeSessionView(viewModel: viewModel, isInputFocused: $isInputFocused)
                } else {
                    WelcomeView(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                isInputFocused = false
            }
        }
        .alert("Badge Unlocked!", isPresented: Binding(
            get: { viewModel.newBadgeUnlocked != nil },
            set: { _ in viewModel.dismissBadgeAlert() }
        )) {
            Button("Awesome!") {
                viewModel.dismissBadgeAlert()
            }
        } message: {
            if let badge = viewModel.newBadgeUnlocked {
                Text("You've earned the \(badge.name) badge!\n\(badge.description)")
            }
        }
    }
}

struct WelcomeView: View {
    @ObservedObject var viewModel: PracticeViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(AppColors.yolkYellow)
                
                VStack(spacing: 8) {
                    Text("Daily Practice")
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Sharpen your conversion skills with guided exercises")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            // Stats Cards
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    StatCard(
                        title: "Current Streak",
                        value: "\(viewModel.stats.currentStreak)",
                        subtitle: viewModel.stats.currentStreak == 1 ? "day" : "days",
                        icon: "flame.fill",
                        color: AppColors.chickenRed
                    )
                    
                    StatCard(
                        title: "Accuracy",
                        value: "\(Int(viewModel.stats.overallAccuracy * 100))%",
                        subtitle: "overall",
                        icon: "target",
                        color: AppColors.yolkYellow
                    )
                }
                
                StatCard(
                    title: "Tasks Completed",
                    value: "\(viewModel.stats.totalTasksCompleted)",
                    subtitle: "total conversions",
                    icon: "checkmark.circle.fill",
                    color: AppColors.yolkYellow,
                    isWide: true
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Start Button
            VStack(spacing: 16) {
                PrimaryButton(title: "Start Daily Practice") {
                    viewModel.startDailyPractice()
                }
                
                Text("Complete 8 conversion tasks to maintain your streak")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct PracticeSessionView: View {
    @ObservedObject var viewModel: PracticeViewModel
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress Header
            VStack(spacing: 16) {
                HStack {
                    Button("Exit") {
                        viewModel.currentSession = nil
                    }
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("Tasks Completed: \(viewModel.progressText)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                ProgressBar(progress: viewModel.progress, height: 6)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Current Task
                    if let task = viewModel.currentTask {
                        TaskCard(
                            task: task,
                            userAnswer: $viewModel.userAnswer,
                            isInputFocused: $isInputFocused,
                            canCheck: viewModel.canCheckAnswer,
                            onCheck: viewModel.checkAnswer
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // Result Card
                    if viewModel.showResult {
                        TaskResultCard(
                            isCorrect: viewModel.isCorrect,
                            message: viewModel.getResultMessage(),
                            explanation: viewModel.showExplanation ? (viewModel.currentTask?.explanation ?? "") : "",
                            correctAnswer: viewModel.getFormattedCorrectAnswer(),
                            isVisible: viewModel.showResult
                        )
                        .padding(.horizontal, 24)
                        
                        if viewModel.showExplanation {
                            PrimaryButton(title: "Next Task") {
                                viewModel.nextTask()
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
}

struct TaskCard: View {
    let task: ConversionTask
    @Binding var userAnswer: String
    @FocusState.Binding var isInputFocused: Bool
    let canCheck: Bool
    let onCheck: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Task Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: task.category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.yolkYellow)
                    
                    Text(task.category.rawValue)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                }
                
                HStack {
                    Text(task.formattedQuestion)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            
            // Answer Input
            VStack(spacing: 16) {
                TextField("Your answer", text: $userAnswer)
                    .textFieldStyle(InputFieldStyle())
                    .keyboardType(.decimalPad)
                    .focused($isInputFocused)
                
                PrimaryButton(
                    title: "Check",
                    isEnabled: canCheck
                ) {
                    isInputFocused = false
                    onCheck()
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}

struct CompletionView: View {
    @ObservedObject var viewModel: PracticeViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Completion Animation
            VStack(spacing: 20) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(AppColors.yolkYellow)
                
                VStack(spacing: 8) {
                    Text("Daily set complete!")
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Great work on today's practice")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            // Session Stats
            if let session = viewModel.currentSession {
                VStack(spacing: 16) {
                    StatRow(label: "Accuracy", value: "\(Int(session.accuracy * 100))%")
                    StatRow(label: "Time", value: formatTime(session.duration))
                    StatRow(label: "Streak", value: "\(viewModel.stats.currentStreak) days")
                }
                .padding(20)
                .cardStyle()
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                PrimaryButton(title: "Practice Again") {
                    viewModel.startNewSession()
                }
                
                SecondaryButton(title: "Back to Home") {
                    viewModel.currentSession = nil
                    viewModel.sessionCompleted = false
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct LoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(AppColors.yolkYellow)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            Text("Preparing your practice session...")
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let isWide: Bool
    
    init(title: String, value: String, subtitle: String, icon: String, color: Color, isWide: Bool = false) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.isWide = isWide
    }
    
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
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Spacer()
                }
            }
            
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 100)
        .cardStyle()
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.body)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
        }
    }
}

#Preview {
    LearnPracticeView()
}
