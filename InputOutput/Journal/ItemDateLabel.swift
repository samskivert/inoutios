import SwiftData
import SwiftUI

func itemDateFormatter() -> DateFormatter {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .none
  return formatter
}

struct ItemDateLabel: View {
  var date :Date
  private let formatter = itemDateFormatter()

  var body: some View {
    Text(date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year()))
  }
}

#Preview {
  ItemDateLabel(date: .now).padding()
}
