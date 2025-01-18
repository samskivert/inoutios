import SwiftData
import SwiftUI

let mkListenItemView = { ListenItemView(item: $0) }

func listenSection(_ title: String, _ items: [ListenItem]) -> some View {
  itemSection(title, items, mkListenItemView)
}

struct ListenSearchResultsList: View {
  @Query var searchResults: [ListenItem]

  init(search: String) {
    _searchResults = Query(
      filter: #Predicate<ListenItem> { item in
        item.title.localizedStandardContains(search)
          || (item.artist?.localizedStandardContains(search) ?? false)
          || (item.recommender?.localizedStandardContains(search) ?? false)
      }, sort: [SortDescriptor(\ListenItem.completed), SortDescriptor(\ListenItem.created)])
  }

  var body: some View {
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      listenSection("Search Results", searchResults)
    }
  }
}

struct ListenHistoryList: View {
  @Query(
    filter: #Predicate<ListenItem> { $0.completed != nil },
    sort: \ListenItem.completed, order: .reverse
  )
  var completed: [ListenItem]

  var body: some View {
    HistoryList(completed: completed, verbed: "Listened", mkView: mkListenItemView)
  }
}

struct ListenCurrentView: View {
  @Query(
    filter: #Predicate<ListenItem> { $0.started != nil && $0.completed == nil },
    sort: \ListenItem.started
  )
  var started: [ListenItem]

  @Query(
    filter: #Predicate<ListenItem> { $0.started == nil && $0.completed == nil },
    sort: \ListenItem.created, order: .reverse
  )
  var unstarted: [ListenItem]

  static var recentDescriptor: FetchDescriptor<ListenItem> {
    var descriptor = FetchDescriptor<ListenItem>(
      predicate: #Predicate<ListenItem> { $0.completed != nil },
      sortBy: [SortDescriptor(\.completed, order: .reverse)])
    descriptor.fetchLimit = 5
    return descriptor
  }
  @Query(recentDescriptor)
  var recentlyCompleted: [ListenItem]

  var body: some View {
    if !started.isEmpty {
      listenSection("Listening", started)
    }
    if unstarted.isEmpty {
      noItems("Nothing to listen to")
    } else {
      listenSection("To Listen", unstarted)
    }
    if !recentlyCompleted.isEmpty {
      listenSection("Recently Listened", recentlyCompleted)
    }
  }
}

struct ListenView: View {
  @Environment(\.modelContext) var modelContext

  @State private var searchText: String = ""
  @State private var showHistory: Bool = false

  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  var body: some View {
    NavigationStack {
      List {
        if showSearch {
          ListenSearchResultsList(search: searchText)
        } else if showHistory {
          ListenHistoryList()
        } else {
          ListenCurrentView()
        }
      }
      .toolbar(content: {
        ToolbarItemGroup(placement: .automatic) {
          Toggle(isOn: $showHistory) {
            Image(systemName: "calendar")
          }
          ItemButton(
            mkItem: { ListenItem(created: .now, format: .podcast, title: "") },
            mkView: mkListenItemView
          )
        }
      })
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Listening")
      .searchable(text: $searchText)
    }
  }
}

#Preview {
  ListenView().modelContainer(setupPreviewModelContainer())
}
