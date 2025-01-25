import SwiftData
import SwiftUI

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
          onEditingDone: { newEntryId = nil }
        )
      }
      .onMove(perform: { from, to in
        item.entries.move(fromOffsets: from, toOffset: to)
      })
      .onDelete(perform: { offsets in
        item.entries.remove(atOffsets: offsets)
      })
    }
  }

  private func deleteEntry(id: UUID) {
    withAnimation {
      item.entries.removeAll(where: { $0.id == id })
    }
  }
}

struct SingleDayView: View {
  @Environment(\.modelContext) var modelContext

  private var formatter = DateFormatter()
  @State private var date = Date.now
  @State private var newEntryId: UUID?
  @State private var showDatePicker = false

  init() {
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
  }

  private var item: JournalItem {
    JournalItem.resolve(with: modelContext, date: date)
  }

  var body: some View {
    List {
      Section(
        header: HStack {
          Button(action: { showDatePicker.toggle() }) {
            Image(systemName: "calendar")
          }.buttonStyle(PlainButtonStyle())
          if showDatePicker {
            DatePicker(
              "",
              selection: $date,
              displayedComponents: .date
            )
            .labelsHidden()
          } else {
            Button(action: {
              date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            }) {
              Image(systemName: "arrowtriangle.left.fill")
            }.buttonStyle(PlainButtonStyle())
            Text(formatter.string(from: date))
            Button(action: {
              date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            }) {
              Image(systemName: "arrowtriangle.right.fill")
            }.buttonStyle(PlainButtonStyle())
          }
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
}

struct JournalView: View {
  @Environment(\.modelContext) var modelContext

  @State private var date: Date = .now
  @State private var searchText: String = ""
  @State private var showHistory: Bool = false
  private var showSearch: Bool { searchText != "" && searchText.count > 1 }

  var body: some View {
    NavigationStack {
      SingleDayView()
        .toolbar(content: {
          ToolbarItemGroup(placement: .automatic) {
            Toggle(isOn: $showHistory) {
              Image(systemName: "calendar")
            }
          }
        })
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
          .listStyle(GroupedListStyle())
        #endif
        .navigationTitle("Journal")
        .searchable(text: $searchText)
    }
  }
}

#Preview {
  JournalView().modelContainer(setupPreviewModelContainer())
}
