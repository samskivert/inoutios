import Foundation
import SwiftData

enum ReadType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
  case article = "Article"
  case book = "Book"
  case paper = "Paper"

  var id: Self { self }
  var label: String { rawValue }
  var description :String { rawValue }
}

struct ReadJson: Decodable {
  var id: String
  var author: String
  var created: String
  var title: String
  var type: String
  var tags: [String]
  var link: String?
  var rating: String
  var started :String?
  var completed: String?
}

@Model
class ReadItem: Identifiable, Consumable, Decodable {
  // Item properties
  var id: UUID
  var created: Date
  var tags: [String]
  var link: String?
  var started: Date?
  var completed: Date?

  // Consumable properties
  var rating: Rating?
  var recommender: String?

  // ReadItem properties
  var format: ReadType
  var title: String
  var author: String?
  var abandoned: Bool

  init(id: UUID = UUID(),
       created: Date,
       tags: [String] = [],
       link: String? = nil,
       started: Date? = nil,
       completed: Date? = nil,
       rating: Rating = .none,
       recommender: String? = nil,
       format: ReadType,
       title: String,
       author: String? = nil,
       abandoned: Bool = false
  ) {
    self.id = id
    self.created = created
    self.tags = tags
    self.link = link
    self.started = started
    self.completed = completed
    self.rating = rating
    self.recommender = recommender
    self.format = format
    self.title = title
    self.author = author
    self.abandoned = abandoned
  }

  required convenience init(from decoder :Decoder) throws {
    let json = try ReadJson(from: decoder)
    let format = ReadType.book
    self.init(id: UUID(), created: Date(), tags: json.tags, link: json.link, started: nil, completed: nil, rating: .none, recommender: nil, format: format, title: json.title, author: json.author, abandoned: false)
  }

  func isProtracted() -> Bool { true }
  func startable() -> Bool { started != nil }
}

var testReadItems: [ReadItem] {
  [
    ReadItem(created: .now.addingTimeInterval(-10), started: .now, recommender: "Some guy", format: .book, title: "The Cat in the Hat", author: "Dr. Seuss"),
    ReadItem(created: .now.addingTimeInterval(-20), format: .book, title: "One Flew Over the Cuckoo's Nest", author: "Ken Kesey"),
    ReadItem(created: .now.addingTimeInterval(-30), format: .article, title: "A Brief History of Chickens"),
    ReadItem(created: .now.addingTimeInterval(-40), recommender: "Mom", format: .book, title: "The Great Gatsby", author: "F. Scott Fitzgerald"),
    ReadItem(created: .now.addingTimeInterval(-50), started: .now.addingTimeInterval(-20), completed: .now, format: .paper, title: "Goto Considered Harmful", author: "Edsgar Dijkstra"),
  ]
}
