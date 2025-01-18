import SwiftData
import SwiftUI

func watchSection(
  _ title: String,
  _ items: [WatchItem]
) -> some View {
  itemSection(title, items, { WatchItemView(item: $0) })
}

struct WatchSearchResultsList: View {
  @Query private var searchResults: [WatchItem]

  init(search: String) {
    _searchResults = Query(
      filter: #Predicate<WatchItem> { item in
        item.title.localizedStandardContains(search)
          || (item.director?.localizedStandardContains(search) ?? false)
          || (item.recommender?.localizedStandardContains(search) ?? false)
      }, sort: [SortDescriptor(\WatchItem.completed), SortDescriptor(\WatchItem.created)])
  }

  var body: some View {
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      watchSection("Search Results", searchResults)
    }
  }
}

struct WatchHistoryList: View {
  @Query(
    filter: #Predicate<WatchItem> { $0.completed != nil },
    sort: \WatchItem.completed, order: .reverse
  )
  var completed: [WatchItem]

  var completedByYear: [(Int, [WatchItem])] {
    let calendar = Calendar.current
    let byyear = Dictionary(
      grouping: completed, by: { calendar.component(.year, from: $0.completed!) }
    )
    return Array(byyear.keys).sorted(by: { $0 > $1 }).map { year in
      (year, Array(byyear[year]!))
    }
  }

  var body: some View {
    if completed.isEmpty {
      noItems("No completed items")
    } else {
      ForEach(completedByYear, id: \.0) { year, items in
        watchSection("Watched in \(year)", items)
      }
    }
  }
}

struct WatchCurrentView: View {
  @Query(
    filter: #Predicate<WatchItem> {
      $0.completed == nil && $0.started != nil
    },
    sort: \WatchItem.started
  )
  var started: [WatchItem]

  @Query(
    filter: #Predicate<WatchItem> { $0.started == nil && $0.completed == nil },
    sort: \WatchItem.created, order: .reverse
  )
  var unstarted: [WatchItem]

  static var recentDescriptor: FetchDescriptor<WatchItem> {
    var descriptor = FetchDescriptor<WatchItem>(
      predicate: #Predicate<WatchItem> { $0.completed != nil },
      sortBy: [SortDescriptor(\.completed, order: .reverse)])
    descriptor.fetchLimit = 5
    return descriptor
  }
  @Query(recentDescriptor)
  var recentlyCompleted: [WatchItem]

  var body: some View {
    if !started.isEmpty {
      watchSection("Watching", started)
    }
    if unstarted.isEmpty {
      noItems("Nothing to watch")
    } else {
      watchSection("To Watch", unstarted)
    }
    if !recentlyCompleted.isEmpty {
      watchSection("Recently Watched", recentlyCompleted)
    }
  }
}

struct WatchView: View {
  @Environment(\.modelContext) var modelContext

  @State private var searchText: String = ""
  @State private var showImport: Bool = false
  @State private var showHistory: Bool = false
  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  var body: some View {
    NavigationStack {
      List {
        if showSearch {
          WatchSearchResultsList(search: searchText)
        } else if showHistory {
          WatchHistoryList()
        } else {
          WatchCurrentView()
        }
      }
      .toolbar(content: {
        ToolbarItemGroup(placement: .automatic) {
          Toggle(isOn: $showHistory) {
            Image(systemName: "calendar")
          }
          ItemButton(
            mkItem: { WatchItem(created: .now, format: .film, title: "") },
            mkView: { WatchItemView(item: $0) }
          )
          Button(action: { showImport = true }) {
            Image(systemName: "tray.and.arrow.down")
          }.accessibilityLabel("Import items from JSON")
        }
      })
      #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Watching")
      .searchable(text: $searchText)
      .fileImporter(isPresented: $showImport, allowedContentTypes: [.json]) { result in
        switch result {
        case .success(let url):
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          print("Importing from \(url)...")
          guard url.startAccessingSecurityScopedResource() else {
            return
          }
          do {
            let items = try WatchImporter().importItems(Data(contentsOf: url))
            for item in items {
              modelContext.insert(item)
            }
          } catch {
            print("Error decoding JSON: \(error)")
          }
        case .failure(let error):
          print("Error importing JSON: \(error)")
        }
      }
    }
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: WatchItem.self, configurations: config)
  for item in testWatchItems {
    container.mainContext.insert(item)
  }
  return WatchView().modelContainer(container)
}
