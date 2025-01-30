import SwiftUI

struct ReadonlyJournalEntryRow: View {
  var entry :JournalEntry
  
  var body: some View {
    HStack {
      Image(systemName: "circle.fill").resizable().frame(width: 10, height: 10)
      Text(entry.text)
      
      Spacer()
      if let tags = entry.tags {
        ForEach(tags, id: \.self) { tag in
          Text(tag).foregroundColor(.white)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
            .background(.gray).cornerRadius(15)
        }
      }
    }
    .frame(minHeight: 30)
  }
}

struct JournalEntryRow: View {
  @Binding var entry: JournalEntry
  @State var isEditing: Bool
  var onDelete :((UUID) -> Void)?
  var onEditingDone :() -> Void
  @State private var restoreText = ""
  @FocusState private var isFocused: Bool

  var body: some View {
    HStack {
      Image(systemName: isEditing ? "circle" : "circle.fill").resizable().frame(width: 10, height: 10)
      if isEditing {
        TextField("", text: $entry.text)
          .focused($isFocused)
          .onSubmit {
            restoreText = entry.text
          }
          .onChange(of: isFocused) { wasFocused, isFocused in
            if !isFocused {
              isEditing = false
              onEditingDone()
            }
          }
        #if os(macOS)
          .onExitCommand(perform: {
            entry.text = restoreText
            isEditing = false
          })
        #endif
        #if os(macOS)
        if let onDelete = onDelete {
          Button(action: { onDelete(entry.id) }) {
            Image(systemName: "trash")
          }.buttonStyle(PlainButtonStyle())
        }
        #endif
      } else {
        Text(entry.text)
          .onTapGesture(count: 1, perform: {
            isEditing = true
            isFocused = true
          })
      }

      Spacer()
      if let tags = entry.tags {
        ForEach(tags, id: \.self) { tag in
          Text(tag).foregroundColor(.white)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
            .background(.gray).cornerRadius(15)
        }
      }
    }
    .frame(minHeight: 30)
    .onAppear {
      restoreText = entry.text
      isFocused = isEditing
    }
  }
}

struct JournalEntryRowPreview: View {
  @State var item :JournalItem

  var body: some View {
    JournalEntryRow(
      entry: $item.entries[0],
      isEditing: false,
      onDelete: { id in /* nada */},
      onEditingDone: { /* nada */ }
    ).padding()
  }
}

#Preview {
  JournalEntryRowPreview(item:testJournalItems[0])
}
