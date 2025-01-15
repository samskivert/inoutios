import SwiftUI

struct WatchItemRow: View {

  var item :WatchItem
  var editAction :() -> Void

  var body: some View {
    HStack {
      watchItemIcon(item.format)
      VStack(alignment: .leading) {
        Text(item.title).font(.headline)
        HStack {
          item.director.map { Text($0).font(.subheadline) }
          item.recommender.map { Text("(via \($0))").font(.subheadline) }
        }
      }.frame(maxWidth: .infinity, alignment: .leading)
      item.link.flatMap({ URL(string: $0) }).map { url in
        Link(destination: url) {
            Image(systemName: "link").resizable().frame(width: 16, height: 16)
        }.buttonStyle(PlainButtonStyle()).padding(4)
      }
      VStack {
        item.ratingIcon().map {
          Text($0)
        }
        item.completed.map { when in
          Text(when, format: .dateTime.day().month()).font(.subheadline)
        }
      }
      if item.completed == nil {
        Button(action: {
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
        }.buttonStyle(PlainButtonStyle()).padding(4)
      }
      Button(action: editAction) {
        Image(systemName: "square.and.pencil").resizable().frame(width: 19, height: 19).padding(.bottom, 4)
      }.buttonStyle(PlainButtonStyle()).padding(4)
    }
  }
}

#Preview {
  WatchItemRow(item: testWatchItems[2], editAction: {}).padding()
}
