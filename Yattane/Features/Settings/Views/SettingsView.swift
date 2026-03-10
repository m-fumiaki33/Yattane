import SwiftUI

struct SettingsView: View {
  @AppStorage("selectedThemeColor") private var selectedThemeRaw: String = AppThemeColor.orange
    .rawValue

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("テーマカラー")) {
          ForEach(AppThemeColor.allCases) { themeColor in
            Button(action: {
              selectedThemeRaw = themeColor.rawValue
            }) {
              HStack {
                Circle()
                  .fill(themeColor.color)
                  .frame(width: 24, height: 24)
                  .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                Text(themeColor.rawValue)
                  .foregroundColor(.primary)

                Spacer()

                if selectedThemeRaw == themeColor.rawValue {
                  Image(systemName: "checkmark")
                    .foregroundColor(Color.theme.primary)
                }
              }
            }
          }
        }

        Section(header: Text("アプリ情報")) {
          HStack {
            Text("バージョン")
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
              .foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("設定")
    }
  }
}

#Preview {
  SettingsView()
}
