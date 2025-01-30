import Foundation
import SwiftData

enum SchemaV3 : VersionedSchema {
  static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 3)

  static var models: [any PersistentModel.Type] {
    return [JournalItem.self, ReadItem.self, WatchItem.self, PlayItem.self, ListenItem.self]
  }
}

enum SchemaV2 : VersionedSchema {
  static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 2)

  static var models: [any PersistentModel.Type] {
    return [JournalItem.self, SchemaV3.ReadItem.self, SchemaV3.WatchItem.self, SchemaV3.PlayItem.self, SchemaV3.ListenItem.self]
  }
}

enum SchemaV1 : VersionedSchema {
  static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 1)

  static var models: [any PersistentModel.Type] {
    return [JournalItem.self, SchemaV3.ReadItem.self, SchemaV3.WatchItem.self, SchemaV3.PlayItem.self, SchemaV3.ListenItem.self]
  }
}

//// leaving this here for when we do need schema migration
enum MigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] {
    [SchemaV1.self, SchemaV2.self, SchemaV3.self]
  }

  static var stages: [MigrationStage] {
    [migrateV1toV2, migrateV2toV3]
  }

  static let migrateV1toV2 = MigrationStage.custom(
    fromVersion: SchemaV1.self,
    toVersion: SchemaV2.self,
    willMigrate: nil,
    didMigrate: { context in
      let items = try context.fetch(FetchDescriptor<SchemaV2.JournalItem>())
      for item in items {
        print("Populating when and keywords for \(item.year) \(item.month) \(item.day)")
        item.when = toWhen(item.year, item.month, item.day)
        item.keywords = computeKeywords(item.entries)
      }
      try context.save()
    }
  )

  static let migrateV2toV3 = MigrationStage.lightweight(fromVersion: SchemaV2.self, toVersion: SchemaV3.self)
}

enum ModelError: LocalizedError {
    case setup(error: Error)
}

func setupModelContainer(
  for versionedSchema: VersionedSchema.Type = SchemaV3.self, url: URL? = nil
) throws -> ModelContainer {
  do {
    let schema = Schema(versionedSchema: versionedSchema)
    let config = if let url = url {
      ModelConfiguration(schema: schema, url: url)
    } else {
      ModelConfiguration(schema: schema)
    }
    return try ModelContainer(
      for: schema,
      migrationPlan: MigrationPlan.self,
      configurations: [config]
    )
  } catch {
    throw ModelError.setup(error: error)
  }
}

@MainActor
func setupPreviewModelContainer () -> ModelContainer {
  let schema = Schema(versionedSchema: SchemaV3.self)
  let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: schema, configurations: config)
  for item in testJournalItems {
    container.mainContext.insert(item)
  }
  for item in testReadItems {
    container.mainContext.insert(item)
  }
  for item in testWatchItems {
    container.mainContext.insert(item)
  }
  for item in testPlayItems {
    container.mainContext.insert(item)
  }
  for item in testListenItems {
    container.mainContext.insert(item)
  }
  return container
}
