import SwiftData
import SwiftUI

func watchSection(
  _ title: String,
  _ items: [WatchItem],
  _ editItem: Binding<WatchItem?>
) -> some View {
  Section(header: Text(title)) {
    ForEach(items) { item in
      WatchItemRow(item: item, editAction: { editItem.wrappedValue = item })
    }
  }
}

struct WatchSearchResultsList: View {
  @Query private var searchResults: [WatchItem]
  private var editItem: Binding<WatchItem?>

  init(search: String, editItem: Binding<WatchItem?>) {
    _searchResults = Query(
      filter: #Predicate<WatchItem> { item in
        item.title.localizedStandardContains(search)
          || (item.director?.localizedStandardContains(search) ?? false)
          || (item.recommender?.localizedStandardContains(search) ?? false)
      }, sort: [SortDescriptor(\WatchItem.completed), SortDescriptor(\WatchItem.created)])
    self.editItem = editItem
  }

  var body: some View {
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      watchSection("Search Results", searchResults, editItem)
    }
  }
}

struct WatchView: View {
  @Environment(\.modelContext) var modelContext

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

  @Query(
    filter: #Predicate<WatchItem> { $0.completed != nil },
    sort: \WatchItem.completed, order: .reverse
  )
  var completed: [WatchItem]

  @State private var searchText: String = ""
  @State private var isEditing: WatchItem? = nil
  @State private var showImport: Bool = false

  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  private var completedByYear: [(Int, [WatchItem])] {
    let calendar = Calendar.current
    let byyear = Dictionary(
      grouping: completed, by: { calendar.component(.year, from: $0.completed!) }
    )
    return Array(byyear.keys).sorted(by: { $0 > $1 }).map { year in
      (year, Array(byyear[year]!))
    }
  }

  var body: some View {
    NavigationStack {
      List {
        if !started.isEmpty && !showSearch {
          watchSection("Watching", started, $isEditing)
        }
        if unstarted.isEmpty {
          ContentUnavailableView(
            "Nothing to watch",
            systemImage: "doc.text",
            description: Text("You haven't added any items yet.")
          )
        } else if !showSearch {
          watchSection("To Watch", unstarted, $isEditing)
        }
        if !completed.isEmpty && !showSearch {
          ForEach(completedByYear, id: \.0) { year, items in
            watchSection("Watched in \(year)", items, $isEditing)
          }
        }
        if showSearch {
          WatchSearchResultsList(search: searchText, editItem: $isEditing)
        }
      }
      .sheet(isPresented: Binding(get: { isEditing != nil }, set: { _ in isEditing = nil })) {
        WatchItemView(item: isEditing!)
          #if !os(iOS)
            .padding()
          #endif
      }
      .toolbar(content: {
        // ToolbarItem(placement: .navigationBarTrailing)
        ToolbarItemGroup(placement: .automatic) {
          Button(action: {
            let item = WatchItem(created: .now, format: .film, title: "")
            modelContext.insert(item)
            isEditing = item
          }) {
            Image(systemName: "plus")
          }.accessibilityLabel("Add a new item")
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
