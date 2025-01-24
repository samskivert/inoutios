import Testing
import XCTest
import Foundation
@testable import InputOutput

struct InputOutputTests {

  var journalJson = """
  [{
    "date": "0003-06-23",
    "entries": {
      "1": {
        "text": "Checked out new Mac Java release"
      },
      "2": {
        "text": "Started testing for a new Yohoho! release"
      },
      "3": {
        "text": "Testy testopolis"
      },
      "4": {
        "text": "Got my new iPod; mmm... portable music goodness"
      },
      "5": {
        "text": "Fiddled with various MP3 management software"
      },
      "6": {
        "text": "More testing; strategized about our upcoming transition to open beta"
      },
      "7": {
        "text": "Investigated the poor Poor Carp"
      },
      "8": {
        "text": "Fixed more bugs!"
      },
      "9": {
        "text": "Played a bit more \\"Dark Cloud 2\\""
      }
    },
    "id": "0003-06-23"
  }, {
    "date": "2002-05-30",
    "entries": {
      "1": {
        "text": "Worked on sea lanes (geometry thinky fiddly)"
      },
      "2": {
        "text": "Participated in alpha planning meeting"
      }
    },
    "id": "2002-05-30"
  }, {
    "date": "2002-05-30",
    "entries": {
      "1": {
        "text": "Worked on sea lanes (geometry thinky fiddly)"
      },
      "2": {
        "text": "Participated in alpha planning meeting"
      }
    },
    "id": "2002-05-30"
  }]
  """

  @Test func testJsonImport() async throws {
    let importer = JournalImporter()
    let items = importer.importItems(journalJson.data(using: .utf8)!)
    XCTAssert(items.count > 0, "Parsed no items.")
    XCTAssert(items.count < 3, "Did not skip empty item.")
    for item in items {
      print(item)
      XCTAssert(item.year != 0, "\(item) has empty year.")
      XCTAssert(item.month != 0, "\(item) has empty month.")
      XCTAssert(item.day != 0, "\(item) has empty day.")
      XCTAssert(!item.entries.isEmpty, "\(item) has no entries.")
    }
  }
}
