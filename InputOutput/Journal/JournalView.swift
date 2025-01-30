import SwiftData
import SwiftUI

struct SearchResultsList: View {
  @Environment(\.dismissSearch) private var dismissSearch
  @EnvironmentObject var state :JournalViewState

  @Query private var matchingItems: [JournalItem]
  private var query :String
  
  init(query :String) {
    self.query = query
    _matchingItems = Query(
      filter: JournalItem.searchPredicate(query: query),
      sort: [SortDescriptor(\.when, order: .reverse)])
  }

  var body: some View {
    Section(header: Text("Items matching '\(query)': \(matchingItems.count)")) {
      ForEach(matchingItems) { item in
        HStack {
          ItemDateLabel(date: item.date)
          Button(action: {
            state.date = item.date
            // clear this directly otherwise we have to wait 0.75 seconds for the debounce
            state.searchText = ""
            dismissSearch()
          }) {
            Image(systemName: "chevron.right.circle")
          }.buttonStyle(PlainButtonStyle())
        }
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
      Text("No entries.").padding([.bottom, .top], 5)
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
  @EnvironmentObject var state :JournalViewState

  @State private var newEntryId: UUID?
  private var formatter = itemDateFormatter()

  private var item: JournalItem {
    JournalItem.resolve(with: modelContext, date: state.date)
  }

  var body: some View {
    Section(
      header: HStack {
        Button(action: { state.date = Date.now }) {
          Image(systemName: "calendar.circle")
        }.buttonStyle(PlainButtonStyle())
        Button(action: {
          state.date = Calendar.current.date(byAdding: .day, value: -1, to: state.date)!
        }) {
          Image(systemName: "arrowtriangle.left.fill")
        }.buttonStyle(PlainButtonStyle())
        ItemDateLabel(date: item.date)
        Button(action: {
          state.date = Calendar.current.date(byAdding: .day, value: 1, to: state.date)!
        }) {
          Image(systemName: "arrowtriangle.right.fill")
        }.buttonStyle(PlainButtonStyle())
        Spacer()
        DatePicker(
          "",
          selection: $state.date,
          displayedComponents: .date
        )
        .labelsHidden()
      }
    ) {
      EntriesList(item: self.item, newEntryId: $newEntryId)
      HStack {
        Spacer()
        Button(action: addItem) {
          Label("Add item", systemImage: "plus.circle")
        }.buttonStyle(PlainButtonStyle())
        Spacer()
      }.padding([.top, .bottom], 5)
    }
  }
  
  private func addItem () {
    let entry = JournalEntry(text: "New item")
    newEntryId = entry.id
    self.item.entries.append(entry)
  }
}

class JournalViewState: ObservableObject {
  @Published var rawSearchText: String = ""
  @Published var searchText: String = ""
  @Published var date = Date.now

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
    .environmentObject(state)
  }
}

#Preview {
  JournalView().modelContainer(setupPreviewModelContainer())
}
