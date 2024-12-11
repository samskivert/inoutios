import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }

            ReadView()
                .tabItem {
                    Label("Reading", systemImage: "book")
                }

            WatchView()
                .tabItem {
                    Label("Watching", systemImage: "tv")
                }

            ListenView()
                .tabItem {
                    Label("Listening", systemImage: "headphones")
                }

            PlayView()
                .tabItem {
                    Label("Playing", systemImage: "gamecontroller")
                }
        }
    }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: ReadItem.self, configurations: config)
  for item in testReadItems {
    container.mainContext.insert(item)
  }
  return ContentView().modelContainer(container)
}
