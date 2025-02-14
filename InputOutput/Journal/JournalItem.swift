import Foundation
import SwiftData

typealias JournalEntry = SchemaLatest.JournalEntry
typealias JournalItem = SchemaLatest.JournalItem

extension SchemaV4 {
  struct JournalEntry: Codable, Identifiable {
    var id = UUID()  // so SwiftUI can keep track of this in memory
    var text: String
    var tags: [String]?

    enum CodingKeys: String, CodingKey {
      case text
      case tags
    }
    
    func matches(_ query :String) -> Bool {
      text.localizedStandardContains(query)
    }
  }

  @Model
  class JournalItem: Identifiable, CustomStringConvertible {
    var id: UUID = UUID()
    var when :Int = 19700101
    var entries: [JournalEntry] = []
    var keywords :String = ""

    init(
      id: UUID = UUID(),
      when: Int,
      entries: [JournalEntry] = []
    ) {
      self.id = id
      self.when = when
      self.entries = entries
      self.keywords = computeKeywords(entries)
    }

    var year: Int { when / 10000 }
    var month: Int { (when / 100) % 100 }
    var day: Int { when % 100 }
    var description: String { "\(year)-\(month)-\(day): \(entries.count) entries" }

    var date :Date {
      var components = DateComponents()
      components.year = year
      components.month = month
      components.day = day
      return Calendar.current.date(from: components)!
    }

    func updateKeywords () {
      let keywords = computeKeywords(entries)
      if keywords != self.keywords {
        self.keywords = keywords // presumably this triggers some SwiftData sync magic
      }
    }

    static func resolve(with modelContext: ModelContext, date: Date) -> JournalItem {
      let when = toWhen(date)
      let fetch = FetchDescriptor<JournalItem>(
        predicate: #Predicate { item in item.when == when })
      do {
        var results = try modelContext.fetch(fetch)
        if results.count > 1 {
          print("Duplicate JournalItem for day \(date): \(results.count)")
          for result in results {
            if result.entries.isEmpty {
              print("Deleting blank duplicate for \(date)")
              modelContext.delete(result)
            }
          }
          results.removeAll(where: { $0.entries.isEmpty })
        }
        if let result = results.first {
          // print("Loaded item: \(result.year) \(result.month) \(result.day) \(result.entries)")
          return result
        }
      } catch {
        print("Error fetching JournalItem: \(error)")
      }
      let instance = JournalItem(when: when, entries: [])
      print("Creating new item: \(when)")
      modelContext.insert(instance)
      return instance
    }

    static func searchPredicate(query: String) -> Predicate<JournalItem> {
      #Predicate<JournalItem> { item in
        item.keywords.localizedStandardContains(query)
      }
    }
  }
}

extension SchemaV3 {
  typealias JournalEntry = SchemaV4.JournalEntry
  typealias JournalItem = SchemaV4.JournalItem
}

extension SchemaV2 {
  typealias JournalEntry = SchemaV3.JournalEntry

  @Model
  class JournalItem: Identifiable {
    var id: UUID = UUID()
    var year: Int = 1970
    var month: Int = 1
    var day: Int = 1
    var when :Int = 19700101
    var entries: [JournalEntry] = []
    var keywords :String = ""

    init() {}
  }
}

extension SchemaV1 {
  typealias JournalEntry = SchemaV2.JournalEntry

  @Model
  class JournalItem: Identifiable {
    var id: UUID = UUID()
    var year: Int = 1970
    var month: Int = 1
    var day: Int = 1
    var entries: [JournalEntry] = []
    
    init() {}
  }
}

func toWhen(_ year :Int, _ month :Int, _ day :Int) -> Int { year * 10000 + month * 100 + day }

func toWhen(_ date :Date) -> Int {
  let year = Calendar.current.component(.year, from: date)
  let month = Calendar.current.component(.month, from: date)
  let day = Calendar.current.component(.day, from: date)
  return toWhen(year, month, day)
}

func computeKeywords (_ entries :[JournalEntry]) -> String {
  var words :Set<String> = []
  for entry in entries {
    for word in entry.text.split(separator: " ") {
      if word.count > 2 {
        words.insert(String(word).lowercased())
      }
    }
  }
  return words.joined(separator: " ")
}

var testJournalItems: [JournalItem] {
  [
    JournalItem(
      when: toWhen(.now),
      entries: [
        JournalEntry(text: "Worked on iOS I/O", tags: ["IO"]),
        JournalEntry(text: "Taxied Remy to/from school"),
        JournalEntry(text: "Listened to Jon Bishop set, nostalgic!"),
      ]),
    JournalItem(
      when: 20250122,
      entries: [
        JournalEntry(text: "Wednesday morning shenanigans"),
        JournalEntry(text: "More work on iOS I/O", tags: ["IO"]),
        JournalEntry(text: "This, that, the other", tags: ["misc", "foo"]),
      ]),
  ]
}
