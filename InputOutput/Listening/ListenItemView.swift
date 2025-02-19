import SwiftUI

struct ListenItemView : View {
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) private var dismiss
  @State var item :ListenItem

  var body :some View {
    Form {
      TextField("Title", text: $item.title)
      TextField("Artist", text: $item.artist ?? "")
      Picker("Type", selection: $item.format) {
        ForEach(ListenType.allCases) { option in
          HStack {
            icon(listenIcon(option))
            Text(String(describing: option))
          }
        }
      }
      TextField("Recommender", text: $item.recommender ?? "")
      TextField("Link", text: $item.link ?? "")
#if os(iOS)
        .textInputAutocapitalization(.never)
        .keyboardType(.URL)
#endif
      Picker("Rating", selection: $item.rating ?? .none) {
        ForEach(Rating.allCases) { option in
          Text(String(describing: option))
        }
      }
      TextField("Notes", text: $item.notes ?? "", axis: .vertical).lineLimit(3...5)
      if item.isProtracted {
        Toggle(isOn: $item.abandoned) {
          Text("Abandoned")
        }
      }
      if item.started != nil {
        HStack {
          DatePicker("Started", selection: $item.started ?? Date(), displayedComponents: [.date])
          Button(action: {
            item.started = nil
          }) {
            Image(systemName: "delete.left")
          }
        }
      }
      if item.completed != nil {
        HStack {
          DatePicker("Completed", selection: $item.completed ?? Date(), displayedComponents: [.date])
          Button(action: {
            item.completed = nil
          }) {
            Image(systemName: "delete.left")
          }
        }
      }
      HStack {
        Text("Created:")
        Text(item.created, format: .dateTime.day().month().year())
      }
      HStack {
        // these buttons have to be marked .borderless otherwise clicking anywhere in the HStack
        // will trigger the first button, yay!
        Button(role: .destructive, action: {
          modelContext.delete(item)
          dismiss()
        }) {
          Image(systemName: "trash")
        }.buttonStyle(.borderless)
        Spacer()
        Button("Close") {
          dismiss()
        }.buttonStyle(.borderless)
      }
    }
#if !os(iOS)
    .padding()
#endif
  }
}

#Preview {
  ListenItemView(item: testListenItems[0])
}
