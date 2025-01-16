import SwiftUI

struct ReadItemRow: View {
  
  var item :ReadItem
  var editAction :() -> Void

  var body: some View {
    HStack {
      readItemIcon(item.format)
      itemInfo(item.title, item.author, item.recommender)
      linkButton(item.link)
      itemStatus(item)
      itemEdit(editAction)
    }
  }
}

#Preview {
  ReadItemRow(item: testReadItems[1], editAction: {}).padding()
}
