import Foundation

enum Rating: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
  case none = ""
  case bad = "🤮"
  case meh = "😒"
  case ok = "😐"
  case good = "🙂"
  case great = "😍"

  var label: String {
    switch self {
    case .none: return "None"
    case .bad: return "Bad"
    case .meh: return "Meh"
    case .ok: return "OK"
    case .good: return "Good"
    case .great: return "Great!"
    }
  }

  var emoji: String { self.rawValue }
  var id: Self { self }
  var description :String { rawValue }
}

enum Progress {
  case unstarted
  case started
  case completed

  var icon: String {
    switch self {
    case .unstarted: return "play.square"
    case .started: return "square"
    case .completed: return "checkmark.square"
    }
  }
}

typealias Filter = (String) -> Bool

struct Tag: Codable {
  let name: String
}

protocol Item : AnyObject {
  var id: UUID { get }
  var created: Date { get }
  var link: String? { get set }
  var started: Date? { get set }
  var completed: Date? { get set }
  var notes: String? { get set }

  var title :String { get }
  var subtitle :String? { get }
  var icon :Icon { get }
  var extraIcon :Icon? { get }
  var ratingIcon :String? { get }

  var isProtracted :Bool { get }
}

extension Item {
  var progress: Progress {
    if (started == nil) { return .unstarted }
    else if (completed == nil) { return .started }
    else { return .completed }
  }
}

protocol Consumable : Item {
  var rating: Rating? { get }
  var recommender: String? { get }
}
