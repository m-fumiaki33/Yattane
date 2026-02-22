import SwiftUI

extension Color {
  static let softTheme = SoftTheme()

  struct SoftTheme {
    // Main Background (Cream/Off-white)
    let background = Color(red: 0.99, green: 0.99, blue: 0.96)

    // Card Background (Pure White)
    let cardBackground = Color.white

    // Text Colors
    let textPrimary = Color(red: 0.3, green: 0.3, blue: 0.3)
    let textSecondary = Color(red: 0.6, green: 0.6, blue: 0.6)

    // Accents (Pastels)
    let babyPink = Color(red: 1.0, green: 0.85, blue: 0.85)
    let babyBlue = Color(red: 0.85, green: 0.92, blue: 1.0)
    let babyGreen = Color(red: 0.88, green: 0.94, blue: 0.88)
    let babyYellow = Color(red: 1.0, green: 0.98, blue: 0.85)

    // Action Colors
    let primaryAction = Color(red: 1.0, green: 0.6, blue: 0.65)  // Darker pink for buttons
  }
}
