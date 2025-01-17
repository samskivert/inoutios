import SwiftData
import SwiftUI

func readSection(
  _ title: String,
  _ items: [ReadItem]
) -> some View {
  itemSection(title, items, { ReadItemView(item: $0) })
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

  var completedByYear: [(Int, [ReadItem])] {
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
        readSection("Readed in \(year)", items)
      }
    }
  }
}

struct ReadCurrentView: View {
  @Query(
    filter: #Predicate<ReadItem> {
      $0.completed == nil && $0.started != nil
    },
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

struct NewReadItemButton: View {
  @Environment(\.modelContext) var modelContext
  @State private var newItem: ReadItem? = nil

  var body: some View {
    Button(action: {
      let item = ReadItem(created: .now, format: .book, title: "")
      modelContext.insert(item)
      newItem = item
    }) {
      Image(systemName: "plus")
    }
    .navigationDestination(item: $newItem) { item in
      ReadItemView(item: item).onDisappear { newItem = nil }
    }
  }
}

struct ReadView: View {
  @Environment(\.modelContext) var modelContext

  @State private var searchText: String = ""
  @State private var showImport: Bool = false
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
          NewReadItemButton()
          Button(action: { showImport = true }) {
            Image(systemName: "tray.and.arrow.down")
          }.accessibilityLabel("Import items from JSON")
        }
      })
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Reading")
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
            let items = try ReadImporter().importItems(Data(contentsOf: url))
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
  let container = try! ModelContainer(for: ReadItem.self, configurations: config)
  for item in testReadItems {
    container.mainContext.insert(item)
  }
  return ReadView().modelContainer(container)
}
