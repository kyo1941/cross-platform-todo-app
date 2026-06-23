import Foundation
import SwiftData

@MainActor
final class TodoRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func getById(_ id: String) throws -> TodoItem? {
        let descriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func getMaxSortOrder() throws -> Int? {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        var limited = descriptor
        limited.fetchLimit = 1
        return try modelContext.fetch(limited).first?.sortOrder
    }

    @discardableResult
    func add(title: String, memo: String?) throws -> TodoItem {
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        let nextSortOrder = (try getMaxSortOrder() ?? -1) + 1
        let trimmedMemo = memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = TodoItem(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            memo: trimmedMemo?.isEmpty == true ? nil : trimmedMemo,
            isDone: false,
            sortOrder: nextSortOrder,
            createdAt: now,
            updatedAt: now
        )
        modelContext.insert(item)
        try modelContext.save()
        return item
    }

    func update(_ item: TodoItem) throws {
        item.title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = item.memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        item.memo = trimmedMemo?.isEmpty == true ? nil : trimmedMemo
        try modelContext.save()
    }

    func toggleDone(id: String) throws {
        guard let item = try getById(id) else { return }
        item.isDone = !item.isDone
        item.updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
        try modelContext.save()
    }

    func delete(id: String) throws {
        guard let item = try getById(id) else { return }
        modelContext.delete(item)
        try modelContext.save()
    }

    func reorder(orderedIds: [String]) throws {
        let allItems = try fetchAll()
        let lookup = Dictionary(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        for (index, id) in orderedIds.enumerated() {
            lookup[id]?.sortOrder = index
        }
        try modelContext.save()
    }
}
