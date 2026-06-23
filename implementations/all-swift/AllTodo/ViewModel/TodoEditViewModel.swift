import Foundation
import SwiftData
import SwiftUI

/// Presentation-layer state and actions for the TODO edit/create screen.
/// Matches Kotlin's `TodoEditViewModel` and `TodoEditUiState`.
@MainActor
@Observable
final class TodoEditViewModel {

    // MARK: - Constants

    static let titleMaxLength = 255
    static let memoMaxLength = 1000
    static let errorTitleRequired = "タイトルを入力してください"
    static let errorTitleTooLong = "タイトルは255文字以内で入力してください"
    static let errorMemoTooLong = "メモは1000文字以内で入力してください"

    // MARK: - UI State

    enum Mode {
        case loading
        case add
        case edit(originalItem: TodoItem)
    }

    private(set) var mode: Mode
    var title: String = "" { didSet { onTitleChanged() } }
    var memo: String = "" { didSet { validate() } }
    private(set) var titleError: String?
    private(set) var memoError: String?
    private(set) var canSave: Bool = false
    private(set) var isSaving: Bool = false

    /// Whether save or cancel completed and the view should dismiss.
    var shouldDismiss: Bool = false

    /// Whether the title has been edited at least once (to suppress error on pristine forms).
    private var titleChangedOnce = false

    /// Whether unsaved changes exist (for back-navigation confirmation).
    var hasChanges: Bool {
        switch mode {
        case .loading:
            return false
        case .add:
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || !memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .edit(let original):
            return title != original.title || memo != (original.memo ?? "")
        }
    }

    /// Navigation bar title based on mode.
    var navigationTitle: String {
        switch mode {
        case .loading, .edit:
            return "TODOを編集"
        case .add:
            return "TODOを追加"
        }
    }

    // MARK: - Dependencies

    private let repository: TodoRepository

    // MARK: - Init

    init(repository: TodoRepository, todoId: String?) {
        self.repository = repository
        if let todoId {
            self.mode = .loading
            loadItem(id: todoId)
        } else {
            self.mode = .add
        }
    }

    // MARK: - Data Loading

    private func loadItem(id: String) {
        do {
            guard let item = try repository.getById(id) else {
                // Item was deleted externally — dismiss the screen.
                shouldDismiss = true
                return
            }
            titleChangedOnce = true
            mode = .edit(originalItem: item)
            title = item.title
            memo = item.memo ?? ""
            validate()
        } catch {
            shouldDismiss = true
        }
    }

    // MARK: - Actions

    private func onTitleChanged() {
        titleChangedOnce = true
        validate()
    }

    func onSaveClick() {
        guard canSave, !isSaving else { return }
        isSaving = true
        canSave = false

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let memoValue: String? = trimmedMemo.isEmpty ? nil : trimmedMemo

        do {
            switch mode {
            case .edit(let originalItem):
                originalItem.title = trimmedTitle
                originalItem.memo = memoValue
                originalItem.updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
                try repository.update(originalItem)
            case .add:
                try repository.add(title: trimmedTitle, memo: memoValue)
            case .loading:
                return
            }
            shouldDismiss = true
        } catch {
            isSaving = false
            validate()
        }
    }

    func onCancelClick() {
        shouldDismiss = true
    }

    // MARK: - Validation

    private func validate() {
        let trimmedTitleLength = title.trimmingCharacters(in: .whitespacesAndNewlines).count

        titleError = if trimmedTitleLength == 0 {
            titleChangedOnce ? Self.errorTitleRequired : nil
        } else if trimmedTitleLength > Self.titleMaxLength {
            Self.errorTitleTooLong
        } else {
            nil
        }

        memoError = memo.count > Self.memoMaxLength ? Self.errorMemoTooLong : nil

        if case .loading = mode {
            canSave = false
        } else {
            canSave = !isSaving
                && trimmedTitleLength >= 1
                && trimmedTitleLength <= Self.titleMaxLength
                && memoError == nil
        }
    }
}
