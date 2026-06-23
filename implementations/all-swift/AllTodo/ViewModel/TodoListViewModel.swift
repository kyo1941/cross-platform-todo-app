import Foundation

enum DeleteConfirmation: Equatable {
    case none
    case pending(TodoItem)

    var target: TodoItem? {
        if case .pending(let item) = self {
            return item
        }
        return nil
    }
}

struct TodoListUiState: Equatable {
    var items: [TodoItem] = []
    var isLoading = true
    var deleteConfirmation: DeleteConfirmation = .none
}

enum TodoListEvent: Equatable {
    case navigateToAdd
    case navigateToEdit(String)
}

@MainActor
@Observable
final class TodoListViewModel {
    var uiState = TodoListUiState()
    var event: TodoListEvent?

    private let repository: any TodoRepository
    private var deleteTargetId: String?

    init(repository: any TodoRepository) {
        self.repository = repository
        observeItems()
    }

    func onToggleDone(id: String) {
        do {
            try repository.toggleDone(id: id)
        } catch {
            assertionFailure("Failed to toggle todo: \(error)")
        }
    }

    func onDeleteRequest(id: String) {
        deleteTargetId = id
        uiState.deleteConfirmation = makeDeleteConfirmation(items: uiState.items)
    }

    func onDeleteConfirm() {
        guard case .pending(let target) = uiState.deleteConfirmation else { return }
        do {
            try repository.delete(id: target.id)
            deleteTargetId = nil
        } catch {
            assertionFailure("Failed to delete todo: \(error)")
        }
    }

    func onDeleteCancel() {
        deleteTargetId = nil
        uiState.deleteConfirmation = .none
    }

    func onMoveItem(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex,
              fromIndex >= 0,
              fromIndex < uiState.items.count,
              toIndex >= 0,
              toIndex < uiState.items.count
        else { return }

        let item = uiState.items.remove(at: fromIndex)
        uiState.items.insert(item, at: toIndex)
        uiState.deleteConfirmation = makeDeleteConfirmation(items: uiState.items)
    }

    func onReorderComplete() {
        do {
            try repository.reorder(orderedIds: uiState.items.map(\.id))
        } catch {
            assertionFailure("Failed to reorder todos: \(error)")
            reloadItems()
        }
    }

    func onAddClick() {
        event = .navigateToAdd
    }

    func onItemClick(id: String) {
        event = .navigateToEdit(id)
    }

    func clearEvent() {
        event = nil
    }

    private func observeItems() {
        Task { @MainActor [weak self, repository] in
            do {
                for try await items in repository.observeAll() {
                    guard let self else { break }
                    uiState.items = items
                    uiState.isLoading = false
                    uiState.deleteConfirmation = makeDeleteConfirmation(items: items)
                }
            } catch {
                guard let self else { return }
                assertionFailure("Failed to observe todos: \(error)")
                uiState.isLoading = false
            }
        }
    }

    private func reloadItems() {
        do {
            let items = try repository.fetchAll()
            uiState.items = items
            uiState.isLoading = false
            uiState.deleteConfirmation = makeDeleteConfirmation(items: items)
        } catch {
            assertionFailure("Failed to load todos: \(error)")
            uiState.isLoading = false
        }
    }

    private func makeDeleteConfirmation(items: [TodoItem]) -> DeleteConfirmation {
        guard let deleteTargetId,
              let target = items.first(where: { $0.id == deleteTargetId })
        else { return .none }
        return .pending(target)
    }
}
