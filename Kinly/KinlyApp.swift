import SwiftUI
import SwiftData

@main
struct KinlyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoList.self,
            TodoItem.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ListsView()
        }
        .modelContainer(sharedModelContainer)
    }
}
