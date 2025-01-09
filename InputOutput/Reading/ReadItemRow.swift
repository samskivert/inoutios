import SwiftUI

func readItemIcon (_ format: ReadType) -> some View {
  switch format {
  case .book:
    Image(systemName: "book").resizable().frame(width: 22, height: 18).padding(.all, 0)
  case .paper:
    Image(systemName: "newspaper").resizable().frame(width: 22, height: 18).padding(.all, 0)
  case .article:
    Image(systemName: "magazine").resizable().frame(width: 18, height: 18)
      .padding([.leading, .trailing], 2)
  }
}

struct ReadItemRow: View {
  
  var item :ReadItem
  var editAction :() -> Void

  var body: some View {
    HStack {
      readItemIcon(item.format)
      VStack(alignment: .leading) {
        Text(item.title).font(.headline)
        HStack {
          item.author.map { Text($0).font(.subheadline) }
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
      Button(action: {
        if (item.started == nil) {
          item.started = .now
        } else if (item.completed == nil) {
          item.completed = .now
        } else {
          item.completed = nil
        }
      }) {
        Image(systemName: item.progress.icon).resizable().frame(width: 16, height: 16)
      }.buttonStyle(PlainButtonStyle()).padding(4)
      Button(action: editAction) {
        Image(systemName: "square.and.pencil").resizable().frame(width: 19, height: 19).padding(.bottom, 4)
      }.buttonStyle(PlainButtonStyle()).padding(4)
    }
  }
}

#Preview {
  ReadItemRow(item: testReadItems[4], editAction: {}).padding()
}
