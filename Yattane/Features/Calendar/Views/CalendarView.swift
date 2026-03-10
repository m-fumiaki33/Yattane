import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
  let milestones: [Milestone]
  @Binding var selectedDate: Date

  func makeUIView(context: Context) -> UICalendarView {
    let calendarView = UICalendarView()
    calendarView.calendar = Calendar(identifier: .gregorian)
    calendarView.locale = .current
    calendarView.fontDesign = .rounded
    calendarView.delegate = context.coordinator
    calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
    return calendarView
  }

  func updateUIView(_ uiView: UICalendarView, context: Context) {
    context.coordinator.milestones = milestones
    // Reload decorations when milestones change
    let dates = milestones.compactMap { $0.date }.map { Calendar.current.startOfDay(for: $0) }
    uiView.reloadDecorations(
      forDateComponents: dates.map {
        Calendar.current.dateComponents([.year, .month, .day], from: $0)
      }, animated: true)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    var parent: CalendarView
    var milestones: [Milestone] = []

    init(parent: CalendarView) {
      self.parent = parent
    }

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents)
      -> UICalendarView.Decoration?
    {
      guard let date = dateComponents.date else { return nil }
      let found = milestones.contains { Calendar.current.isDate($0.date!, inSameDayAs: date) }

      if found {
        return .default(color: .systemOrange, size: .small)
      }
      return nil
    }

    func dateSelection(
      _ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?
    ) {
      if let date = dateComponents?.date {
        parent.selectedDate = date
      }
    }
  }
}

struct CalendarTabWrapper: View {
  @State private var selectedDate = Date()
  @State private var milestones: [Milestone] = []
  private let repository = MilestoneRepository()
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Child.createdAt, ascending: true)],
    animation: .default)
  private var children: FetchedResults<Child>
  @AppStorage("selectedChildId") private var selectedChildId: String = ""

  private var activeChild: Child? {
    if let matched = children.first(where: { $0.id?.uuidString == selectedChildId }) {
      return matched
    }
    return children.first
  }

  var body: some View {
    NavigationStack {
      Group {
        if children.isEmpty {
          VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
              .font(.system(size: 64))
              .foregroundColor(.gray.opacity(0.8))
            Text("子どもを登録するとカレンダーが使えます")
              .font(.headline)
              .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.theme.background)
        } else {
          VStack(spacing: 0) {
            // Custom Header for Calendar
            VStack(alignment: .leading, spacing: 4) {
              Text("カレンダー")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 24)
            .background(
              Color.theme.primary
                .clipShape(CustomRoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
                .ignoresSafeArea()
            )

            // Calendar View Card
            VStack {
              CalendarView(milestones: milestones, selectedDate: $selectedDate)
                .padding()
            }
            .background(Color.theme.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Selected Date's Milestones
            List {
              ForEach(
                milestones.filter { Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
              ) { milestone in
                MilestoneRow(milestone: milestone)
                  .listRowSeparator(.hidden)
                  .listRowBackground(Color.clear)
                  .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
              }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
          }
          .background(Color.theme.background)
          .ignoresSafeArea(edges: .top)
        }
      }
      .onAppear {
        fetchMilestones()
      }
      .onChange(of: selectedDate) { oldValue, newValue in
        // Refresh if needed, but data is already loaded
      }
      .onChange(of: selectedChildId) { _, _ in
        fetchMilestones()
      }
    }
  }

  private func fetchMilestones() {
    if let child = activeChild {
      do {
        milestones = try repository.fetchMilestones(for: child)
      } catch {
        print("Error fetching: \(error)")
      }
    }
  }
}
