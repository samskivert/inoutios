import SwiftUI

func ??<T>(binding: Binding<T?>, fallback: T) -> Binding<T> where T : Equatable {
  return Binding(get: {
    binding.wrappedValue ?? fallback
  }, set: {
    if ($0 == fallback) {
      binding.wrappedValue = nil
    } else {
      binding.wrappedValue = $0
    }
  })
}

func linkButton (_ link: String?) -> Optional<some View> {
  link.flatMap({ URL(string: $0) }).map { url in
    Link(destination: url) {
      Image(systemName: "link").resizable().frame(width: 16, height: 16)
    }.buttonStyle(PlainButtonStyle()).padding(4)
  }
}

func itemInfo (_ title :String, _ subtitle :String?, _ recommender :String?) -> some View {
  VStack(alignment: .leading) {
    Text(title).font(.headline)
    HStack {
      subtitle.map { Text($0).font(.subheadline) }
      recommender.map { Text("(via \($0))").font(.subheadline) }
    }
  }.frame(maxWidth: .infinity, alignment: .leading)
}

func itemStatus (_ item :Item) -> AnyView {
  if let when = item.completed {
    AnyView(VStack {
      item.ratingIcon().map { Text($0) }
      Text(when, format: .dateTime.day().month()).font(.subheadline)
    })
  } else {
    AnyView(Button(action: {
      if item.started == nil && item.isProtracted() {
        item.started = .now
      } else if item.completed == nil {
        if item.started == nil {
          item.started = .now
        }
        item.completed = .now
      } else {
        item.completed = nil
      }
    }) {
      Image(systemName: item.progress.icon).resizable().frame(width: 16, height: 16)
    }.buttonStyle(PlainButtonStyle()).padding(4))
  }
}

func itemEdit (_ editAction :@escaping () -> Void) -> some View {
  Button(action: editAction) {
    Image(systemName: "square.and.pencil").resizable().frame(width: 19, height: 19).padding(.bottom, 4)
  }.buttonStyle(PlainButtonStyle()).padding(4)
}