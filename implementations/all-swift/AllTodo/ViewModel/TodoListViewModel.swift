import Foundation
import SwiftData
import SwiftUI

/// Presentation-layer state and actions for the TODO list screen.
/// Matches Kotlin's `TodoListViewModel` and `TodoListUiState`.
@MainActor
@Observable
final class TodoListViewModel {

    // MARK: - UI State

    var items: [TodoItem] = []
    var isLoading: Bool = true

    /// ID of the item pending delete confirmation, or `nil` if no dialog is shown.
    var deleteTargetId: String?

    /// The item pending delete confirmation (derived from `deleteTargetId`).
    var deleteTarget: TodoItem? {
        guard let id = deleteTargetId else { return nil }
        return items.first { $0.id == id }
    }

    // MARK: - Dependencies

    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    // MARK: - Data Loading

    func loadItems() {
        do {
            items = try repository.fetchAll()
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    // MARK: - Actions

    func onToggleDone(id: String) {
        do {
            try repository.toggleDone(id: id)
            loadItems()
        } catch {
            // Silently ignore toggle errors
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
            // Silently ignore delete errors
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
            // Reload on error to restore consistent state
            loadItems()
        }
    }
}
