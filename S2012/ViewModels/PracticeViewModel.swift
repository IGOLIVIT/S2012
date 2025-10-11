import Foundation
import SwiftUI
import Combine

class PracticeViewModel: ObservableObject {
    @Published var currentSession: TaskSession?
    @Published var currentTaskIndex: Int = 0
    @Published var userAnswer: String = ""
    @Published var showResult: Bool = false
    @Published var isCorrect: Bool = false
    @Published var showExplanation: Bool = false
    @Published var sessionCompleted: Bool = false
    @Published var newBadgeUnlocked: Badge?
    @Published var isLoading: Bool = false
    
    private let practiceEngine = PracticeEngine.shared
    private let converter = ConverterService.shared
    @Published var stats = Stats()
    
    var currentTask: ConversionTask? {
        guard let session = currentSession,
              currentTaskIndex < session.tasks.count else { return nil }
        return session.tasks[currentTaskIndex]
    }
    
    var progress: Double {
        guard let session = currentSession else { return 0 }
        return Double(session.completedTasks.count) / Double(session.tasks.count)
    }
    
    var progressText: String {
        guard let session = currentSession else { return "0/0" }
        return "\(session.completedTasks.count)/\(session.tasks.count)"
    }
    
    var canCheckAnswer: Bool {
        !userAnswer.isEmpty && Double(userAnswer) != nil
    }
    
    func startDailyPractice() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let tasks = self.practiceEngine.generateDailyTasks()
            self.currentSession = TaskSession(tasks: tasks)
            self.currentTaskIndex = 0
            self.resetCurrentTask()
            self.isLoading = false
        }
    }
    
    func checkAnswer() {
        guard let task = currentTask,
              let answer = Double(userAnswer) else { return }
        
        let correct = practiceEngine.checkAnswer(answer, for: task)
        isCorrect = correct
        showResult = true
        
        // Record the task completion
        currentSession?.completeTask(taskId: task.id, isCorrect: correct)
        stats.recordTaskCompletion(isCorrect: correct, category: task.category)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: correct ? .light : .medium)
        impactFeedback.impactOccurred()
        
        // Show explanation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showExplanation = true
        }
        
        // Check if session is complete
        if currentSession?.isComplete == true {
            completeSession()
        }
    }
    
    func nextTask() {
        guard let session = currentSession else { return }
        
        if currentTaskIndex < session.tasks.count - 1 {
            currentTaskIndex += 1
            resetCurrentTask()
        } else if session.isComplete {
            completeSession()
        }
    }
    
    private func resetCurrentTask() {
        userAnswer = ""
        showResult = false
        showExplanation = false
        isCorrect = false
    }
    
    private func completeSession() {
        guard let session = currentSession else { return }
        
        sessionCompleted = true
        
        // Update streak
        stats.updateStreak()
        
        // Record session time
        stats.recordDailySetTime(session.duration)
        
        // Check for new badge unlocks
        checkForNewBadges()
        
        // Add completion haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func checkForNewBadges() {
        let previousUnlockedCount = stats.unlockedBadges.count
        
        // Force badge check by accessing the stats
        _ = stats.unlockedBadges
        
        let newUnlockedCount = stats.unlockedBadges.count
        
        if newUnlockedCount > previousUnlockedCount {
            // Find the newly unlocked badge
            newBadgeUnlocked = stats.unlockedBadges.last
        }
    }
    
    func startNewSession() {
        currentSession = nil
        currentTaskIndex = 0
        sessionCompleted = false
        newBadgeUnlocked = nil
        resetCurrentTask()
        startDailyPractice()
    }
    
    func dismissBadgeAlert() {
        newBadgeUnlocked = nil
    }
    
    func getResultMessage() -> String {
        if isCorrect {
            return "Great job!"
        } else {
            return "Not quite. Here's how:"
        }
    }
    
    func getResultColor() -> Color {
        return isCorrect ? AppColors.yolkYellow : AppColors.chickenRed
    }
    
    func getFormattedCorrectAnswer() -> String {
        guard let task = currentTask else { return "" }
        let formatted = converter.formatResult(task.correctAnswer, for: task.toUnit)
        return "\(formatted) \(task.toUnit.symbol)"
    }
}
