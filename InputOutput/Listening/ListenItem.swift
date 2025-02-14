import Foundation
import SwiftData

enum ListenType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
  case song = "Song"
  case album = "Album"
  case podcast = "Podcast"
  case other = "Other"

  var id: Self { self }
  var label: String { rawValue }
  var description: String { rawValue }
}

func listenIcon (_ type :ListenType) -> Icon {
  switch type {
  case .album: .album
  case .song: .song
  case .podcast: .podcast
  case .other: .otherListen
  }
}

typealias ListenItem = SchemaLatest.ListenItem

extension SchemaV4 {
  @Model
  class ListenItem: Identifiable, Consumable {
    // Item properties
    var id: UUID = UUID()
    var created: Date = Date.now
    var tags: [Tag] = []
    var link: String?
    var started: Date?
    var completed: Date?
    var notes: String?

    // Consumable properties
    var rating: Rating?
    var recommender: String?

    // ListenItem properties
    var format: ListenType = ListenType.other
    var title: String = ""
    var artist: String?
    var abandoned: Bool = false

    var subtitle :String? { artist }
    var icon :Icon { listenIcon(format) }
    var extraIcon :Icon? { nil }
    var ratingIcon :String? { if abandoned { "😴" } else { rating.map({ $0.emoji }) } }

    var isProtracted :Bool { format == .podcast }

    init(
      id: UUID = UUID(),
      created: Date,
      tags: [Tag] = [],
      link: String? = nil,
      started: Date? = nil,
      completed: Date? = nil,
      rating: Rating = .none,
      recommender: String? = nil,
      format: ListenType,
      title: String,
      artist: String? = nil,
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
      self.artist = artist
      self.abandoned = abandoned
    }
  }
}

extension SchemaV3 {
  @Model
  class ListenItem: Identifiable {
    var id: UUID = UUID()
    var created: Date = Date.now
    var tags: [Tag] = []
    var link: String?
    var started: Date?
    var completed: Date?
    var notes: String?
    var rating: Rating?
    var recommender: String?
    var format: ListenType = ListenType.other
    var title: String = ""
    var artist: String?
    var abandoned: Bool = false
    
    init () {}
  }
}

var testListenItems: [ListenItem] {
  [
    ListenItem(
      created: .now.addingTimeInterval(-10), started: .now, recommender: "Shiri", format: .song,
      title: "Summer in the City", artist: "Regina Spektor"),
    ListenItem(
      created: .now.addingTimeInterval(-20), link: "https://suemarr.com/order.html", format: .album,
      title: "Beyond the Time", artist: "Suemarr"),
    ListenItem(
      created: .now.addingTimeInterval(-30), format: .other, title: "Susskind Interview"),
    ListenItem(
      created: .now.addingTimeInterval(-40), recommender: "Mom", format: .podcast,
      title: "Steven Pinker: AI in the Age of Reason", artist: "Lex Fridman"),
    ListenItem(
      created: .now.addingTimeInterval(-50), started: .now.addingTimeInterval(-20), completed: .now,
      rating: .good, format: .podcast, title: "Field Guide to Living with Guts and Confidence", artist: "Michael Shermer"),
  ]
}
