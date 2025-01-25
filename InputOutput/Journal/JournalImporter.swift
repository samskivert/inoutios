import Foundation

struct JournalEntryJson : Decodable {
  var text: String
  var tags: [String]?
}

struct JournalJson: Decodable {
  var id: String
  var date: String // yyyy-mm-dd
  var entries: [String: JournalEntryJson]
  var order: [String]?
}

struct JournalImporter {
  let dateFormatter = DateFormatter()

  func importItems(_ data: Data) -> [JournalItem] {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    dateFormatter.dateFormat = "yyyy-MM-dd"

    var items = [JournalItem]()
    do {
      let jsons = try decoder.decode([JournalJson].self, from: data)
      for json in jsons {
        // print("Decoded: \(json)")
        if let date = parseDate(json.date) {
          let calendar = Calendar.current
          let year = calendar.component(.year, from: date)
          let month = calendar.component(.month, from: date)
          let day = calendar.component(.day, from: date)
          var sortedKeys = Array(json.entries.keys).map { Int($0)! }
          sortedKeys.sort()
          var entries :[SchemaV1.JournalEntry] = []
          let entryKeys = if let order = json.order { order } else { sortedKeys.map { String($0) } }
          for idstr in entryKeys {
            if let entry = json.entries[idstr] {
              if let id = Int(idstr) {
                // print("Parsed entry \(json.date) (\(year) \(month) \(day)): \(id) -> \(entry.text) \(entry.tags ?? [])" )
                entries.append(SchemaV1.JournalEntry(text: entry.text, tags: entry.tags))
              } else {
                print("Invalid id \(idstr)")
              }
            }
          }
          if entries.count > 0 {
            items.append(
              JournalItem(
                id: UUID(),
                year: year, month: month, day: day,
                entries: entries
              ))
          }
        }
      }
    } catch {
      print("Error decoding JSON: \(error)")
    }
    return items
  }

  func parseDate(_ when: String?) -> Date? {
    if when == nil { return nil }
    return dateFormatter.date(from: when!)
  }
}
