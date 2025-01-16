import SwiftUI

struct PlayItemRow: View {

  var item :PlayItem
  var editAction :() -> Void

  var body: some View {
    HStack {
      playItemIcon(item.platform)
      itemInfo(item.title, item.platform.label, item.recommender)
      linkButton(item.link)
      if item.sawCredits {
        Image(systemName: "flag.pattern.checkered").resizable().frame(width: 16, height: 16)
      }
      itemStatus(item)
      itemEdit(editAction)
    }
  }
}

#Preview {
  PlayItemRow(item: testPlayItems[4], editAction: {}).padding()
}
