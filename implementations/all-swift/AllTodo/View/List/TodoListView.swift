import SwiftUI

struct TodoRow: View {
    let item: TodoItem
    let onToggleDone: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: () -> Void

    var body: some View {
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
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)

            Image(systemName: "line.3.horizontal")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named("todo-list"))
                        .onChanged(onDragChanged)
                        .onEnded { _ in onDragEnded() }
                )
                .accessibilityLabel("並び替え")

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

private struct TodoRowFramePreferenceKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct TodoListView: View {
    let repository: any TodoRepository

    @State private var viewModel: TodoListViewModel?
    @State private var navigateToAdd = false
    @State private var editTargetId: String?
    @State private var draggedItemId: String?
    @State private var dragStartMidY: CGFloat?
    @State private var didReorderDuringDrag = false
    @State private var rowFrames: [String: CGRect] = [:]

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
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel?.onAddClick()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $navigateToAdd) {
            TodoEditView(repository: repository, todoId: nil)
        }
        .navigationDestination(item: $editTargetId) { id in
            TodoEditView(repository: repository, todoId: id)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TodoListViewModel(repository: repository)
            }
        }
        .onChange(of: viewModel?.event) { _, newValue in
            guard let event = newValue else { return }
            switch event {
            case .navigateToAdd:
                navigateToAdd = true
            case .navigateToEdit(let id):
                editTargetId = id
            }
            viewModel?.clearEvent()
        }
    }

    @ViewBuilder
    private func listContent(viewModel: TodoListViewModel) -> some View {
        let uiState = viewModel.uiState
        if uiState.isLoading {
            ProgressView()
        } else if uiState.items.isEmpty {
            ContentUnavailableView(
                "TODOがありません",
                systemImage: "checklist",
                description: Text("右上の＋ボタンからTODOを追加しましょう")
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(uiState.items, id: \.id) { item in
                        TodoRow(
                            item: item,
                            onToggleDone: { viewModel.onToggleDone(id: item.id) },
                            onDelete: { viewModel.onDeleteRequest(id: item.id) },
                            onTap: { viewModel.onItemClick(id: item.id) },
                            onDragChanged: { value in
                                handleDragChanged(item: item, value: value, viewModel: viewModel)
                            },
                            onDragEnded: {
                                handleDragEnded(viewModel: viewModel)
                            }
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                        .opacity(draggedItemId == item.id ? 0.5 : 1)
                        .overlay {
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: TodoRowFramePreferenceKey.self,
                                    value: [item.id: proxy.frame(in: .named("todo-list"))]
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .coordinateSpace(name: "todo-list")
            .onPreferenceChange(TodoRowFramePreferenceKey.self) { rowFrames = $0 }
            .animation(.default, value: uiState.items.map(\.id))
            .deleteConfirmDialog(
                title: uiState.deleteConfirmation.target?.title,
                isPresented: Binding(
                    get: { uiState.deleteConfirmation.target != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.onDeleteCancel()
                        }
                    }
                ),
                onConfirm: { viewModel.onDeleteConfirm() },
                onCancel: { viewModel.onDeleteCancel() }
            )
        }
    }

    private func handleDragChanged(item: TodoItem, value: DragGesture.Value, viewModel: TodoListViewModel) {
        if draggedItemId != item.id {
            draggedItemId = item.id
            dragStartMidY = rowFrames[item.id]?.midY
            didReorderDuringDrag = false
        } else if dragStartMidY == nil {
            dragStartMidY = rowFrames[item.id]?.midY
        }

        guard let draggedItemId,
              let startMidY = dragStartMidY,
              let fromIndex = viewModel.uiState.items.firstIndex(where: { $0.id == draggedItemId })
        else { return }

        let currentY = startMidY + value.translation.height
        let destination = viewModel.uiState.items
            .compactMap { todo -> (item: TodoItem, distance: CGFloat)? in
                guard let frame = rowFrames[todo.id] else { return nil }
                return (todo, abs(frame.midY - currentY))
            }
            .min { $0.distance < $1.distance }?
            .item

        guard let destination,
              destination.id != draggedItemId,
              let toIndex = viewModel.uiState.items.firstIndex(where: { $0.id == destination.id })
        else { return }

        viewModel.onMoveItem(fromIndex: fromIndex, toIndex: toIndex)
        didReorderDuringDrag = true
    }

    private func handleDragEnded(viewModel: TodoListViewModel) {
        guard draggedItemId != nil else { return }
        let shouldSave = didReorderDuringDrag
        draggedItemId = nil
        dragStartMidY = nil
        didReorderDuringDrag = false
        if shouldSave {
            viewModel.onReorderComplete()
        }
    }
}
