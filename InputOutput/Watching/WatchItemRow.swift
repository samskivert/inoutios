import SwiftUI

struct WatchItemRow: View {

  var item :WatchItem
  var editAction :() -> Void

  var body: some View {
    HStack {
      watchItemIcon(item.format)
      itemInfo(item.title, item.director, item.recommender)
      linkButton(item.link)
      itemStatus(item)
      itemEdit(editAction)
    }
  }
}

#Preview {
  WatchItemRow(item: testWatchItems[4], editAction: {}).padding()
}
