import Foundation

class ConverterService {
    static let shared = ConverterService()
    
    private init() {}
    
    func convert(value: Double, from fromUnit: ConversionUnit, to toUnit: ConversionUnit) -> Double? {
        // Handle same unit conversion
        if fromUnit.type.isSameType(as: toUnit.type) && fromUnit.name == toUnit.name {
            return value
        }
        
        switch (fromUnit.type, toUnit.type) {
        case (.length(let from), .length(let to)):
            return convertLength(value: value, from: from, to: to)
        case (.mass(let from), .mass(let to)):
            return convertMass(value: value, from: from, to: to)
        case (.temperature(let from), .temperature(let to)):
            return convertTemperature(value: value, from: from, to: to)
        case (.volume(let from), .volume(let to)):
            return convertVolume(value: value, from: from, to: to)
        case (.speed(let from), .speed(let to)):
            return convertSpeed(value: value, from: from, to: to)
        default:
            return nil // Different unit types
        }
    }
    
    func formatResult(_ value: Double, for unit: ConversionUnit) -> String {
        let formatted: String
        
        switch unit.type {
        case .temperature:
            formatted = String(format: "%.2f", value)
        default:
            if abs(value) >= 1000 {
                formatted = String(format: "%.1f", value)
            } else if abs(value) >= 10 {
                formatted = String(format: "%.2f", value)
            } else {
                formatted = String(format: "%.3f", value)
            }
        }
        
        // Remove trailing zeros
        let trimmed = formatted.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        let final = trimmed.hasSuffix(".") ? String(trimmed.dropLast()) : trimmed
        
        return final
    }
    
    func isValidInput(_ value: Double, for unit: ConversionUnit) -> Bool {
        switch unit.type {
        case .temperature(.kelvin):
            return value >= -273.15 // Absolute zero in Celsius equivalent
        default:
            return value >= 0 // Most units don't accept negative values
        }
    }
    
    // MARK: - Length Conversions
    private func convertLength(value: Double, from: LengthUnit, to: LengthUnit) -> Double {
        let meters = convertToMeters(value: value, from: from)
        return convertFromMeters(value: meters, to: to)
    }
    
    private func convertToMeters(value: Double, from: LengthUnit) -> Double {
        switch from {
        case .meters: return value
        case .kilometers: return value * 1000
        case .centimeters: return value / 100
        case .millimeters: return value / 1000
        case .inches: return value * 0.0254
        case .feet: return value * 0.3048
        case .miles: return value * 1609.344
        }
    }
    
    private func convertFromMeters(value: Double, to: LengthUnit) -> Double {
        switch to {
        case .meters: return value
        case .kilometers: return value / 1000
        case .centimeters: return value * 100
        case .millimeters: return value * 1000
        case .inches: return value / 0.0254
        case .feet: return value / 0.3048
        case .miles: return value / 1609.344
        }
    }
    
    // MARK: - Mass Conversions
    private func convertMass(value: Double, from: MassUnit, to: MassUnit) -> Double {
        let grams = convertToGrams(value: value, from: from)
        return convertFromGrams(value: grams, to: to)
    }
    
    private func convertToGrams(value: Double, from: MassUnit) -> Double {
        switch from {
        case .grams: return value
        case .kilograms: return value * 1000
        case .pounds: return value * 453.592
        case .ounces: return value * 28.3495
        }
    }
    
    private func convertFromGrams(value: Double, to: MassUnit) -> Double {
        switch to {
        case .grams: return value
        case .kilograms: return value / 1000
        case .pounds: return value / 453.592
        case .ounces: return value / 28.3495
        }
    }
    
    // MARK: - Temperature Conversions
    private func convertTemperature(value: Double, from: TemperatureUnit, to: TemperatureUnit) -> Double {
        switch (from, to) {
        case (.celsius, .fahrenheit):
            return value * 9/5 + 32
        case (.fahrenheit, .celsius):
            return (value - 32) * 5/9
        case (.celsius, .kelvin):
            return value + 273.15
        case (.kelvin, .celsius):
            return value - 273.15
        case (.fahrenheit, .kelvin):
            let celsius = (value - 32) * 5/9
            return celsius + 273.15
        case (.kelvin, .fahrenheit):
            let celsius = value - 273.15
            return celsius * 9/5 + 32
        default:
            return value // Same unit
        }
    }
    
    // MARK: - Volume Conversions
    private func convertVolume(value: Double, from: VolumeUnit, to: VolumeUnit) -> Double {
        let milliliters = convertToMilliliters(value: value, from: from)
        return convertFromMilliliters(value: milliliters, to: to)
    }
    
    private func convertToMilliliters(value: Double, from: VolumeUnit) -> Double {
        switch from {
        case .milliliters: return value
        case .liters: return value * 1000
        case .cups: return value * 236.588
        case .tablespoons: return value * 14.7868
        case .teaspoons: return value * 4.92892
        case .gallons: return value * 3785.41
        }
    }
    
    private func convertFromMilliliters(value: Double, to: VolumeUnit) -> Double {
        switch to {
        case .milliliters: return value
        case .liters: return value / 1000
        case .cups: return value / 236.588
        case .tablespoons: return value / 14.7868
        case .teaspoons: return value / 4.92892
        case .gallons: return value / 3785.41
        }
    }
    
    // MARK: - Speed Conversions
    private func convertSpeed(value: Double, from: SpeedUnit, to: SpeedUnit) -> Double {
        let metersPerSecond = convertToMetersPerSecond(value: value, from: from)
        return convertFromMetersPerSecond(value: metersPerSecond, to: to)
    }
    
    private func convertToMetersPerSecond(value: Double, from: SpeedUnit) -> Double {
        switch from {
        case .metersPerSecond: return value
        case .kilometersPerHour: return value / 3.6
        case .milesPerHour: return value * 0.44704
        case .knots: return value * 0.514444
        }
    }
    
    private func convertFromMetersPerSecond(value: Double, to: SpeedUnit) -> Double {
        switch to {
        case .metersPerSecond: return value
        case .kilometersPerHour: return value * 3.6
        case .milesPerHour: return value / 0.44704
        case .knots: return value / 0.514444
        }
    }
}

extension UnitType {
    func isSameType(as other: UnitType) -> Bool {
        switch (self, other) {
        case (.length, .length), (.mass, .mass), (.temperature, .temperature), (.volume, .volume), (.speed, .speed):
            return true
        default:
            return false
        }
    }
}
