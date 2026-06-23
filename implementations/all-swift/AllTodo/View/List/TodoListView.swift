import SwiftUI

struct TodoRow: View {
    let item: TodoItem
    let onToggleDone: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Button(action: onToggleDone) {
                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(item.isDone ? .green : .secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.body)
                        .lineLimit(1)
                        .strikethrough(item.isDone)
                        .foregroundStyle(item.isDone ? .secondary : .primary)

                    if let memo = item.memo, !memo.isEmpty {
                        Text(memo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodoListViewModel?
    @State private var navigateToAdd = false
    @State private var editTargetId: String?

    var body: some View {
        Group {
            if let viewModel {
                listContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("TODO")
        .toolbar {
            if let viewModel, !viewModel.items.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    navigateToAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $navigateToAdd) {
            TodoEditView(todoId: nil)
        }
        .navigationDestination(item: $editTargetId) { id in
            TodoEditView(todoId: id)
        }
        .onAppear {
            if viewModel == nil {
                let repo = TodoRepository(modelContext: modelContext)
                viewModel = TodoListViewModel(repository: repo)
            }
            viewModel?.loadItems()
        }
    }

    @ViewBuilder
    private func listContent(viewModel: TodoListViewModel) -> some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.items.isEmpty {
            ContentUnavailableView(
                "TODOがありません",
                systemImage: "checklist",
                description: Text("右上の＋ボタンからTODOを追加しましょう")
            )
        } else {
            List {
                ForEach(viewModel.items, id: \.id) { item in
                    TodoRow(
                        item: item,
                        onToggleDone: { viewModel.onToggleDone(id: item.id) },
                        onDelete: { viewModel.onDeleteRequest(id: item.id) },
                        onTap: { editTargetId = item.id }
                    )
                }
                .onMove { from, to in
                    viewModel.onReorder(fromOffsets: from, toOffset: to)
                }
            }
            .listStyle(.insetGrouped)
            .animation(.default, value: viewModel.items.map(\.id))
            .deleteConfirmDialog(
                title: viewModel.deleteTarget?.title,
                onConfirm: { viewModel.onDeleteConfirm() },
                onCancel: { viewModel.onDeleteCancel() }
            )
        }
    }
}
