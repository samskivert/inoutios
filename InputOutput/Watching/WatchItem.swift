import Foundation
import SwiftData

enum WatchType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
  case show = "Show"
  case film = "Film"
  case video = "Video"
  case other = "Other"

  var id: Self { self }
  var label: String { rawValue }
  var description: String { rawValue }
}

struct WatchJson: Decodable {
  var id: String
  var director: String?
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
  class WatchItem: Identifiable, Consumable {
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

    // WatchItem properties
    var format: WatchType = WatchType.film
    var title: String = ""
    var director: String?
    var abandoned: Bool = false

    var subtitle :String? { director }
    var icon :Icon {
      switch format {
      case .show: .show
      case .film: .film
      case .video: .video
      case .other: .otherWatch
      }
    }
    var extraIcon :Icon? { nil }
    var ratingIcon: String? { if abandoned { "😴" } else { rating.map({ $0.emoji }) } }

    var isProtracted: Bool { format != .film }

    init(
      id: UUID = UUID(),
      created: Date,
      tags: [Tag] = [],
      link: String? = nil,
      started: Date? = nil,
      completed: Date? = nil,
      rating: Rating = .none,
      recommender: String? = nil,
      format: WatchType,
      title: String,
      director: String? = nil,
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
      self.director = director
      self.abandoned = abandoned
    }
  }
}

typealias WatchItem = SchemaV1.WatchItem

var testWatchItems: [WatchItem] {
  [
    WatchItem(
      created: .now.addingTimeInterval(-10), started: .now, recommender: "Some guy", format: .video,
      title: "The Cat in the Hat", director: "Dr. Seuss"),
    WatchItem(
      created: .now.addingTimeInterval(-20), link: "https://samskivert.com/", format: .film,
      title: "One Flew Over the Cuckoo's Nest", director: "Ken Kesey"),
    WatchItem(
      created: .now.addingTimeInterval(-30), format: .other, title: "A Brief History of Chickens"),
    WatchItem(
      created: .now.addingTimeInterval(-40), recommender: "Mom", format: .show,
      title: "The Great Gatsby", director: "F. Scott Fitzgerald"),
    WatchItem(
      created: .now.addingTimeInterval(-50), started: .now.addingTimeInterval(-20), completed: .now,
      rating: .good, format: .film, title: "Anomalisa", director: "Kaufman"),
  ]
}
