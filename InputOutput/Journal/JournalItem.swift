import Foundation
import SwiftData

extension SchemaV1 {
  struct JournalEntry: Codable, Identifiable {
    var id = UUID()  // so SwiftUI can keep track of this in memory
    var text: String
    var tags: [String]?

    enum CodingKeys: String, CodingKey {
      case text
      case tags
    }
  }

  @Model
  class JournalItem: Identifiable, CustomStringConvertible {
    var id: UUID = UUID()
    var year: Int = 1970
    var month: Int = 1
    var day: Int = 1
    var entries: [JournalEntry] = []

    init(
      id: UUID = UUID(),
      year: Int,
      month: Int,
      day: Int,
      entries: [JournalEntry] = []
    ) {
      self.id = id
      self.year = year
      self.month = month
      self.day = day
      self.entries = entries
    }

    var description: String { "\(year)-\(month)-\(day): \(entries.count) entries" }

    static func resolve(with modelContext: ModelContext, date: Date) -> JournalItem {
      let year = Calendar.current.component(.year, from: date)
      let month = Calendar.current.component(.month, from: date)
      let day = Calendar.current.component(.day, from: date)
      let fetch = FetchDescriptor<JournalItem>(
        predicate: #Predicate { item in
          item.year == year && item.month == month && item.day == day
        })
      do {
        if let result = try modelContext.fetch(fetch).first {
          // print("Loaded item: \(result.year) \(result.month) \(result.day) \(result.entries)")
          return result
        }
      } catch {
        print("Error fetching JournalItem: \(error)")
      }
      let instance = JournalItem(
        year: year, month: month, day: day, entries: []
      )
      print("Creating new item \(year) \(month) \(day)")
      modelContext.insert(instance)
      return instance
    }
  }
}

typealias JournalEntry = SchemaV1.JournalEntry
typealias JournalItem = SchemaV1.JournalItem

var testJournalItems: [JournalItem] {
  [
    JournalItem(
      year: 2025, month: 1, day: 23,
      entries: [
        JournalEntry(text: "Worked on iOS I/O", tags: ["IO"]),
        JournalEntry(text: "Taxied Remy to/from school"),
        JournalEntry(text: "Listened to Jon Bishop set, nostalgic!"),
      ]),
    JournalItem(
      year: 2025, month: 1, day: 22,
      entries: [
        JournalEntry(text: "Wednesday morning shenanigans"),
        JournalEntry(text: "More work on iOS I/O", tags: ["IO"]),
        JournalEntry(text: "This, that, the other", tags: ["misc", "foo"]),
      ]),
  ]
}
