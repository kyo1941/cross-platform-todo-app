import Foundation

@MainActor
protocol TodoRepository: AnyObject {
    func observeAll() -> AsyncThrowingStream<[TodoItem], Error>
    func fetchAll() throws -> [TodoItem]
    func getById(_ id: String) throws -> TodoItem?
    @discardableResult func add(title: String, memo: String?) throws -> TodoItem
    func update(_ item: TodoItem) throws
    func delete(id: String) throws
    func toggleDone(id: String) throws
    func reorder(orderedIds: [String]) throws
}

@MainActor
final class DefaultTodoRepository: TodoRepository {
    private let localDataSource: TodoLocalDataSource
    private var continuations: [UUID: AsyncThrowingStream<[TodoItem], Error>.Continuation] = [:]

    init(localDataSource: TodoLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func observeAll() -> AsyncThrowingStream<[TodoItem], Error> {
        let (stream, continuation) = AsyncThrowingStream<[TodoItem], Error>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.onTermination = { _ in
            Task { @MainActor [weak self] in
                self?.continuations[id] = nil
            }
        }
        do {
            continuation.yield(try fetchAll())
        } catch {
            continuation.finish(throwing: error)
        }
        return stream
    }

    func fetchAll() throws -> [TodoItem] {
        try localDataSource.fetchAll()
    }

    func getById(_ id: String) throws -> TodoItem? {
        try localDataSource.getById(id)
    }

    @discardableResult
    func add(title: String, memo: String?) throws -> TodoItem {
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        let trimmedMemo = memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = TodoItem(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            memo: trimmedMemo?.isEmpty == true ? nil : trimmedMemo,
            isDone: false,
            sortOrder: (try localDataSource.getMaxSortOrder() ?? -1) + 1,
            createdAt: now,
            updatedAt: now
        )
        try localDataSource.insert(item)
        publishAll()
        return item
    }

    func update(_ item: TodoItem) throws {
        let trimmedMemo = item.memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        var normalized = item
        normalized.title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.memo = trimmedMemo?.isEmpty == true ? nil : trimmedMemo
        try localDataSource.update(normalized)
        publishAll()
    }

    func delete(id: String) throws {
        try localDataSource.delete(id: id)
        publishAll()
    }

    func toggleDone(id: String) throws {
        guard var item = try localDataSource.getById(id) else { return }
        item.isDone.toggle()
        item.updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
        try localDataSource.update(item)
        publishAll()
    }

    func reorder(orderedIds: [String]) throws {
        let orders = Dictionary(uniqueKeysWithValues: orderedIds.enumerated().map { ($0.element, $0.offset) })
        try localDataSource.updateSortOrders(orders)
        publishAll()
    }

    private func publishAll() {
        do {
            let items = try fetchAll()
            continuations.values.forEach { $0.yield(items) }
        } catch {
            continuations.values.forEach { $0.finish(throwing: error) }
            continuations.removeAll()
        }
    }
}
