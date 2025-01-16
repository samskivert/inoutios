import Foundation
import SwiftData

enum ReadType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
  case article = "Article"
  case book = "Book"
  case paper = "Paper"
  case audiobook = "Audiobook"

  var id: Self { self }
  var label: String { rawValue }
  var description: String { rawValue }
}

struct ReadJson: Decodable {
  var id: String
  var author: String?
  var created: UInt64
  var title: String
  var type: String
  var tags: [String]?
  var link: String?
  var rating: String?
  var started: String?
  var completed: String?
  var recommender: String?
  var abandoned: Bool?
}

extension SchemaV1 {
  @Model
  class ReadItem: Identifiable, Consumable, Item {
    // Item properties
    var id: UUID = UUID()
    var created: Date = Date.now
    var tags: [Tag] = []
    var link: String?
    var started: Date?
    var completed: Date?

    // Consumable properties
    var rating: Rating?
    var recommender: String?

    // ReadItem properties
    var format: ReadType = ReadType.book
    var title: String = ""
    var author: String?
    var abandoned: Bool = false

    init(
      id: UUID = UUID(),
      created: Date,
      tags: [Tag] = [],
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

    func isProtracted() -> Bool { true }
    func startable() -> Bool { started != nil }

    func ratingIcon() -> String? {
      if abandoned { "😴" } else { rating.map({ $0.emoji }) }
    }
  }
}

typealias ReadItem = SchemaV1.ReadItem

var testReadItems: [ReadItem] {
  [
    ReadItem(
      created: .now.addingTimeInterval(-10), started: .now, recommender: "Some guy", format: .book,
      title: "The Cat in the Hat", author: "Dr. Seuss"),
    ReadItem(
      created: .now.addingTimeInterval(-20), link: "https://samskivert.com/", format: .audiobook,
      title: "One Flew Over the Cuckoo's Nest", author: "Ken Kesey"),
    ReadItem(
      created: .now.addingTimeInterval(-30), format: .article, title: "A Brief History of Chickens"),
    ReadItem(
      created: .now.addingTimeInterval(-40), recommender: "Mom", format: .book,
      title: "The Great Gatsby", author: "F. Scott Fitzgerald"),
    ReadItem(
      created: .now.addingTimeInterval(-50), started: .now.addingTimeInterval(-20), completed: .now,
      rating: .good, format: .paper, title: "Goto Considered Harmful", author: "Edsgar Dijkstra"),
  ]
}
