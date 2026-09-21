import Foundation
import SwiftData
import AEVOCore

@Model
final class StoredSnapshot {
    @Attribute(.unique) var key: String
    var payload: Data
    var updatedAt: Date
    init(payload: Data) { key = "current"; self.payload = payload; updatedAt = Date() }
}

@MainActor
final class LocalStore {
    private let container: ModelContainer
    private let context: ModelContext
    private var row: StoredSnapshot?

    init(inMemory: Bool = false) throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        container = try ModelContainer(for: StoredSnapshot.self, configurations: configuration)
        context = ModelContext(container); context.autosaveEnabled = false
        var request = FetchDescriptor<StoredSnapshot>(predicate: #Predicate { $0.key == "current" })
        request.fetchLimit = 1; row = try context.fetch(request).first
    }

    func load() throws -> AppState {
        guard let row else { return AppState() }
        // A decode failure is surfaced. Existing data is never replaced by an empty state.
        return try StateCodec.decode(row.payload)
    }

    func save(_ state: AppState) throws {
        let data = try StateCodec.encode(state)
        let wasNew = row == nil
        if let row { row.payload = data; row.updatedAt = Date() }
        else { let value = StoredSnapshot(payload: data); context.insert(value); row = value }
        do { try context.save() }
        catch { context.rollback(); if wasNew { row = nil }; throw error }
    }
}
