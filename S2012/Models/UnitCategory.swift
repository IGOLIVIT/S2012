import Foundation

enum UnitCategory: String, CaseIterable, Identifiable {
    case length = "Length"
    case mass = "Mass"
    case temperature = "Temperature"
    case volume = "Volume"
    case speed = "Speed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .length: return "ruler"
        case .mass: return "scalemass"
        case .temperature: return "thermometer"
        case .volume: return "drop"
        case .speed: return "speedometer"
        }
    }
    
    var units: [ConversionUnit] {
        switch self {
        case .length:
            return [
                ConversionUnit(name: "Meters", symbol: "m", type: .length(.meters)),
                ConversionUnit(name: "Kilometers", symbol: "km", type: .length(.kilometers)),
                ConversionUnit(name: "Centimeters", symbol: "cm", type: .length(.centimeters)),
                ConversionUnit(name: "Millimeters", symbol: "mm", type: .length(.millimeters)),
                ConversionUnit(name: "Inches", symbol: "in", type: .length(.inches)),
                ConversionUnit(name: "Feet", symbol: "ft", type: .length(.feet)),
                ConversionUnit(name: "Miles", symbol: "mi", type: .length(.miles))
            ]
        case .mass:
            return [
                ConversionUnit(name: "Grams", symbol: "g", type: .mass(.grams)),
                ConversionUnit(name: "Kilograms", symbol: "kg", type: .mass(.kilograms)),
                ConversionUnit(name: "Pounds", symbol: "lb", type: .mass(.pounds)),
                ConversionUnit(name: "Ounces", symbol: "oz", type: .mass(.ounces))
            ]
        case .temperature:
            return [
                ConversionUnit(name: "Celsius", symbol: "°C", type: .temperature(.celsius)),
                ConversionUnit(name: "Fahrenheit", symbol: "°F", type: .temperature(.fahrenheit)),
                ConversionUnit(name: "Kelvin", symbol: "K", type: .temperature(.kelvin))
            ]
        case .volume:
            return [
                ConversionUnit(name: "Liters", symbol: "L", type: .volume(.liters)),
                ConversionUnit(name: "Milliliters", symbol: "mL", type: .volume(.milliliters)),
                ConversionUnit(name: "Cups (US)", symbol: "cup", type: .volume(.cups)),
                ConversionUnit(name: "Tablespoons (US)", symbol: "tbsp", type: .volume(.tablespoons)),
                ConversionUnit(name: "Teaspoons (US)", symbol: "tsp", type: .volume(.teaspoons)),
                ConversionUnit(name: "Gallons (US)", symbol: "gal", type: .volume(.gallons))
            ]
        case .speed:
            return [
                ConversionUnit(name: "Meters per second", symbol: "m/s", type: .speed(.metersPerSecond)),
                ConversionUnit(name: "Kilometers per hour", symbol: "km/h", type: .speed(.kilometersPerHour)),
                ConversionUnit(name: "Miles per hour", symbol: "mph", type: .speed(.milesPerHour)),
                ConversionUnit(name: "Knots", symbol: "kn", type: .speed(.knots))
            ]
        }
    }
}

struct ConversionUnit: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let symbol: String
    let type: UnitType
    
    static func == (lhs: ConversionUnit, rhs: ConversionUnit) -> Bool {
        lhs.id == rhs.id
    }
}

enum UnitType {
    case length(LengthUnit)
    case mass(MassUnit)
    case temperature(TemperatureUnit)
    case volume(VolumeUnit)
    case speed(SpeedUnit)
}

enum LengthUnit {
    case meters, kilometers, centimeters, millimeters, inches, feet, miles
}

enum MassUnit {
    case grams, kilograms, pounds, ounces
}

enum TemperatureUnit {
    case celsius, fahrenheit, kelvin
}

enum VolumeUnit {
    case liters, milliliters, cups, tablespoons, teaspoons, gallons
}

enum SpeedUnit {
    case metersPerSecond, kilometersPerHour, milesPerHour, knots
}
