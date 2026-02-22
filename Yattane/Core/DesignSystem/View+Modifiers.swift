import SwiftUI

struct SoftCardStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding()
      .background(Color.softTheme.cardBackground)
      .cornerRadius(16)
      .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
  }
}

struct SoftButtonStyle: ButtonStyle {
  var backgroundColor: Color = Color.softTheme.primaryAction
  var foregroundColor: Color = .white

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.softBody)
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
      .foregroundColor(foregroundColor)
      .clipShape(Capsule())
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.spring(), value: configuration.isPressed)
  }
}

extension View {
  func softCard() -> some View {
    self.modifier(SoftCardStyle())
  }

  func softBackground() -> some View {
    self.background(Color.softTheme.background)
  }
}
