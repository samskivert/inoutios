import SwiftData
import SwiftUI

func listenSection(
  _ title: String,
  _ items: [ListenItem]
) -> some View {
  itemSection(title, items, { ListenItemView(item: $0) })
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

  var completedByYear: [(Int, [ListenItem])] {
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
        listenSection("Listened in \(year)", items)
      }
    }
  }
}

struct ListenCurrentView: View {
  @Query(
    filter: #Predicate<ListenItem> {
      $0.completed == nil && $0.started != nil
    },
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

struct NewListenItemButton: View {
  @Environment(\.modelContext) var modelContext
  @State private var newItem: ListenItem? = nil

  var body: some View {
    Button(action: {
      let item = ListenItem(created: .now, format: .podcast, title: "")
      modelContext.insert(item)
      newItem = item
    }) {
      Image(systemName: "plus")
    }
    .navigationDestination(item: $newItem) { item in
      ListenItemView(item: item).onDisappear { newItem = nil }
    }
  }
}

struct ListenView: View {
  @Environment(\.modelContext) var modelContext

  @State private var searchText: String = ""
  @State private var showImport: Bool = false
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
        // ToolbarItem(placement: .navigationBarTrailing)
        ToolbarItemGroup(placement: .automatic) {
          Toggle(isOn: $showHistory) {
            Image(systemName: "calendar")
          }
          NewListenItemButton()
          Button(action: { showImport = true }) {
            Image(systemName: "tray.and.arrow.down")
          }.accessibilityLabel("Import items from JSON")
        }
      })
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Listening")
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
            let items = try ListenImporter().importItems(Data(contentsOf: url))
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
  let container = try! ModelContainer(for: ListenItem.self, configurations: config)
  for item in testListenItems {
    container.mainContext.insert(item)
  }
  return ListenView().modelContainer(container)
}
