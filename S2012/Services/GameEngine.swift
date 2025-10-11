import Foundation
import Combine

class GameEngine: ObservableObject {
    @Published var currentQuestion: GameQuestion?
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var isGameActive: Bool = false
    @Published var gameEnded: Bool = false
    @Published var accuracy: Double = 0.0
    @Published var totalQuestions: Int = 0
    @Published var correctAnswers: Int = 0
    
    private var timer: Timer?
    private let converter = ConverterService.shared
    private var usedQuestions: Set<String> = []
    
    func startGame() {
        resetGame()
        isGameActive = true
        gameEnded = false
        generateNextQuestion()
        startTimer()
    }
    
    func endGame() {
        isGameActive = false
        gameEnded = true
        timer?.invalidate()
        timer = nil
        
        // Calculate final accuracy
        if totalQuestions > 0 {
            accuracy = Double(correctAnswers) / Double(totalQuestions)
        }
    }
    
    func submitAnswer(_ selectedAnswer: Double) {
        guard let question = currentQuestion, isGameActive else { return }
        
        totalQuestions += 1
        let isCorrect = abs(selectedAnswer - question.correctAnswer) < 0.001
        
        if isCorrect {
            score += 1
            correctAnswers += 1
        }
        
        // Brief pause to show result, then next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.isGameActive {
                self.generateNextQuestion()
            }
        }
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = 60
        totalQuestions = 0
        correctAnswers = 0
        accuracy = 0.0
        usedQuestions.removeAll()
        currentQuestion = nil
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    private func generateNextQuestion() {
        let categories = UnitCategory.allCases
        let category = categories.randomElement()!
        
        guard let question = generateQuestion(for: category) else {
            // Fallback if we can't generate a question
            endGame()
            return
        }
        
        currentQuestion = question
    }
    
    private func generateQuestion(for category: UnitCategory) -> GameQuestion? {
        let units = category.units
        guard units.count >= 2 else { return nil }
        
        let fromUnit = units.randomElement()!
        let toUnit = units.filter { $0.name != fromUnit.name }.randomElement()!
        
        let value = generateGameValue(for: category)
        
        guard let correctAnswer = converter.convert(value: value, from: fromUnit, to: toUnit) else {
            return nil
        }
        
        // Create unique identifier for this question
        let questionId = "\(category.rawValue)-\(fromUnit.name)-\(toUnit.name)-\(value)"
        
        // Skip if we've used this question recently
        if usedQuestions.contains(questionId) && usedQuestions.count < 20 {
            return generateQuestion(for: category) // Try again
        }
        
        usedQuestions.insert(questionId)
        if usedQuestions.count > 30 {
            // Clear old questions to allow reuse
            usedQuestions.removeAll()
        }
        
        let options = generateOptions(correctAnswer: correctAnswer, category: category)
        let question = "Convert \(formatGameValue(value)) \(fromUnit.symbol) to \(toUnit.symbol)"
        
        let explanation = generateGameExplanation(
            value: value,
            fromUnit: fromUnit,
            toUnit: toUnit,
            result: correctAnswer,
            category: category
        )
        
        return GameQuestion(
            question: question,
            correctAnswer: correctAnswer,
            options: options,
            explanation: explanation,
            category: category
        )
    }
    
    private func generateGameValue(for category: UnitCategory) -> Double {
        switch category {
        case .length:
            return [1, 2, 5, 10, 12, 25, 50, 100].randomElement()!
        case .mass:
            return [1, 2, 4, 8, 16, 32].randomElement()!
        case .temperature:
            return [0, 32, 100, 212, 25, 68, 98.6].randomElement()!
        case .volume:
            return [1, 2, 3, 4, 5, 8, 10].randomElement()!
        case .speed:
            return [30, 60, 100, 120].randomElement()!
        }
    }
    
    private func generateOptions(correctAnswer: Double, category: UnitCategory) -> [Double] {
        var options: [Double] = [correctAnswer]
        
        // Generate 3 plausible distractors
        for _ in 0..<3 {
            let distractor = generateDistractor(correctAnswer: correctAnswer, category: category)
            
            // Ensure no duplicates
            if !options.contains(where: { abs($0 - distractor) < 0.001 }) {
                options.append(distractor)
            }
        }
        
        // Fill any missing options with additional distractors
        while options.count < 4 {
            let distractor = generateDistractor(correctAnswer: correctAnswer, category: category)
            if !options.contains(where: { abs($0 - distractor) < 0.001 }) {
                options.append(distractor)
            }
        }
        
        return options.shuffled()
    }
    
    private func generateDistractor(correctAnswer: Double, category: UnitCategory) -> Double {
        let multipliers: [Double]
        
        switch category {
        case .temperature:
            // Temperature distractors should be more carefully chosen
            multipliers = [0.5, 0.8, 1.2, 1.5, 2.0]
        default:
            multipliers = [0.3, 0.5, 0.7, 1.3, 1.7, 2.0, 3.0]
        }
        
        let multiplier = multipliers.randomElement()!
        var distractor = correctAnswer * multiplier
        
        // Add some random variation
        let variation = Double.random(in: 0.9...1.1)
        distractor *= variation
        
        // Ensure positive values for most categories
        if category != .temperature {
            distractor = abs(distractor)
        }
        
        return distractor
    }
    
    private func formatGameValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func generateGameExplanation(
        value: Double,
        fromUnit: ConversionUnit,
        toUnit: ConversionUnit,
        result: Double,
        category: UnitCategory
    ) -> String {
        switch category {
        case .length:
            if fromUnit.name.contains("Inches") && toUnit.name.contains("Centimeters") {
                return "Remember: 1 inch = 2.54 cm"
            } else if fromUnit.name.contains("Feet") && toUnit.name.contains("Meters") {
                return "Remember: 1 foot = 0.3048 meters"
            }
        case .mass:
            if fromUnit.name.contains("Pounds") && toUnit.name.contains("Kilograms") {
                return "Remember: 1 pound = 0.454 kg"
            } else if fromUnit.name.contains("Ounces") && toUnit.name.contains("Grams") {
                return "Remember: 1 ounce = 28.35 grams"
            }
        case .temperature:
            guard case .temperature(let from) = fromUnit.type,
                  case .temperature(let to) = toUnit.type else {
                return "Temperature conversion"
            }
            
            switch (from, to) {
            case (.celsius, .fahrenheit):
                return "Remember: °F = °C × 9/5 + 32"
            case (.fahrenheit, .celsius):
                return "Remember: °C = (°F - 32) × 5/9"
            case (.celsius, .kelvin):
                return "Remember: K = °C + 273.15"
            default:
                return "Temperature conversion formula"
            }
        case .volume:
            if fromUnit.name.contains("Cups") && toUnit.name.contains("Milliliters") {
                return "Remember: 1 US cup = 236.6 mL"
            }
        case .speed:
            if fromUnit.name.contains("Miles") && toUnit.name.contains("Kilometers") {
                return "Remember: 1 mph = 1.609 km/h"
            }
        }
        
        return "Quick tip: Practice makes perfect!"
    }
    
    deinit {
        timer?.invalidate()
    }
}
