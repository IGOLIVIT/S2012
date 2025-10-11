import Foundation

class PracticeEngine {
    static let shared = PracticeEngine()
    private let converter = ConverterService.shared
    
    private init() {}
    
    func generateDailyTasks(count: Int = 8) -> [ConversionTask] {
        var tasks: [ConversionTask] = []
        let categories = UnitCategory.allCases
        
        // Ensure we have at least one task from each category
        for category in categories {
            if tasks.count < count {
                if let task = generateTask(for: category, difficulty: .easy) {
                    tasks.append(task)
                }
            }
        }
        
        // Fill remaining slots with random tasks of increasing difficulty
        while tasks.count < count {
            let category = categories.randomElement()!
            let difficulty: TaskDifficulty = tasks.count < 3 ? .easy : (tasks.count < 6 ? .medium : .hard)
            
            if let task = generateTask(for: category, difficulty: difficulty) {
                // Avoid duplicate conversions
                let isDuplicate = tasks.contains { existingTask in
                    existingTask.fromUnit.name == task.fromUnit.name &&
                    existingTask.toUnit.name == task.toUnit.name &&
                    abs(existingTask.fromValue - task.fromValue) < 0.1
                }
                
                if !isDuplicate {
                    tasks.append(task)
                }
            }
        }
        
        return tasks.shuffled()
    }
    
    private func generateTask(for category: UnitCategory, difficulty: TaskDifficulty) -> ConversionTask? {
        let units = category.units
        guard units.count >= 2 else { return nil }
        
        let fromUnit = units.randomElement()!
        let toUnit = units.filter { $0.name != fromUnit.name }.randomElement()!
        
        let value = generateValue(for: category, difficulty: difficulty)
        
        guard let convertedValue = converter.convert(value: value, from: fromUnit, to: toUnit) else {
            return nil
        }
        
        let explanation = generateExplanation(
            value: value,
            fromUnit: fromUnit,
            toUnit: toUnit,
            result: convertedValue,
            category: category
        )
        
        return ConversionTask(
            question: "Convert \(formatValue(value)) \(fromUnit.symbol) to \(toUnit.symbol)",
            fromValue: value,
            fromUnit: fromUnit,
            toUnit: toUnit,
            correctAnswer: convertedValue,
            explanation: explanation,
            category: category
        )
    }
    
    private func generateValue(for category: UnitCategory, difficulty: TaskDifficulty) -> Double {
        switch category {
        case .length:
            switch difficulty {
            case .easy: return [1, 2, 5, 10, 100].randomElement()!
            case .medium: return [1.5, 2.5, 12, 25, 50].randomElement()!
            case .hard: return [0.5, 3.7, 15.2, 87.3].randomElement()!
            }
        case .mass:
            switch difficulty {
            case .easy: return [1, 2, 5, 8, 16].randomElement()!
            case .medium: return [1.5, 3.2, 12.5, 24].randomElement()!
            case .hard: return [0.75, 4.6, 18.7, 35.4].randomElement()!
            }
        case .temperature:
            switch difficulty {
            case .easy: return [0, 32, 100, 212].randomElement()!
            case .medium: return [25, 68, 98.6, 150].randomElement()!
            case .hard: return [-10, 37.5, 85.3, 273.15].randomElement()!
            }
        case .volume:
            switch difficulty {
            case .easy: return [1, 2, 3, 5, 10].randomElement()!
            case .medium: return [1.5, 2.5, 4.5, 8.5].randomElement()!
            case .hard: return [0.75, 3.25, 6.8, 12.3].randomElement()!
            }
        case .speed:
            switch difficulty {
            case .easy: return [30, 60, 100].randomElement()!
            case .medium: return [45, 75, 120].randomElement()!
            case .hard: return [35.5, 88.7, 145.2].randomElement()!
            }
        }
    }
    
    private func generateExplanation(
        value: Double,
        fromUnit: ConversionUnit,
        toUnit: ConversionUnit,
        result: Double,
        category: UnitCategory
    ) -> String {
        let formattedValue = formatValue(value)
        let formattedResult = converter.formatResult(result, for: toUnit)
        
        switch category {
        case .length:
            return getConversionFactor(from: fromUnit, to: toUnit, category: category)
        case .mass:
            return getConversionFactor(from: fromUnit, to: toUnit, category: category)
        case .temperature:
            return getTemperatureExplanation(value: value, fromUnit: fromUnit, toUnit: toUnit, result: result)
        case .volume:
            return getConversionFactor(from: fromUnit, to: toUnit, category: category)
        case .speed:
            return getConversionFactor(from: fromUnit, to: toUnit, category: category)
        }
    }
    
    private func getConversionFactor(from fromUnit: ConversionUnit, to toUnit: ConversionUnit, category: UnitCategory) -> String {
        // Simplified explanations for common conversions
        let fromName = fromUnit.name.lowercased()
        let toName = toUnit.name.lowercased()
        
        switch category {
        case .length:
            if fromName.contains("inch") && toName.contains("cent") {
                return "1 inch = 2.54 cm"
            } else if fromName.contains("feet") && toName.contains("meter") {
                return "1 foot = 0.3048 meters"
            } else if fromName.contains("mile") && toName.contains("kilo") {
                return "1 mile = 1.609 km"
            }
        case .mass:
            if fromName.contains("pound") && toName.contains("kilo") {
                return "1 pound = 0.454 kg"
            } else if fromName.contains("ounce") && toName.contains("gram") {
                return "1 ounce = 28.35 grams"
            }
        case .volume:
            if fromName.contains("cup") && toName.contains("milli") {
                return "1 US cup = 236.6 mL"
            } else if fromName.contains("gallon") && toName.contains("liter") {
                return "1 US gallon = 3.785 L"
            }
        case .speed:
            if fromName.contains("mph") && toName.contains("km") {
                return "1 mph = 1.609 km/h"
            }
        default:
            break
        }
        
        return "Use conversion factor between \(fromUnit.name) and \(toUnit.name)"
    }
    
    private func getTemperatureExplanation(value: Double, fromUnit: ConversionUnit, toUnit: ConversionUnit, result: Double) -> String {
        guard case .temperature(let from) = fromUnit.type,
              case .temperature(let to) = toUnit.type else {
            return "Temperature conversion"
        }
        
        let formattedValue = formatValue(value)
        let formattedResult = converter.formatResult(result, for: toUnit)
        
        switch (from, to) {
        case (.celsius, .fahrenheit):
            return "°F = °C × 9/5 + 32 = \(formattedValue) × 9/5 + 32 = \(formattedResult)°F"
        case (.fahrenheit, .celsius):
            return "°C = (°F - 32) × 5/9 = (\(formattedValue) - 32) × 5/9 = \(formattedResult)°C"
        case (.celsius, .kelvin):
            return "K = °C + 273.15 = \(formattedValue) + 273.15 = \(formattedResult)K"
        case (.kelvin, .celsius):
            return "°C = K - 273.15 = \(formattedValue) - 273.15 = \(formattedResult)°C"
        default:
            return "Temperature conversion: \(formattedValue)\(fromUnit.symbol) = \(formattedResult)\(toUnit.symbol)"
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    func checkAnswer(_ userAnswer: Double, for task: ConversionTask, tolerance: Double = 0.01) -> Bool {
        let difference = abs(userAnswer - task.correctAnswer)
        let relativeTolerance = max(tolerance, abs(task.correctAnswer) * 0.01) // 1% or absolute tolerance
        return difference <= relativeTolerance
    }
}

enum TaskDifficulty {
    case easy, medium, hard
}
