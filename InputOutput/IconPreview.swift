import SwiftUI

struct IconPreview: View {
    var body: some View {
      HStack {
        ForEach(Icon.allCases) { icon($0) }
      }
    }
}

#Preview {
  IconPreview().padding()
}
