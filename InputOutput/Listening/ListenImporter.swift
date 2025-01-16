import Foundation

struct ListenImporter {
    let dateFormatter = DateFormatter()

    func importItems(_ data: Data) -> [ListenItem] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        dateFormatter.dateFormat = "yyyy-MM-dd"

        var items = [ListenItem]()
        do {
          let jsons = try decoder.decode([ListenJson].self, from: data)
          for json in jsons {
            print("Decoded: \(json)")
            items.append(
              ListenItem(
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
                artist: json.artist ?? "",
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

    func parseType(_ format: String) -> ListenType {
        switch format {
        case "song": return .song
        case "album": return .album
        case "podcast": return .podcast
        case "other": return .other
        default:
            print("Unknown format: \(format)")
            return .other
        }
    }

    func parseDate(_ when: String?) -> Date? {
        if when == nil { return nil }
        return dateFormatter.date(from: when!)
    }
}
