import SwiftData
import SwiftUI

func noItems(_ message :String) -> some View {
  ContentUnavailableView(
    message,
    systemImage: "doc.text",
    description: Text("You haven't added any items yet.")
  )
}

struct ItemButton<I,E> :View where I : Item, I : PersistentModel, E : View {
  @Environment(\.modelContext) var modelContext
  @State private var newItem: I? = nil
  private var mkItem: () -> I
  private var mkView: (I) -> E

  var body: some View {
    Button(action: {
      let item = mkItem()
      modelContext.insert(item)
      newItem = item
    }) {
      Image(systemName: "plus")
    }
    .navigationDestination(item: $newItem) { item in
      mkView(item).onDisappear { newItem = nil }
    }
  }
}
