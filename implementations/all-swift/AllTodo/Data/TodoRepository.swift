import Foundation
import SwiftData

/// Single source of truth for to-do data.
/// The UI layer always goes through the repository.
@MainActor
final class TodoRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Read

    /// Fetches all items ordered by `sortOrder` ascending.
    func fetchAll() throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches a single item by its ID.
    func getById(_ id: String) throws -> TodoItem? {
        let descriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// Returns the maximum `sortOrder` value, or `nil` if no items exist.
    func getMaxSortOrder() throws -> Int? {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        var limited = descriptor
        limited.fetchLimit = 1
        return try modelContext.fetch(limited).first?.sortOrder
    }

    // MARK: - Create

    /// Adds a new to-do item with a trimmed title and optional memo.
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

    // MARK: - Update

    /// Updates an existing item. Title and memo are normalized before persistence.
    func update(_ item: TodoItem) throws {
        item.title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = item.memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        item.memo = trimmedMemo?.isEmpty == true ? nil : trimmedMemo
        try modelContext.save()
    }

    /// Toggles the `isDone` flag on the item with the given ID.
    func toggleDone(id: String) throws {
        guard let item = try getById(id) else { return }
        item.isDone = !item.isDone
        item.updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
        try modelContext.save()
    }

    // MARK: - Delete

    /// Deletes the item with the given ID.
    func delete(id: String) throws {
        guard let item = try getById(id) else { return }
        modelContext.delete(item)
        try modelContext.save()
    }

    // MARK: - Reorder

    /// Reassigns `sortOrder` values based on the given ordered list of IDs.
    /// Index 0 gets sortOrder 0, index 1 gets sortOrder 1, etc.
    func reorder(orderedIds: [String]) throws {
        let allItems = try fetchAll()
        let lookup = Dictionary(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        for (index, id) in orderedIds.enumerated() {
            lookup[id]?.sortOrder = index
        }
        try modelContext.save()
    }
}
