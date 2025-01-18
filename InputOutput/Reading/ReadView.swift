import SwiftData
import SwiftUI

let mkReadItemView = { ReadItemView(item: $0) }

func readSection(_ title: String, _ items: [ReadItem]) -> some View {
  itemSection(title, items, mkReadItemView)
}

struct ReadSearchResultsList: View {
  @Query private var searchResults: [ReadItem]

  init(search: String) {
    _searchResults = Query(
      filter: #Predicate<ReadItem> { item in
        item.title.localizedStandardContains(search)
          || (item.author?.localizedStandardContains(search) ?? false)
          || (item.recommender?.localizedStandardContains(search) ?? false)
      }, sort: [SortDescriptor(\ReadItem.completed), SortDescriptor(\ReadItem.created)])
  }

  var body: some View {
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      readSection("Search Results", searchResults)
    }
  }
}

struct ReadHistoryList: View {
  @Query(
    filter: #Predicate<ReadItem> { $0.completed != nil },
    sort: \ReadItem.completed, order: .reverse
  )
  var completed: [ReadItem]

  var body: some View {
    HistoryList(completed: completed, verbed: "Read", mkView: mkReadItemView)
  }
}

struct ReadCurrentView: View {
  @Query(
    filter: #Predicate<ReadItem> { $0.started != nil && $0.completed == nil },
    sort: \ReadItem.started
  )
  var started: [ReadItem]

  @Query(
    filter: #Predicate<ReadItem> { $0.started == nil && $0.completed == nil },
    sort: \ReadItem.created, order: .reverse
  )
  var unstarted: [ReadItem]

  static var recentDescriptor: FetchDescriptor<ReadItem> {
    var descriptor = FetchDescriptor<ReadItem>(
      predicate: #Predicate<ReadItem> { $0.completed != nil },
      sortBy: [SortDescriptor(\.completed, order: .reverse)])
    descriptor.fetchLimit = 5
    return descriptor
  }
  @Query(recentDescriptor)
  var recentlyCompleted: [ReadItem]

  var body: some View {
    if !started.isEmpty {
      readSection("Reading", started)
    }
    if unstarted.isEmpty {
      noItems("Nothing to read")
    } else {
      readSection("To Read", unstarted)
    }
    if !recentlyCompleted.isEmpty {
      readSection("Recently Readed", recentlyCompleted)
    }
  }
}

struct ReadView: View {
  @Environment(\.modelContext) var modelContext

  @State private var searchText: String = ""
  @State private var showHistory: Bool = false
  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  var body: some View {
    NavigationStack {
      List {
        if showSearch {
          ReadSearchResultsList(search: searchText)
        } else if showHistory {
          ReadHistoryList()
        } else {
          ReadCurrentView()
        }
      }
      .toolbar(content: {
        ToolbarItemGroup(placement: .automatic) {
          Toggle(isOn: $showHistory) {
            Image(systemName: "calendar")
          }
          ItemButton(
            mkItem: { ReadItem(created: .now, format: .book, title: "") },
            mkView: mkReadItemView
          )
        }
      })
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Reading")
      .searchable(text: $searchText)
    }
  }
}

#Preview {
  ReadView().modelContainer(setupPreviewModelContainer())
}
