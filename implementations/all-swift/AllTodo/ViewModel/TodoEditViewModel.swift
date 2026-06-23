import Foundation

struct TodoEditForm: Equatable {
    var title = ""
    var memo = ""
    var titleError: String?
    var memoError: String?
    var canSave = false
    var isSaving = false
}

enum TodoEditUiState: Equatable {
    case loading
    case add(TodoEditForm)
    case edit(originalItem: TodoItem, form: TodoEditForm)

    var form: TodoEditForm {
        switch self {
        case .loading:
            return TodoEditForm()
        case .add(let form), .edit(_, let form):
            return form
        }
    }

    var title: String { form.title }
    var memo: String { form.memo }
    var titleError: String? { form.titleError }
    var memoError: String? { form.memoError }
    var canSave: Bool { form.canSave }
    var isSaving: Bool { form.isSaving }

    var navigationTitle: String {
        switch self {
        case .add:
            return "TODOを追加"
        case .loading, .edit:
            return "TODOを編集"
        }
    }

    static func edit(originalItem: TodoItem) -> TodoEditUiState {
        .edit(
            originalItem: originalItem,
            form: TodoEditForm(
                title: originalItem.title,
                memo: originalItem.memo ?? "",
                canSave: true
            )
        )
    }

    func updatingForm(_ transform: (inout TodoEditForm) -> Void) -> TodoEditUiState {
        switch self {
        case .loading:
            return self
        case .add(var form):
            transform(&form)
            return .add(form)
        case .edit(let originalItem, var form):
            transform(&form)
            return .edit(originalItem: originalItem, form: form)
        }
    }
}

enum TodoEditEvent: Equatable {
    case navigateBack
}

@MainActor
@Observable
final class TodoEditViewModel {
    static let titleMaxLength = 255
    static let memoMaxLength = 1000
    static let errorTitleRequired = "タイトルを入力してください"
    static let errorTitleTooLong = "タイトルは255文字以内で入力してください"
    static let errorMemoTooLong = "メモは1000文字以内で入力してください"

    var uiState: TodoEditUiState
    var event: TodoEditEvent?

    private let repository: any TodoRepository
    private var titleChangedOnce = false

    init(repository: any TodoRepository, todoId: String?) {
        self.repository = repository
        if let todoId {
            uiState = .loading
            loadItem(id: todoId)
        } else {
            uiState = .add(TodoEditForm())
        }
    }

    func onTitleChange(_ value: String) {
        titleChangedOnce = true
        uiState = uiState.updatingForm { $0.title = value }
        validate()
    }

    func onMemoChange(_ value: String) {
        uiState = uiState.updatingForm { $0.memo = value }
        validate()
    }

    func onSaveClick() {
        let state = uiState
        guard state.canSave, !state.isSaving else { return }
        uiState = uiState.updatingForm {
            $0.isSaving = true
            $0.canSave = false
        }

        let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let memoValue: String? = trimmedMemo.isEmpty ? nil : trimmedMemo

        do {
            switch state {
            case .edit(let originalItem, _):
                var updated = originalItem
                updated.title = trimmedTitle
                updated.memo = memoValue
                updated.updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
                try repository.update(updated)
            case .add:
                try repository.add(title: trimmedTitle, memo: memoValue)
            case .loading:
                return
            }
            event = .navigateBack
        } catch {
            assertionFailure("Failed to save todo: \(error)")
            uiState = uiState.updatingForm { $0.isSaving = false }
            validate()
        }
    }

    func onCancelClick() {
        event = .navigateBack
    }

    func clearEvent() {
        event = nil
    }

    private func loadItem(id: String) {
        do {
            guard let item = try repository.getById(id) else {
                event = .navigateBack
                return
            }
            titleChangedOnce = true
            uiState = .edit(originalItem: item)
        } catch {
            assertionFailure("Failed to load todo: \(error)")
            event = .navigateBack
        }
    }

    private func validate() {
        let trimmedTitleLength = uiState.title.trimmingCharacters(in: .whitespacesAndNewlines).count
        let titleError: String? = if trimmedTitleLength == 0 {
            titleChangedOnce ? Self.errorTitleRequired : nil
        } else if trimmedTitleLength > Self.titleMaxLength {
            Self.errorTitleTooLong
        } else {
            nil
        }
        let memoError = uiState.memo.count > Self.memoMaxLength ? Self.errorMemoTooLong : nil
        let canSave = if case .loading = uiState {
            false
        } else {
            !uiState.isSaving
                && trimmedTitleLength >= 1
                && trimmedTitleLength <= Self.titleMaxLength
                && memoError == nil
        }

        uiState = uiState.updatingForm {
            $0.titleError = titleError
            $0.memoError = memoError
            $0.canSave = canSave
        }
    }
}
