import SwiftUI

struct MilestoneListView: View {
  @State private var viewModel = MilestoneListViewModel()
  @State private var showingAddMilestone = false
  @State private var showingDeleteAllAlert = false
  @State private var showingDeleteOneAlert = false
  @State private var showingChildProfile = false
  @State private var showingAddChild = false
  @State private var showingDeleteChildAlert = false
  @State private var showingDeleteCompletionAlert = false
  @State private var milestoneToDelete: IndexSet?

  var body: some View {
    NavigationStack {
      mainContent
        .listStyle(.plain)
        .navigationTitle(viewModel.selectedChild?.name ?? String(localized: "app_title"))
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Menu {
              ForEach(viewModel.children) { child in
                Button(child.name ?? "子ども") {
                  viewModel.selectedChild = child
                  viewModel.fetchMilestones()
                }
              }
              Divider()
              if let selected = viewModel.selectedChild {
                Button(
                  String(
                    format: NSLocalizedString("milestone_child_edit", comment: ""),
                    selected.name ?? ""), systemImage: "pencil"
                ) {
                  showingChildProfile = true
                }
                Button(
                  String(
                    format: NSLocalizedString("milestone_child_delete", comment: ""),
                    selected.name ?? "子ども"), systemImage: "trash"
                ) {
                  // Delay prompt slightly to ensure menu dismissal doesn't conflict
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingDeleteChildAlert = true
                  }
                }
                Divider()
              }
              Button("milestone_child_add", systemImage: "person.badge.plus") {
                showingAddChild = true
              }
            } label: {
              HStack {
                Text(viewModel.selectedChild?.name ?? String(localized: "menu"))
                  .fontWeight(.bold)
                Image(systemName: "chevron.down")
                  .font(.caption)
              }
              .foregroundColor(.primary)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddMilestone = true }) {
              HStack(spacing: 4) {
                Text("milestone_record_button")
                  .font(.callout)
                  .fontWeight(.medium)
                Image(systemName: "plus.circle.fill")
                  .font(.system(size: 24))
              }
              .foregroundColor(.blue)
            }
            .disabled(viewModel.selectedChild == nil)
          }

        }
        .sheet(isPresented: $showingAddMilestone) {
          if let child = viewModel.selectedChild {
            AddMilestoneView(child: child)
              .onDisappear {
                viewModel.fetchMilestones()
              }
          }
        }
        .sheet(isPresented: $showingChildProfile) {
          // Edit current
          ChildProfileView(child: viewModel.selectedChild)
            .onDisappear {
              viewModel.fetchChildren()  // Refresh name etc
            }
        }
        .sheet(isPresented: $showingAddChild) {  // Changed from showingChildList
          // Add new
          ChildProfileView(child: nil)
            .onDisappear {
              viewModel.fetchChildren()
            }
        }
        .onAppear {
          viewModel.fetchChildren()  // This also fetches milestones
        }
        .alert("全てのデータを削除しますか？", isPresented: $showingDeleteAllAlert) {
          Button("削除", role: .destructive) {
            viewModel.deleteAll()
          }
          Button("キャンセル", role: .cancel) {}
        } message: {
          Text("この操作は取り消せません。")
        }
        .alert("この記録を削除しますか？", isPresented: $showingDeleteOneAlert) {
          Button("削除", role: .destructive) {
            if let offsets = milestoneToDelete {
              viewModel.deleteMilestone(at: offsets)
            }
          }
          Button("キャンセル", role: .cancel) {
            milestoneToDelete = nil
          }
        }
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    List {
      if viewModel.selectedChild != nil {
        ForEach(viewModel.milestones) { milestone in
          MilestoneRow(milestone: milestone)
            .softCard()
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .onDelete { offsets in
          milestoneToDelete = offsets
          showingDeleteOneAlert = true
        }
      } else {
        ContentUnavailableView {
          Label("milestone_empty_title", systemImage: "person.crop.circle.badge.plus")
        } description: {
          Text("milestone_empty_description")
        }
      }
    }
    .scrollContentBackground(.hidden)
    .softBackground()
    .alert(
      String(
        format: NSLocalizedString("milestone_delete_child_title", comment: ""),
        viewModel.selectedChild?.name ?? "子ども"),
      isPresented: $showingDeleteChildAlert
    ) {
      Button("delete", role: .destructive) {
        viewModel.deleteSelectedChild()
        showingDeleteCompletionAlert = true
      }
      Button("cancel", role: .cancel) {}
    } message: {
      Text("milestone_delete_child_message")
    }
    .alert("milestone_delete_child_completed", isPresented: $showingDeleteCompletionAlert) {
      Button("OK", role: .cancel) {}
    }
  }
}
