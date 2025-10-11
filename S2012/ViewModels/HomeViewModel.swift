import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedCategory: UnitCategory = .length
    @Published var selectedFromUnit: ConversionUnit
    @Published var selectedToUnit: ConversionUnit
    @Published var inputValue: String = ""
    @Published var result: String = ""
    @Published var showResult: Bool = false
    @Published var isConverting: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let converter = ConverterService.shared
    
    init() {
        let lengthUnits = UnitCategory.length.units
        selectedFromUnit = lengthUnits[0] // Meters
        selectedToUnit = lengthUnits[1] // Kilometers
    }
    
    var canConvert: Bool {
        !inputValue.isEmpty && Double(inputValue) != nil
    }
    
    var presetConversions: [PresetConversion] {
        switch selectedCategory {
        case .length:
            return [
                PresetConversion(value: "1", fromUnit: "km", toUnit: "m", description: "1 km to m"),
                PresetConversion(value: "5", fromUnit: "mi", toUnit: "km", description: "5 mi to km"),
                PresetConversion(value: "12", fromUnit: "in", toUnit: "cm", description: "12 in to cm")
            ]
        case .mass:
            return [
                PresetConversion(value: "1", fromUnit: "kg", toUnit: "lb", description: "1 kg to lb"),
                PresetConversion(value: "8", fromUnit: "oz", toUnit: "g", description: "8 oz to g"),
                PresetConversion(value: "2.5", fromUnit: "lb", toUnit: "kg", description: "2.5 lb to kg")
            ]
        case .temperature:
            return [
                PresetConversion(value: "32", fromUnit: "°F", toUnit: "°C", description: "32 °F to °C"),
                PresetConversion(value: "100", fromUnit: "°C", toUnit: "°F", description: "100 °C to °F"),
                PresetConversion(value: "0", fromUnit: "°C", toUnit: "K", description: "0 °C to K")
            ]
        case .volume:
            return [
                PresetConversion(value: "3", fromUnit: "L", toUnit: "mL", description: "3 L to mL"),
                PresetConversion(value: "2", fromUnit: "cup", toUnit: "mL", description: "2 cup to mL"),
                PresetConversion(value: "1", fromUnit: "gal", toUnit: "L", description: "1 gal to L")
            ]
        case .speed:
            return [
                PresetConversion(value: "60", fromUnit: "mph", toUnit: "km/h", description: "60 mph to km/h"),
                PresetConversion(value: "100", fromUnit: "km/h", toUnit: "mph", description: "100 km/h to mph"),
                PresetConversion(value: "10", fromUnit: "m/s", toUnit: "km/h", description: "10 m/s to km/h")
            ]
        }
    }
    
    func updateCategory(_ category: UnitCategory) {
        selectedCategory = category
        let units = category.units
        selectedFromUnit = units[0]
        selectedToUnit = units.count > 1 ? units[1] : units[0]
        clearResult()
    }
    
    func updateFromUnit(_ unit: ConversionUnit) {
        selectedFromUnit = unit
        if selectedFromUnit.name == selectedToUnit.name {
            // Auto-select a different "to" unit
            let units = selectedCategory.units
            selectedToUnit = units.first { $0.name != unit.name } ?? units[0]
        }
        convertIfPossible()
    }
    
    func updateToUnit(_ unit: ConversionUnit) {
        selectedToUnit = unit
        convertIfPossible()
    }
    
    func swapUnits() {
        let temp = selectedFromUnit
        selectedFromUnit = selectedToUnit
        selectedToUnit = temp
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        convertIfPossible()
    }
    
    func convert() {
        guard let value = Double(inputValue) else {
            showErrorMessage("Please enter a valid number")
            return
        }
        
        // Validate input for specific units
        if !converter.isValidInput(value, for: selectedFromUnit) {
            if case .temperature(.kelvin) = selectedFromUnit.type, value < -273.15 {
                showErrorMessage("Temperature cannot be below absolute zero")
                return
            } else if value < 0 {
                showErrorMessage("Value cannot be negative")
                return
            }
        }
        
        isConverting = true
        
        // Add slight delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let convertedValue = self.converter.convert(
                value: value,
                from: self.selectedFromUnit,
                to: self.selectedToUnit
            ) {
                let formattedResult = self.converter.formatResult(convertedValue, for: self.selectedToUnit)
                
                withAnimation(.easeOut(duration: 0.6)) {
                    self.result = "\(formattedResult) \(self.selectedToUnit.symbol)"
                    self.showResult = true
                    self.isConverting = false
                }
                
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            } else {
                self.showErrorMessage("Conversion failed")
                self.isConverting = false
            }
        }
    }
    
    func applyPreset(_ preset: PresetConversion) {
        inputValue = preset.value
        
        // Find matching units
        let units = selectedCategory.units
        if let fromUnit = units.first(where: { $0.symbol == preset.fromUnit || $0.name.lowercased().contains(preset.fromUnit.lowercased()) }),
           let toUnit = units.first(where: { $0.symbol == preset.toUnit || $0.name.lowercased().contains(preset.toUnit.lowercased()) }) {
            selectedFromUnit = fromUnit
            selectedToUnit = toUnit
        }
        
        convert()
    }
    
    private func convertIfPossible() {
        if canConvert {
            convert()
        } else {
            clearResult()
        }
    }
    
    private func clearResult() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = false
            result = ""
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        
        // Auto-hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showError = false
        }
    }
}

struct PresetConversion {
    let value: String
    let fromUnit: String
    let toUnit: String
    let description: String
}
