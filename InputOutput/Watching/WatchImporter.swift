import Foundation

struct WatchImporter {
    let dateFormatter = DateFormatter()

    func importItems(_ data: Data) -> [WatchItem] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        dateFormatter.dateFormat = "yyyy-MM-dd"

        var items = [WatchItem]()
        do {
          let jsons = try decoder.decode([WatchJson].self, from: data)
          for json in jsons {
            print("Decoded: \(json)")
            items.append(
              WatchItem(
                id: UUID(),
                created: Date(timeIntervalSince1970: TimeInterval(json.created) / 1000),
                tags: (json.tags ?? []).map({ Tag(name: $0) }),
                link: json.link,
                started: parseDate(json.started),
                completed: parseDate(json.completed),
                rating: parseRating(json.rating),
                recommender: json.recommender,
                format: parseType(json.type),
                title: json.title,
                director: json.director ?? "",
                abandoned: json.abandoned ?? false
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

    func parseType(_ format: String) -> WatchType {
        switch format {
        case "film": return .film
        case "show": return .show
        case "video": return .video
        default:
            print("Unknown format: \(format)")
            return .film
        }
    }

    func parseDate(_ when: String?) -> Date? {
        if when == nil { return nil }
        return dateFormatter.date(from: when!)
    }
}
