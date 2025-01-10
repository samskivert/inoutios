import SwiftUI
import SwiftData

@main
struct InputOutputApp: App {
  var sharedModelContainer: ModelContainer = {
    do {
      return try setupModelContainer()
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}
