import SwiftUI

extension Color {
  static var theme: AppTheme {
    let rawValue =
      UserDefaults.standard.string(forKey: "selectedThemeColor") ?? AppThemeColor.orange.rawValue
    let selectedTheme = AppThemeColor(rawValue: rawValue) ?? .orange
    return selectedTheme.theme
  }

  struct AppTheme {
    // Main Background (Ivory from Figma)
    var background = Color(hex: "#FAF9F6")

    // Card Background (Pure White)
    var cardBackground = Color.white

    // Text Colors
    var textPrimary = Color(hex: "#333333")  // Main body text
    var textSecondary = Color(hex: "#666666")  // Sub text

    // Accents
    var primary = Color(hex: "#FF9F6B")  // Coral Orange (Header etc.)
    var secondary = Color(hex: "#A3E0D5")  // Mint Green (Weight background)

    // Specific Tag & Icon backgrounds
    var babyPink = Color(hex: "#FFD6C9")  // Peach color for age tags
    var babyBlue = Color(hex: "#C6E2FF")  // Soft blue for height background
    var babyYellow = Color(hex: "#FFF9E6")  // Pale yellow for comment background

    var shadow = Color.black.opacity(0.05)
  }
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
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
