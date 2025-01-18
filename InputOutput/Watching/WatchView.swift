import SwiftData
import SwiftUI

let mkWatchItemView = { WatchItemView(item: $0) }

func watchSection(_ title: String, _ items: [WatchItem]) -> some View {
  itemSection(title, items, mkWatchItemView)
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

  var body: some View {
    HistoryList(completed: completed, verbed: "Watched", mkView: mkWatchItemView)
  }
}

struct WatchCurrentView: View {
  @Query(
    filter: #Predicate<WatchItem> { $0.started != nil && $0.completed == nil },
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
            mkView: mkWatchItemView
          )
        }
      })
      #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Watching")
      .searchable(text: $searchText)
    }
  }
}

#Preview {
  WatchView().modelContainer(setupPreviewModelContainer())
}
