import SwiftData
import SwiftUI

func listenSection(
  _ title: String,
  _ items: [ListenItem],
  _ editItem: Binding<ListenItem?>
) -> some View {
  Section(header: Text(title)) {
    ForEach(items) { item in
      ListenItemRow(item: item, editAction: { editItem.wrappedValue = item })
    }
  }
}

struct ListenSearchResultsList: View {
  @Query private var searchResults: [ListenItem]
  private var editItem: Binding<ListenItem?>

  init(search: String, editItem: Binding<ListenItem?>) {
    _searchResults = Query(
      filter: #Predicate<ListenItem> { item in
        item.title.localizedStandardContains(search)
          || (item.artist?.localizedStandardContains(search) ?? false)
          || (item.recommender?.localizedStandardContains(search) ?? false)
      }, sort: [SortDescriptor(\ListenItem.completed), SortDescriptor(\ListenItem.created)])
    self.editItem = editItem
  }

  var body: some View {
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      listenSection("Search Results", searchResults, editItem)
    }
  }
}

struct ListenView: View {
  @Environment(\.modelContext) var modelContext

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

  @Query(
    filter: #Predicate<ListenItem> { $0.completed != nil },
    sort: \ListenItem.completed, order: .reverse
  )
  var completed: [ListenItem]

  @State private var searchText: String = ""
  @State private var isEditing: ListenItem? = nil
  @State private var showImport: Bool = false

  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  private var completedByYear: [(Int, [ListenItem])] {
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
          listenSection("Listening", started, $isEditing)
        }
        if unstarted.isEmpty {
          ContentUnavailableView(
            "Nothing to listen",
            systemImage: "doc.text",
            description: Text("You haven't added any items yet.")
          )
        } else if !showSearch {
          listenSection("To Listen", unstarted, $isEditing)
        }
        if !completed.isEmpty && !showSearch {
          ForEach(completedByYear, id: \.0) { year, items in
            listenSection("Listened in \(year)", items, $isEditing)
          }
        }
        if showSearch {
          ListenSearchResultsList(search: searchText, editItem: $isEditing)
        }
      }
      .sheet(isPresented: Binding(get: { isEditing != nil }, set: { _ in isEditing = nil })) {
        ListenItemView(item: isEditing!)
          #if !os(iOS)
            .padding()
          #endif
      }
      .toolbar(content: {
        // ToolbarItem(placement: .navigationBarTrailing)
        ToolbarItemGroup(placement: .automatic) {
          Button(action: {
            let item = ListenItem(created: .now, format: .podcast, title: "")
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
