import Foundation

struct ConversionTask: Identifiable {
    let id = UUID()
    let question: String
    let fromValue: Double
    let fromUnit: ConversionUnit
    let toUnit: ConversionUnit
    let correctAnswer: Double
    let explanation: String
    let category: UnitCategory
    
    var formattedQuestion: String {
        let formattedValue = formatValue(fromValue)
        return "Convert \(formattedValue) \(fromUnit.symbol) to \(toUnit.symbol)"
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

struct GameQuestion: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: Double
    let options: [Double]
    let explanation: String
    let category: UnitCategory
    
    var formattedOptions: [String] {
        options.map { formatAnswer($0) }
    }
    
    var formattedCorrectAnswer: String {
        formatAnswer(correctAnswer)
    }
    
    private func formatAnswer(_ value: Double) -> String {
        if abs(value) >= 1000 {
            return String(format: "%.1f", value)
        } else if abs(value) >= 10 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.3f", value)
        }
    }
}

struct TaskSession {
    let tasks: [ConversionTask]
    var completedTasks: [UUID] = []
    var correctAnswers: Int = 0
    var startTime: Date = Date()
    var endTime: Date?
    
    var isComplete: Bool {
        completedTasks.count == tasks.count
    }
    
    var accuracy: Double {
        guard !completedTasks.isEmpty else { return 0 }
        return Double(correctAnswers) / Double(completedTasks.count)
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    mutating func completeTask(taskId: UUID, isCorrect: Bool) {
        if !completedTasks.contains(taskId) {
            completedTasks.append(taskId)
            if isCorrect {
                correctAnswers += 1
            }
        }
        
        if isComplete && endTime == nil {
            endTime = Date()
        }
    }
}
