import Testing
import Foundation
@testable import InputOutput

struct InputOutputTests {

  var readJson = """
  [{
  "created": 1424296544484,
  "author": "Fisher",
  "type": "book",
  "title": "Getting To Yes",
  "started": "2020-04-09",
  "tags": ["Blink"],
  "completed": "2020-04-09",
  "id": "7nTYY0khJ5a36uE9oJWK"
  },
  {
  "created": 977961600000,
  "author": "Philip K. Dick",
  "rating": "good",
  "link": "https://samskivert.com/reviews/books/2000/12/do-androids-dream-of-electric-sheep-philip-k-dick-3/",
  "started": "2000-12-28",
  "completed": "2000-12-28",
  "type": "book",
  "title": "Do Androids Dream of Electric Sheep?",
  "id": "7pgpkUTkPSE1T4raeMo9"
  }]
  """

    @Test func example() async throws {
        let importer = ReadImporter()
        let items = importer.importItems(readJson.data(using: .utf8)!)
        for item in items {
            print("Decoded: \(item) \(item.created) \(item.title)")
        }
    }
}
