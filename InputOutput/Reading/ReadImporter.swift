//
//  ReadImporter.swift
//  InputOutput
//
//  Created by Michael Bayne on 12/11/24.
//

import Foundation

struct ReadImporter {
    let dateFormatter = DateFormatter()

    func importItems(_ data :Data) -> [ReadItem] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        dateFormatter.dateFormat = "yyyy-MM-dd"

        var items = [ReadItem]()
        do {
          let jsons = try decoder.decode([ReadJson].self, from: data)
          for json in jsons {
              print("Decoded: \(json)")
              items.append(ReadItem(
                id: UUID(),
                created: Date(timeIntervalSince1970: TimeInterval(json.created) / 1000),
                tags: json.tags ?? [],
                link: json.link,
                started: parseDate(json.started),
                completed: parseDate(json.completed),
                rating: parseRating(json.rating),
                recommender: json.recommender,
                format: parseType(json.type),
                title: json.title,
                author: json.author ?? "",
                abandoned: json.abandoned ?? false
              ))
          }
        } catch {
          print("Error decoding JSON: \(error)")
        }
        return items
    }

    func parseRating(_ rating :String?) -> Rating {
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

    func parseType (_ format :String) -> ReadType {
        switch format {
        case "book": return .book
        case "article": return .article
        case "paper": return .paper
        default:
            print("Unknown format: \(format)")
            return .book
        }
    }

    func parseDate (_ when :String?) -> Date? {
        if when == nil { return nil }
        return dateFormatter.date(from: when!)
    }
}
