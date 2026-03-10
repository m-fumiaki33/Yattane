import CoreData
import SwiftUI

struct ChildListView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Child.createdAt, ascending: true)],
    animation: .default)
  private var children: FetchedResults<Child>

  @AppStorage("selectedChildId") private var selectedChildId: String = ""
  @State private var showingAddChild = false
  @State private var childToEdit: Child?

  var body: some View {
    NavigationStack {
      List {
        ForEach(children) { child in
          HStack {
            VStack(alignment: .leading) {
              Text(child.name ?? "子ども")
                .font(.headline)
              if let birthday = child.birthday {
                Text(birthday.formatted(date: .long, time: .omitted))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            }
            Spacer()
            if child.id?.uuidString == selectedChildId
              || (selectedChildId.isEmpty && child == children.first)
            {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            if let idString = child.id?.uuidString {
              selectedChildId = idString
              dismiss()
            }
          }
          .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
              childToEdit = child
            } label: {
              Label("編集", systemImage: "pencil")
            }
            .tint(.orange)
          }
        }
      }
      .navigationTitle("子どもの選択")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddChild = true
          } label: {
            Image(systemName: "plus")
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button("閉じる") { dismiss() }
        }
      }
      .sheet(isPresented: $showingAddChild) {
        ChildProfileView(child: nil)
      }
      .sheet(item: $childToEdit) { child in
        ChildProfileView(child: child)
      }
    }
  }
}
