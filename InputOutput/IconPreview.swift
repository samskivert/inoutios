import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct IconPreview: View {
    var body: some View {
      VStack {
        ForEach(Icon.allCases.chunked(into: 7), id: \.self) { row in
          HStack {
            ForEach(row) { icon($0) }
          }
        }
      }
    }
}

#Preview {
  IconPreview().padding()
}
