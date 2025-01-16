import Foundation
import SwiftData

enum SchemaV1 : VersionedSchema {
  static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 1)

  static var models: [any PersistentModel.Type] {
    return [ReadItem.self, WatchItem.self, PlayItem.self]
  }
}

// leaving this here for when we do need schema migration
//enum MigrationPlan: SchemaMigrationPlan {
//    static var schemas: [any VersionedSchema.Type] {
//        [SchemaV0.self, SchemaV1.self]
//    }
//
//    static var stages: [MigrationStage] {
//        [migrateV0toV1]
//    }
//
//    static let migrateV0toV1 = MigrationStage.custom(
//        fromVersion: SchemaV0.self,
//        toVersion: SchemaV1.self,
//        willMigrate: nil,
//        didMigrate: { context in
//            let items = try context.fetch(FetchDescriptor<ReadItem>())
////            for item in items {
////                item.extinct = false
////            }
//            try context.save()
//        }
//    )
//}

enum ModelError: LocalizedError {
    case setup(error: Error)
}

func setupModelContainer(
  for versionedSchema: VersionedSchema.Type = SchemaV1.self, url: URL? = nil
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
      configurations: [config]
    )
//      return try ModelContainer(
//        for: schema,
//        migrationPlan: MigrationPlan.self,
//        configurations: [config]
//      )
  } catch {
    throw ModelError.setup(error: error)
  }
}
