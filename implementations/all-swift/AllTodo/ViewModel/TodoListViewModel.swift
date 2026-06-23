import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class TodoListViewModel {

    var items: [TodoItem] = []
    var isLoading: Bool = true
    var deleteTargetId: String?

    var deleteTarget: TodoItem? {
        guard let id = deleteTargetId else { return nil }
        return items.first { $0.id == id }
    }

    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func loadItems() {
        do {
            items = try repository.fetchAll()
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    func onToggleDone(id: String) {
        do {
            try repository.toggleDone(id: id)
            loadItems()
        } catch {
        }
    }

    func onDeleteRequest(id: String) {
        deleteTargetId = id
    }

    func onDeleteConfirm() {
        guard let targetId = deleteTargetId else { return }
        do {
            try repository.delete(id: targetId)
            deleteTargetId = nil
            loadItems()
        } catch {
        }
    }

    func onDeleteCancel() {
        deleteTargetId = nil
    }

    func onReorder(fromOffsets: IndexSet, toOffset: Int) {
        var reordered = items
        reordered.move(fromOffsets: fromOffsets, toOffset: toOffset)
        items = reordered
        do {
            try repository.reorder(orderedIds: reordered.map { $0.id })
        } catch {
            loadItems()
        }
    }
}
