import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameEngine = GameEngine()
    @Published var selectedAnswer: Double?
    @Published var showResult: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var showEndScreen: Bool = false
    @Published var newBestScore: Bool = false
    
    @Published var stats = Stats()
    
    var isNewBest: Bool {
        gameEngine.score > stats.bestGameScore
    }
    
    var accuracyPercentage: Int {
        Int(gameEngine.accuracy * 100)
    }
    
    var currentQuestionNumber: Int {
        gameEngine.totalQuestions + 1
    }
    
    func startGame() {
        gameEngine.startGame()
        showEndScreen = false
        newBestScore = false
        selectedAnswer = nil
        showResult = false
    }
    
    func selectAnswer(_ answer: Double) {
        guard gameEngine.isGameActive, selectedAnswer == nil else { return }
        
        selectedAnswer = answer
        
        // Check if correct
        if let currentQuestion = gameEngine.currentQuestion {
            lastAnswerCorrect = abs(answer - currentQuestion.correctAnswer) < 0.001
            showResult = true
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: lastAnswerCorrect ? .light : .medium)
            impactFeedback.impactOccurred()
            
            // Submit answer to game engine
            gameEngine.submitAnswer(answer)
            
            // Reset for next question
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.selectedAnswer = nil
                self.showResult = false
            }
        }
    }
    
    func endGame() {
        gameEngine.endGame()
        
        // Check for new best score
        if gameEngine.score > stats.bestGameScore {
            newBestScore = true
            stats.recordGameScore(gameEngine.score)
        }
        
        showEndScreen = true
        
        // Add completion haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(newBestScore ? .success : .warning)
    }
    
    func playAgain() {
        startGame()
    }
    
    func getOptionColor(for option: Double) -> Color {
        guard showResult, let selected = selectedAnswer else {
            return AppColors.cardBackground
        }
        
        if abs(option - selected) < 0.001 {
            // This is the selected option
            return lastAnswerCorrect ? AppColors.yolkYellow : AppColors.chickenRed
        } else if let currentQuestion = gameEngine.currentQuestion,
                  abs(option - currentQuestion.correctAnswer) < 0.001 {
            // This is the correct option (show if user was wrong)
            return lastAnswerCorrect ? AppColors.cardBackground : AppColors.yolkYellow.opacity(0.6)
        }
        
        return AppColors.cardBackground
    }
    
    func getOptionTextColor(for option: Double) -> Color {
        guard showResult, let selected = selectedAnswer else {
            return AppColors.primaryText
        }
        
        if abs(option - selected) < 0.001 {
            // This is the selected option
            return lastAnswerCorrect ? AppColors.primaryBackground : AppColors.primaryText
        } else if let currentQuestion = gameEngine.currentQuestion,
                  abs(option - currentQuestion.correctAnswer) < 0.001 {
            // This is the correct option
            return lastAnswerCorrect ? AppColors.primaryText : AppColors.primaryBackground
        }
        
        return AppColors.primaryText
    }
    
    func getTimerColor() -> Color {
        if gameEngine.timeRemaining <= 10 {
            return AppColors.chickenRed
        } else if gameEngine.timeRemaining <= 20 {
            return AppColors.yolkYellow
        } else {
            return AppColors.primaryText
        }
    }
    
    func getEndScreenMessage() -> String {
        if newBestScore {
            return "New Best!"
        } else if gameEngine.score >= 15 {
            return "Excellent!"
        } else if gameEngine.score >= 10 {
            return "Great job!"
        } else if gameEngine.score >= 5 {
            return "Good effort!"
        } else {
            return "Keep practicing!"
        }
    }
    
    func getQuickTip() -> String {
        let tips = [
            "Remember: 1 inch = 2.54 cm",
            "Remember: 1 pound = 0.454 kg",
            "Remember: °F = °C × 9/5 + 32",
            "Remember: 1 mile = 1.609 km",
            "Remember: 1 US cup = 236.6 mL",
            "Practice makes perfect!",
            "Focus on common conversions first",
            "Use estimation to eliminate wrong answers"
        ]
        
        return tips.randomElement() ?? "Keep practicing!"
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
