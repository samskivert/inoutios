import Foundation

struct PlayImporter {
    let dateFormatter = DateFormatter()

    func importItems(_ data: Data) -> [PlayItem] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        dateFormatter.dateFormat = "yyyy-MM-dd"

        var items = [PlayItem]()
        do {
          let jsons = try decoder.decode([PlayJson].self, from: data)
          for json in jsons {
            print("Decoded: \(json)")
            items.append(
              PlayItem(
                id: UUID(),
                created: Date(timeIntervalSince1970: TimeInterval(json.created) / 1000),
                tags: (json.tags ?? []).map({ Tag(name: $0) }),
                link: json.link,
                started: parseDate(json.started),
                completed: parseDate(json.completed),
                rating: parseRating(json.rating),
                recommender: json.recommender,
                platform: parsePlatform(json.platform ?? "pc"),
                title: json.title,
                sawCredits: json.credits ?? false
              ))
          }
        } catch {
          print("Error decoding JSON: \(error)")
        }
        return items
    }

    func parseRating(_ rating: String?) -> Rating {
        if let r = rating {
            switch r {
            case "none": return .none
            case "bad": return .bad
            case "meh": return .meh
            case "ok": return .ok
            case "good": return .good
            case "great": return .great
            default:
                print("Unknown rating \(r)")
                return .none
            }
        } else {
            return .none
        }
    }

    func parsePlatform(_ format: String) -> Platform {
        switch format {
        case "pc": return .pc
        case "table": return .table
        case "mobile": return .mobile
        case "switch": return .nswitch
        case "3ds": return .n3ds
        case "wiiu": return .wiiu
        case "wii": return .wii
        case "cube": return .cube
        case "n64": return .n64
        case "gb": return .gameboy
        case "ps1": return .ps1
        case "ps2": return .ps2
        case "ps3": return .ps3
        case "ps4": return .ps4
        case "ps5": return .ps5
        case "vita": return .vita
        case "xbox": return .xbox
        default:
            print("Unknown format: \(format)")
            return .pc
        }
    }

    func parseDate(_ when: String?) -> Date? {
        if when == nil { return nil }
        return dateFormatter.date(from: when!)
    }
}
