import SwiftUI

extension Font {
  static func rounded(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    return Font.system(size: size, weight: weight, design: .rounded)
  }

  static let softTitle = Font.system(size: 28, weight: .bold, design: .rounded)
  static let softHeadline = Font.system(size: 20, weight: .semibold, design: .rounded)
  static let softBody = Font.system(size: 16, weight: .regular, design: .rounded)
  static let softCaption = Font.system(size: 14, weight: .medium, design: .rounded)
}
