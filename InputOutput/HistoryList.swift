import SwiftUI

struct HistoryList<I, E>: View where I : Consumable, I : Identifiable, E : View {
  let completed: [I]
  let verbed :String
  let mkView: (I) -> E

  private var completedByYear: [(Int, [I])] {
    let calendar = Calendar.current
    let byyear = Dictionary(
      grouping: completed, by: { calendar.component(.year, from: $0.completed!) }
    )
    return Array(byyear.keys).sorted(by: { $0 > $1 }).map { year in
      (year, Array(byyear[year]!))
    }
  }

  var body: some View {
    if completed.isEmpty {
      noItems("No completed items")
    } else {
      ForEach(completedByYear, id: \.0) { year, items in
        itemSection("\(self.verbed) in \(year)", items, { self.mkView($0) })
      }
    }
  }
}
