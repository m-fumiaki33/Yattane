import SwiftUI

struct ChildProfileView: View {
  @State var viewModel: ChildProfileViewModel
  @Environment(\.dismiss) var dismiss
  @State private var showingDeleteAlert = false

  init(child: Child? = nil) {
    _viewModel = State(initialValue: ChildProfileViewModel(child: child))
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("child_name_label", text: $viewModel.name)
          DatePicker(
            "child_birthday_label", selection: $viewModel.birthday, displayedComponents: .date)
          Picker("child_gender_label", selection: $viewModel.gender) {
            Text("gender_unselected").tag(Int16(0))
            Text("gender_boy").tag(Int16(1))
            Text("gender_girl").tag(Int16(2))
            Text("gender_other").tag(Int16(3))
          }
        } header: {
          Text("child_profile_header")
        }
      }
      .navigationTitle(viewModel.isNew ? "child_register_title" : "child_edit_title")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("save") {
            if viewModel.save() {
              dismiss()
            }
          }
          .disabled(viewModel.name.isEmpty)
        }
      }
    }
  }
}
