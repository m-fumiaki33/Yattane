//
//  Persistence.swift
//  Yatta
//
//  Created by m-fumi on 2026/02/14.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  @MainActor
  static let preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    let child = Child(context: viewContext)
    child.id = UUID()
    child.name = "プレビュー用子どもデータ"
    child.birthday = Calendar.current.date(byAdding: .month, value: -6, to: Date())
    child.createdAt = Date()

    for i in 0..<10 {
      let newMilestone = Milestone(context: viewContext)
      newMilestone.id = UUID()
      newMilestone.title = "Milestone \(i)"
      newMilestone.date = Date()
      newMilestone.createdAt = Date()
      newMilestone.child = child
    }
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()

  let container: NSPersistentCloudKitContainer

  init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "Yattane")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}
