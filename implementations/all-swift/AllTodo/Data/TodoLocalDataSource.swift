import Foundation
import SwiftData

@MainActor
protocol TodoLocalDataSource {
    func fetchAll() throws -> [TodoItem]
    func getMaxSortOrder() throws -> Int?
    func getById(_ id: String) throws -> TodoItem?
    func insert(_ item: TodoItem) throws
    func update(_ item: TodoItem) throws
    func delete(id: String) throws
    func updateSortOrders(_ orders: [String: Int]) throws
}

@MainActor
final class SwiftDataTodoLocalDataSource: TodoLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoEntity>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func getMaxSortOrder() throws -> Int? {
        let descriptor = FetchDescriptor<TodoEntity>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        var limited = descriptor
        limited.fetchLimit = 1
        return try modelContext.fetch(limited).first?.sortOrder
    }

    func getById(_ id: String) throws -> TodoItem? {
        try getEntityById(id)?.toDomain()
    }

    func insert(_ item: TodoItem) throws {
        modelContext.insert(TodoEntity(item: item))
        try modelContext.save()
    }

    func update(_ item: TodoItem) throws {
        guard let entity = try getEntityById(item.id) else { return }
        entity.apply(item)
        try modelContext.save()
    }

    func delete(id: String) throws {
        guard let entity = try getEntityById(id) else { return }
        modelContext.delete(entity)
        try modelContext.save()
    }

    func updateSortOrders(_ orders: [String: Int]) throws {
        let descriptor = FetchDescriptor<TodoEntity>()
        let entities = try modelContext.fetch(descriptor)
        let lookup = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0) })
        for (id, sortOrder) in orders {
            lookup[id]?.sortOrder = sortOrder
        }
        try modelContext.save()
    }

    private func getEntityById(_ id: String) throws -> TodoEntity? {
        let descriptor = FetchDescriptor<TodoEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
}
