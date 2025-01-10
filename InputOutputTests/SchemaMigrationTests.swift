import XCTest
import OSLog
import SwiftData
@testable import InputOutput

// disabled until we need to do a real schema migration
final class SchemaMigrationTests: XCTestCase {
    
//  var url: URL!
//  var container: ModelContainer!
//  var context: ModelContext!
//  
//  override func setUpWithError() throws {
//    self.url = FileManager.default.temporaryDirectory.appending(component: "default.store")
//  }
//  
//  override func tearDownWithError() throws {
//    self.container = nil
//    self.context = nil
//    
//    try FileManager.default.removeItem(at: self.url)
//    try? FileManager.default.removeItem(at: self.url.deletingPathExtension().appendingPathExtension("store-shm"))
//    try? FileManager.default.removeItem(at: self.url.deletingPathExtension().appendingPathExtension("store-wal"))
//  }
//  
//  func testMigrationV0toV1() throws {
//    // 1. Setup V1
//    container = try setupModelContainer(for: SchemaV0.self, url: self.url)
//    context = ModelContext(container)
//    try loadSampleDataSchemaV0(context: context)
//    let itemsV0 = try context.fetch(FetchDescriptor<SchemaV0.ReadItem>())
//    
//    // 2. Migration V1 -> V2
//    container = try setupModelContainer(for: SchemaV1.self, url: self.url)
//    context = ModelContext(container)
//    
//    // 3. Assert: all animals should have extinct==false
//    let items = try context.fetch(FetchDescriptor<SchemaV1.ReadItem>())
//    for item in items {
//      let oldItem = itemsV0.first(where: { $0.id == item.id })!
//      XCTAssert(oldItem.tags.count == item.tags.count, "\(item) failed to migrate tags: \(oldItem.tags).")
//      print("Tags, old: \(oldItem.tags), new: \(item.tags)")
//    }
//  }
//  
//  func loadSampleDataSchemaV0(context: ModelContext) throws {
//    var testReadItems: [SchemaV0.ReadItem] {
//      [
//        SchemaV0.ReadItem(created: .now.addingTimeInterval(-10), tags: ["foo", "bar"], started: .now, recommender: "Some guy", format: .book,
//                    title: "The Cat in the Hat", author: "Dr. Seuss"),
//        SchemaV0.ReadItem(created: .now.addingTimeInterval(-20), link: "https://samskivert.com/", format: .audiobook,
//                    title: "One Flew Over the Cuckoo's Nest", author: "Ken Kesey"),
//        SchemaV0.ReadItem(created: .now.addingTimeInterval(-30), format: .article,
//                    title: "A Brief History of Chickens"),
//        SchemaV0.ReadItem(created: .now.addingTimeInterval(-40), recommender: "Mom", format: .book,
//                    title: "The Great Gatsby", author: "F. Scott Fitzgerald"),
//        SchemaV0.ReadItem(created: .now.addingTimeInterval(-50), started: .now.addingTimeInterval(-20), completed: .now, rating: .good, format: .paper,
//                    title: "Goto Considered Harmful", author: "Edsgar Dijkstra"),
//      ]
//    }
//    for item in testReadItems {
//      context.insert(item)
//    }
//    try context.save()
//  }
}
