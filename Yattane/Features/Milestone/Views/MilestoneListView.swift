import CoreData
import SwiftUI

struct MilestoneListView: View {
  @State private var viewModel = MilestoneListViewModel()
  @State private var showingAddMilestone = false
  @State private var showingProfile = false
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

  // Display name with honorific based on gender
  private var displayName: String {
    guard let child = activeChild else { return "子ども" }
    let name = child.name ?? "子ども"
    switch child.gender {
    case 1: return "\(name)くん"   // 男の子
    case 2: return "\(name)ちゃん" // 女の子
    default: return name           // 未選択・その他
    }
  }

  // Calculate age string like "生後6ヶ月"
  private var ageString: String {
    guard let child = activeChild, let birthday = child.birthday else { return "生年月日未設定" }
    let now = Date()
    let components = Calendar.current.dateComponents([.month, .day], from: birthday, to: now)

    if let month = components.month, month > 0 {
      return "生後\(month)ヶ月"
    } else if let day = components.day {
      return "生後\(day)日"
    } else {
      return "今日誕生！"
    }
  }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .top) {
        Color.theme.background.ignoresSafeArea()

        if children.isEmpty {
          VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
              .font(.system(size: 64))
              .foregroundColor(.theme.primary)
            Text("子どものプロフィールを登録しましょう")
              .font(.title3)
              .fontWeight(.semibold)
              .foregroundColor(.theme.textPrimary)
            Button(action: { showingProfile = true }) {
              Text("登録をはじめる")
                .bold()
                .frame(maxWidth: 240)
            }
            .buttonStyle(.borderedProminent)
            .tint(.theme.primary)
            .controlSize(.large)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          VStack(spacing: 0) {
            // Figma-like Custom Header
            customHeader

            // Timeline Content
            HStack {
              Text("タイムライン")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.theme.textPrimary)
              Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 8)

            if viewModel.milestones.isEmpty {
              VStack(spacing: 20) {
                Spacer()
                Image(systemName: "pencil.and.list.clipboard")
                  .font(.system(size: 64))
                  .foregroundColor(.theme.secondary)
                Text("成長の記録をはじめましょう")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundColor(.theme.textPrimary)
                Text("右上の「＋」ボタンか、下のボタンから\n最初の記録を追加できます。")
                  .font(.subheadline)
                  .foregroundColor(.theme.textSecondary)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal, 32)

                Button(action: { showingAddMilestone = true }) {
                  HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("記録を追加する")
                      .bold()
                  }
                  .frame(maxWidth: 240)
                  .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.theme.primary)
                .controlSize(.large)
                .padding(.top, 16)
                Spacer()
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
              List {
                ForEach(viewModel.milestones) { milestone in
                  MilestoneRow(milestone: milestone)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                .onDelete(perform: deleteMilestones)
              }
              .listStyle(.plain)
              .scrollContentBackground(.hidden)
            }
          }
        }
      }
      .toolbar {
        if !children.isEmpty {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddMilestone = true }) {
              Image(systemName: "plus.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.white)
            }
          }
        }
      }
      .sheet(isPresented: $showingAddMilestone) {
        if let child = activeChild {
          AddMilestoneView(child: child)
            .onDisappear {
              viewModel.fetchMilestones(for: child)
            }
        }
      }
      .sheet(isPresented: $showingProfile) {
        ChildListView()
      }
      .onAppear {
        if let child = activeChild {
          viewModel.fetchMilestones(for: child)
        }
      }
      .onChange(of: selectedChildId) { _, _ in
        if let child = activeChild {
          viewModel.fetchMilestones(for: child)
        }
      }
    }
  }

  // MARK: - Custom Header
  private var customHeader: some View {
    VStack(spacing: 16) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text("\(displayName)の成長記録")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)

          Text(ageString)
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.9))
        }

        Spacer()

        // Avatar / Profile Switcher
        Button(action: { showingProfile = true }) {
          ZStack {
            Circle()
              .fill(Color.white.opacity(0.2))
              .frame(width: 50, height: 50)

            Image(systemName: "person.crop.circle")
              .resizable()
              .scaledToFit()
              .frame(width: 50, height: 50)
              .foregroundColor(.white)
          }
        }
      }
      .padding(.horizontal, 20)

      // Stats / Summary Row
      HStack(spacing: 12) {
        headerStatBox(
          title: "お誕生日",
          value: activeChild?.birthday?.formatted(date: .abbreviated, time: .omitted) ?? "-")
        headerStatBox(title: "記録数", value: "\(viewModel.milestones.count) 件")
      }
      .padding(.horizontal, 20)
    }
    .padding(.top, 60)  // Extra padding for safe area
    .padding(.bottom, 24)
    .background(
      Color.theme.primary
        .clipShape(CustomRoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
        .ignoresSafeArea()
    )
  }

  private func headerStatBox(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundColor(.white.opacity(0.8))
      Text(value)
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.white)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(Color.white.opacity(0.15))
    .cornerRadius(12)
  }

  private func deleteMilestones(at offsets: IndexSet) {
    viewModel.deleteMilestone(at: offsets)
  }
}

// Define CustomRoundedCorner to round only bottom corners
struct CustomRoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect, byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
