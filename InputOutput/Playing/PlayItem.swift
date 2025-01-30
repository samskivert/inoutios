import Foundation
import SwiftData

enum Platform: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
  case pc = "PC"
  case table = "Tabletop"
  case mobile = "Mobile"
  case vr = "VR"

  case nswitch = "Switch"
  case n3ds = "3DS"
  case wiiu = "WiiU"
  case wii = "Wii"
  case cube = "GameCube"
  case n64 = "N64"
  case gameboy = "GameBoy"

  case dcast = "Dreamcast"

  case ps1 = "PS1"
  case ps2 = "PS2"
  case ps3 = "PS3"
  case ps4 = "PS4"
  case ps5 = "PS5"
  case vita = "Vita"

  case xbox = "XBOX"

  var id: Self { self }
  var label: String { rawValue }
  var description: String { rawValue }
}

func playIcon (_ platform :Platform) -> Icon {
  switch platform {
  case .pc: .pc
  case .table: .table
  case .mobile: .mobile
  case .vr: .vr
  case .nswitch, .vita: .controller1
  case .n3ds, .wiiu, .wii, .cube, .n64, .gameboy, .dcast: .controller2
  case .ps1, .ps2, .ps3, .ps4, .ps5: .playstation
  case .xbox: .xbox
  }
}

extension SchemaV3 {
  @Model
  class PlayItem: Identifiable, Consumable {
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

    // PlayItem properties
    var platform: Platform = Platform.pc
    var title: String = ""
    var sawCredits: Bool = false

    var subtitle :String? { platform.label }
    var icon :Icon { playIcon(platform) }
    var extraIcon :Icon? { if sawCredits { .sawCredits } else { nil } }
    var ratingIcon: String? { rating.map({ $0.emoji }) }

    var isProtracted: Bool { true }

    init(
      id: UUID = UUID(),
      created: Date,
      tags: [Tag] = [],
      link: String? = nil,
      started: Date? = nil,
      completed: Date? = nil,
      rating: Rating = .none,
      recommender: String? = nil,
      platform: Platform,
      title: String,
      sawCredits: Bool = false
    ) {
      self.id = id
      self.created = created
      self.tags = tags
      self.link = link
      self.started = started
      self.completed = completed
      self.rating = rating
      self.recommender = recommender
      self.platform = platform
      self.title = title
      self.sawCredits = sawCredits
    }
  }
}

typealias PlayItem = SchemaV3.PlayItem

var testPlayItems: [PlayItem] {
  [
    PlayItem(
      created: .now.addingTimeInterval(-10), started: .now, recommender: "Some guy",
      platform: .xbox, title: "Psychonauts"),
    PlayItem(
      created: .now.addingTimeInterval(-20), link: "https://samskivert.com/", platform: .nswitch,
      title: "Golf Story"),
    PlayItem(
      created: .now.addingTimeInterval(-30), platform: .pc, title: "A Brief History of Chickens"),
    PlayItem(
      created: .now.addingTimeInterval(-40), recommender: "Walter", platform: .ps4,
      title: "Sea of Solitude"),
    PlayItem(
      created: .now.addingTimeInterval(-50), started: .now.addingTimeInterval(-20), completed: .now,
      rating: .good, platform: .xbox, title: "Worms XBL", sawCredits: true),
  ]
}
