import SwiftData
import SwiftUI

func playSection(
  _ title: String,
  _ items: [PlayItem],
  _ editItem: Binding<PlayItem?>
) -> some View {
  Section(header: Text(title)) {
    ForEach(items) { item in
      PlayItemRow(item: item, editAction: { editItem.wrappedValue = item })
    }
  }
}

struct PlaySearchResultsList: View {
  private var search: String
  @Query private var allItems: [PlayItem]
  private var editItem: Binding<PlayItem?>

  init(search: String, editItem: Binding<PlayItem?>) {
    self.search = search
    // We can't construct a filter predicate that checks whether platform
    // is in a list of matched platforms, so we just load all items and
    // do the filtering in memory; go team. I should probably just do this
    // for everything and avoid the excruciating pile  that is
    // SwiftData Predicate macros.
    _allItems = Query(sort: [SortDescriptor(\PlayItem.completed), SortDescriptor(\PlayItem.created)])
    self.editItem = editItem
  }

  var body: some View {
    let platforms = Platform.allCases.filter({ $0.label.localizedStandardContains(search)})
    let searchResults = allItems.filter({ $0.title.localizedStandardContains(search) ||  platforms.contains($0.platform) ||      ($0.recommender?.localizedStandardContains(search) ?? false)})
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      playSection("Search Results", searchResults, editItem)
    }
  }
}

struct PlayView: View {
  @Environment(\.modelContext) var modelContext

  @Query(
    filter: #Predicate<PlayItem> {
      $0.completed == nil && $0.started != nil
    },
    sort: \PlayItem.started
  )
  var started: [PlayItem]

  @Query(
    filter: #Predicate<PlayItem> { $0.started == nil && $0.completed == nil },
    sort: \PlayItem.created, order: .reverse
  )
  var unstarted: [PlayItem]

  @Query(
    filter: #Predicate<PlayItem> { $0.completed != nil },
    sort: \PlayItem.completed, order: .reverse
  )
  var completed: [PlayItem]

  @State private var searchText: String = ""
  @State private var isEditing: PlayItem? = nil
  @State private var showImport: Bool = false

  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  private var completedByYear: [(Int, [PlayItem])] {
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
          playSection("Playing", started, $isEditing)
        }
        if unstarted.isEmpty {
          ContentUnavailableView(
            "Nothing to play",
            systemImage: "doc.text",
            description: Text("You haven't added any items yet.")
          )
        } else if !showSearch {
          playSection("To Play", unstarted, $isEditing)
        }
        if !completed.isEmpty && !showSearch {
          ForEach(completedByYear, id: \.0) { year, items in
            playSection("Played in \(year)", items, $isEditing)
          }
        }
        if showSearch {
          PlaySearchResultsList(search: searchText, editItem: $isEditing)
        }
      }
      .sheet(isPresented: Binding(get: { isEditing != nil }, set: { _ in isEditing = nil })) {
        PlayItemView(item: isEditing!)
          #if !os(iOS)
            .padding()
          #endif
      }
      .toolbar(content: {
        // ToolbarItem(placement: .navigationBarTrailing)
        ToolbarItemGroup(placement: .automatic) {
          Button(action: {
            let item = PlayItem(created: .now, platform: .pc, title: "")
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
      .navigationTitle("Playing")
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
            let items = try PlayImporter().importItems(Data(contentsOf: url))
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
  let container = try! ModelContainer(for: PlayItem.self, configurations: config)
  for item in testPlayItems {
    container.mainContext.insert(item)
  }
  return PlayView().modelContainer(container)
}
