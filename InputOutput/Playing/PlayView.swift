import SwiftData
import SwiftUI

let mkPlayItemView = { PlayItemView(item: $0) }

func playSection(_ title: String, _ items: [PlayItem]) -> some View {
  itemSection(title, items, mkPlayItemView)
}

struct PlaySearchResultsList: View {
  private var search: String
  @Query private var allItems: [PlayItem]

  init(search: String) {
    self.search = search
    // We can't construct a filter predicate that checks whether platform is in a list of matched
    // platforms, so we just load all items and do the filtering in memory; go team. I should
    // probably just do this for everything and avoid the excruciating pile of papercuts that is
    // SwiftData Predicate macros.
    _allItems = Query(sort: [SortDescriptor(\PlayItem.completed), SortDescriptor(\PlayItem.created)])
  }

  var body: some View {
    let platforms = Platform.allCases.filter({ $0.label.localizedStandardContains(search)})
    let searchResults = allItems.filter({ $0.title.localizedStandardContains(search)
      || platforms.contains($0.platform)
      || ($0.recommender?.localizedStandardContains(search) ?? false)})
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      playSection("Search Results", searchResults)
    }
  }
}

struct PlayHistoryList: View {
  @Query(
    filter: #Predicate<PlayItem> { $0.completed != nil },
    sort: \PlayItem.completed, order: .reverse
  )
  var completed: [PlayItem]

  var body: some View {
    HistoryList(completed: completed, verbed: "Played", mkView: mkPlayItemView)
  }
}

struct PlayCurrentView: View {
  @Query(
    filter: #Predicate<PlayItem> { $0.started != nil && $0.completed == nil },
    sort: \PlayItem.started
  )
  var started: [PlayItem]

  @Query(
    filter: #Predicate<PlayItem> { $0.started == nil && $0.completed == nil },
    sort: \PlayItem.created, order: .reverse
  )
  var unstarted: [PlayItem]

  static var recentDescriptor: FetchDescriptor<PlayItem> {
    var descriptor = FetchDescriptor<PlayItem>(
      predicate: #Predicate<PlayItem> { $0.completed != nil },
      sortBy: [SortDescriptor(\.completed, order: .reverse)])
    descriptor.fetchLimit = 5
    return descriptor
  }
  @Query(recentDescriptor)
  var recentlyCompleted: [PlayItem]

  var body: some View {
    if !started.isEmpty {
      playSection("Playing", started)
    }
    if unstarted.isEmpty {
      noItems("Nothing to play")
    } else {
      playSection("To Play", unstarted)
    }
    if !recentlyCompleted.isEmpty {
      playSection("Recently Played", recentlyCompleted)
    }
  }
}

struct PlayView: View {
  @Environment(\.modelContext) var modelContext

  @State private var searchText: String = ""
  @State private var showHistory: Bool = false
  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  var body: some View {
    NavigationStack {
      List {
        if showSearch {
          PlaySearchResultsList(search: searchText)
        } else if showHistory {
          PlayHistoryList()
        } else {
          PlayCurrentView()
        }
      }
      .toolbar(content: {
        ToolbarItemGroup(placement: .automatic) {
          Toggle(isOn: $showHistory) {
            Image(systemName: "calendar")
          }
          ItemButton(
            mkItem: { PlayItem(created: .now, platform: .pc, title: "") },
            mkView: mkPlayItemView
          )
        }
      })
      #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Playing")
      .searchable(text: $searchText)
    }
  }
}

#Preview {
  PlayView().modelContainer(setupPreviewModelContainer())
}
