import SwiftUI

enum AppThemeColor: String, CaseIterable, Identifiable {
  case orange = "オレンジ"
  case green = "グリーン"
  case pink = "ピンク"
  case purple = "パープル"
  case blue = "ブルー"
  case yellow = "イエロー"
  case white = "ホワイト"

  var id: String { rawValue }

  var color: Color {
    switch self {
    case .orange: return Color(hex: "#FF9F6B")
    case .green: return Color(hex: "#7DCEA0")
    case .pink: return Color(hex: "#F1948A")
    case .purple: return Color(hex: "#BB8FCE")
    case .blue: return Color(hex: "#85C1E9")
    case .yellow: return Color(hex: "#F7DC6F")
    case .white: return Color(hex: "#C0C0C0")  // Slightly off-white (silver) for contrast against white backgrounds
    }
  }

  var theme: Color.AppTheme {
    var newTheme = Color.AppTheme()
    newTheme.primary = self.color
    if self == .white {
      newTheme.textPrimary = .black
    }
    return newTheme
  }
}
