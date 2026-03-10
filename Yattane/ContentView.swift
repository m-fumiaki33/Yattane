import CoreData
import SwiftUI

struct ContentView: View {
  @AppStorage("selectedThemeColor") private var selectedThemeRaw: String = AppThemeColor.orange
    .rawValue

  var body: some View {
    TabView {
      MilestoneListView()
        .tabItem {
          Label("記録", systemImage: "list.bullet")
        }

      CalendarTabWrapper()
        .tabItem {
          Label("カレンダー", systemImage: "calendar")
        }

      SettingsView()
        .tabItem {
          Label("設定", systemImage: "gearshape")
        }
    }
    .accentColor(Color.theme.primary)
    .id(selectedThemeRaw)  // Force redraw when theme changes
  }
}

#Preview {
  ContentView()
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
