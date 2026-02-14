//
//  YattaApp.swift
//  Yatta
//
//  Created by 茂木文章 on 2026/02/14.
//

import SwiftUI
import CoreData

@main
struct YattaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
