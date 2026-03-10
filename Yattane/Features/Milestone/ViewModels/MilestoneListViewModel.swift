import CoreData
import SwiftUI

@Observable
class MilestoneListViewModel {
  var milestones: [Milestone] = []
  private let repository: MilestoneRepositoryProtocol

  init(repository: MilestoneRepositoryProtocol = MilestoneRepository()) {
    self.repository = repository
    // Removed fetchMilestones() from init since it needs a child
  }

  func fetchMilestones(for child: Child) {
    do {
      milestones = try repository.fetchMilestones(for: child)
    } catch {
      print("Failed to fetch milestones: \(error)")
    }
  }

  func deleteMilestone(at offsets: IndexSet) {
    for index in offsets {
      let milestone = milestones[index]
      do {
        try repository.deleteMilestone(milestone)
        milestones.remove(at: index)
      } catch {
        print("Failed to delete milestone: \(error)")
      }
    }
  }
}
