import SwiftUI

struct TodoEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TodoEditViewModel

    let repository: any TodoRepository
    let todoId: String?

    init(repository: any TodoRepository, todoId: String?) {
        self.repository = repository
        self.todoId = todoId
        _viewModel = State(initialValue: TodoEditViewModel(repository: repository, todoId: todoId))
    }

    var body: some View {
        editForm(viewModel: viewModel)
        .navigationTitle(viewModel.uiState.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel.onCancelClick()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("戻る")
                    }
                }
                .disabled(viewModel.uiState.isSaving)
            }
        }
        .onChange(of: viewModel.event) { _, newValue in
            switch newValue {
            case .none:
                break
            case .navigateBack:
                dismiss()
            }
            viewModel.clearEvent()
        }
    }

    @ViewBuilder
    private func editForm(viewModel: TodoEditViewModel) -> some View {
        let uiState = viewModel.uiState
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("タイトル")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField(
                        "タイトル",
                        text: Binding(
                            get: { viewModel.uiState.title },
                            set: { viewModel.onTitleChange($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .disabled(uiState.isSaving)
                    if let error = uiState.titleError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("メモ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField(
                        "メモ",
                        text: Binding(
                            get: { viewModel.uiState.memo },
                            set: { viewModel.onMemoChange($0) }
                        ),
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...10)
                    .disabled(uiState.isSaving)
                    if let error = uiState.memoError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom, 24)

                Button {
                    viewModel.onSaveClick()
                } label: {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!uiState.canSave)
            }
            .padding(16)
        }
    }
}
