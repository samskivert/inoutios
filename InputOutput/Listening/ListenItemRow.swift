import SwiftUI

struct ListenItemRow: View {

  var item :ListenItem
  var editAction :() -> Void

  var body: some View {
    HStack {
      listenItemIcon(item.format)
      itemInfo(item.title, item.artist, item.recommender)
      linkButton(item.link)
      itemStatus(item)
      itemEdit(editAction)
    }
  }
}

#Preview {
  ListenItemRow(item: testListenItems[4], editAction: {}).padding()
}
