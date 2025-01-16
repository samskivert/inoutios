import SwiftUI

struct IconPreview: View {
    var body: some View {
      HStack {
        ForEach(ReadType.allCases) { readItemIcon($0) }
      }
      HStack {
        ForEach(WatchType.allCases) { watchItemIcon($0) }
      }
      HStack {
        ForEach(Platform.allCases) { playItemIcon($0) }
      }
    }
}

#Preview {
  IconPreview().padding()
}
