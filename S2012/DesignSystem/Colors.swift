import SwiftUI

struct AppColors {
    // Primary background
    static let primaryBackground = Color(hex: "0F1113")
    
    // Accent colors
    static let yolkYellow = Color(hex: "FFD54A")
    static let chickenRed = Color(hex: "E53935")
    
    // Neutrals
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "9AA4AE")
    
    // Gradients
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0F1113"), Color(hex: "161A1F")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Card backgrounds
    static let cardBackground = Color(hex: "1A1E22")
    static let cardBorder = Color(hex: "2A2E32")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
