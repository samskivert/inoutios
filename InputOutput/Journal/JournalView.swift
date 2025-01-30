import SwiftData
import SwiftUI

func itemDateFormatter() -> DateFormatter {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .none
  return formatter
}

struct ItemDateLabel: View {
  var date :Date
  private let formatter = itemDateFormatter()

  var body: some View {
    Text(formatter.string(from: date))
  }
}

struct SearchResultsList: View {
  private var query :String
  @Query private var matchingItems: [JournalItem]
  
  init(query :String) {
    self.query = query
    _matchingItems = Query(
      filter: JournalItem.searchPredicate(query: query),
      sort: [SortDescriptor(\.when, order: .reverse)])
  }

  var body: some View {
    Section(header: Text("Items matching '\(query)': \(matchingItems.count)")) {
      ForEach(matchingItems) { item in
        ItemDateLabel(date: item.date)
        ForEach(item.entries.filter({ $0.matches(query) })) { entry in
          ReadonlyJournalEntryRow(entry: entry)
        }
      }
    }
  }
}

struct EntriesList: View {
  @Bindable var item: JournalItem
  @Binding var newEntryId: UUID?

  var body: some View {
    if item.entries.isEmpty {
      Text("No entries.")
    } else {
      ForEach($item.entries) { $entry in
        JournalEntryRow(
          entry: $entry,
          isEditing: entry.id == newEntryId,
          onDelete: deleteEntry,
          onEditingDone: {
            newEntryId = nil
            item.updateKeywords()
          }
        )
      }
      .onMove(perform: { from, to in
        item.entries.move(fromOffsets: from, toOffset: to)
      })
      .onDelete(perform: { offsets in
        item.entries.remove(atOffsets: offsets)
        item.updateKeywords()
      })
    }
  }

  private func deleteEntry(id: UUID) {
    withAnimation {
      item.entries.removeAll(where: { $0.id == id })
      item.updateKeywords()
    }
  }
}

struct SingleDayView: View {
  @Environment(\.modelContext) var modelContext

  private var formatter = itemDateFormatter()
  @State private var date = Date.now
  @State private var newEntryId: UUID?
  @State private var showDatePicker = false

  private var item: JournalItem {
    JournalItem.resolve(with: modelContext, date: date)
  }

  var body: some View {
      Section(
        header: HStack {
          Button(action: { date = Date.now }) {
            Image(systemName: "calendar.circle")
          }.buttonStyle(PlainButtonStyle())
          Spacer()
          Button(action: {
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
          }) {
            Image(systemName: "arrowtriangle.left.fill")
          }.buttonStyle(PlainButtonStyle())
          DatePicker(
            "",
            selection: $date,
            displayedComponents: .date
          )
          .labelsHidden()
          Button(action: {
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
          }) {
            Image(systemName: "arrowtriangle.right.fill")
          }.buttonStyle(PlainButtonStyle())
          Spacer()
          Button(action: {
            let entry = JournalEntry(text: "New item")
            newEntryId = entry.id
            self.item.entries.append(entry)
          }) {
            Image(systemName: "plus")
          }.buttonStyle(PlainButtonStyle())
        }
      ) {
        EntriesList(item: self.item, newEntryId: $newEntryId)
      }
  }
}

class JournalViewState: ObservableObject {
  @Published var rawSearchText: String = ""
  @Published var searchText: String = ""

  init() {
    $rawSearchText
      .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
      .assign(to: &$searchText)
  }
}

struct JournalView: View {
  @Environment(\.modelContext) var modelContext

  @StateObject var state = JournalViewState()
  private var showSearch: Bool { state.searchText != "" }

  var body: some View {
    NavigationStack {
      List {
        if showSearch {
          SearchResultsList(query: state.searchText)
        } else {
          SingleDayView()
        }
      }
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
      #endif
      .navigationTitle("Journal")
      .searchable(text: $state.rawSearchText)
    }
  }
}

#Preview {
  JournalView().modelContainer(setupPreviewModelContainer())
}
