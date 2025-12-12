import SwiftUI

extension Color {
    static let cosmosBackground = Color(hex: "0B0B1A")
    static let cosmosPurple = Color(hex: "1E1B4B")
    static let softLavender = Color(hex: "A78BFA")
    static let softPink = Color(hex: "F0ABFC")
    static let softBlue = Color(hex: "7DD3FC")
    static let softPeach = Color(hex: "FED7AA")
    static let starWhite = Color(hex: "F5F5F7")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
