import SwiftData
import SwiftUI

func readSection(
  _ title: String,
  _ items: [ReadItem],
  _ editItem: Binding<ReadItem?>
) -> some View {
  Section(header: Text(title)) {
    ForEach(items) { item in
      ReadItemRow(item: item, editAction: { editItem.wrappedValue = item })
    }
  }
}

struct SearchResultsList: View {
  @Query private var searchResults: [ReadItem]
  private var editItem: Binding<ReadItem?>

  init(search: String, editItem: Binding<ReadItem?>) {
    _searchResults = Query(
      filter: #Predicate<ReadItem> { item in
        item.title.localizedStandardContains(search)
          || (item.author?.localizedStandardContains(search) ?? false)
          || (item.recommender?.localizedStandardContains(search) ?? false)
      }, sort: [SortDescriptor(\ReadItem.completed), SortDescriptor(\ReadItem.created)])
    self.editItem = editItem
  }

  var body: some View {
    if searchResults.isEmpty {
      Text("No matches.")
    } else {
      readSection("Search Results", searchResults, editItem)
    }
  }
}

struct ReadView: View {
  @Environment(\.modelContext) var modelContext

  @Query(
    filter: #Predicate<ReadItem> {
      $0.completed == nil && $0.started != nil
    },
    sort: \ReadItem.started
  )
  var reading: [ReadItem]

  @Query(
    filter: #Predicate<ReadItem> { $0.started == nil },
    sort: \ReadItem.created, order: .reverse
  )
  var toread: [ReadItem]

  @Query(
    filter: #Predicate<ReadItem> { $0.completed != nil },
    sort: \ReadItem.completed, order: .reverse
  )
  var recentlyRead: [ReadItem]

  @State private var searchText: String = ""
  @State private var isEditing: ReadItem? = nil
  @State private var showImport: Bool = false

  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  private var completedByYear: [(Int, [ReadItem])] {
    let calendar = Calendar.current
    let byyear = Dictionary(
      grouping: recentlyRead, by: { calendar.component(.year, from: $0.completed!) }
    )
    return Array(byyear.keys).sorted(by: { $0 > $1 }).map { year in
      (year, Array(byyear[year]!))
    }
  }

  var body: some View {
    NavigationStack {
      List {
        if !reading.isEmpty && !showSearch {
          readSection("Reading", reading, $isEditing)
        }
        if toread.isEmpty {
          ContentUnavailableView(
            "Nothing to read",
            systemImage: "doc.text",
            description: Text("You haven't added any items yet.")
          )
        } else if !showSearch {
          readSection("To Read", toread, $isEditing)
        }
        if !recentlyRead.isEmpty && !showSearch {
          ForEach(completedByYear, id: \.0) { year, items in
            readSection("Read in \(year)", items, $isEditing)
          }
        }
        if showSearch {
          SearchResultsList(search: searchText, editItem: $isEditing)
        }
      }
      .sheet(isPresented: Binding(get: { isEditing != nil }, set: { _ in isEditing = nil })) {
        ReadItemView(item: isEditing!).padding()
      }
      .toolbar(content: {
        // ToolbarItem(placement: .navigationBarTrailing)
        ToolbarItemGroup(placement: .automatic) {
          Button(action: {
            let item = ReadItem(created: .now, format: .book, title: "")
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
