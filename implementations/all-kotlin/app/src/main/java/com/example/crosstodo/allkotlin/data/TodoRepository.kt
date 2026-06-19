package com.example.crosstodo.allkotlin.data

import kotlinx.coroutines.flow.Flow
import java.util.UUID
import javax.inject.Inject

/**
 * Single source of truth for TODO data. The UI layer always goes through the
 * repository (see the architecture guideline in the project spec).
 */
interface TodoRepository {
    fun observeAll(): Flow<List<TodoItem>>
    suspend fun getById(id: String): TodoItem?
    suspend fun add(title: String, memo: String?): TodoItem
    suspend fun update(item: TodoItem)
    suspend fun delete(id: String)
    suspend fun toggleDone(id: String)
    suspend fun reorder(orderedIds: List<String>)
}

class DefaultTodoRepository @Inject constructor(
    private val localDataSource: TodoLocalDataSource,
) : TodoRepository {

    override fun observeAll(): Flow<List<TodoItem>> = localDataSource.observeAll()

    override suspend fun getById(id: String): TodoItem? = localDataSource.getById(id)

    override suspend fun add(title: String, memo: String?): TodoItem {
        val now = System.currentTimeMillis()
        val nextSortOrder = (localDataSource.getMaxSortOrder() ?: -1) + 1
        val item = TodoItem(
            id = UUID.randomUUID().toString(),
            title = title.trim(),
            memo = memo?.trim()?.takeUnless { it.isEmpty() },
            isDone = false,
            sortOrder = nextSortOrder,
            createdAt = now,
            updatedAt = now,
        )
        localDataSource.insert(item)
        return item
    }

    override suspend fun update(item: TodoItem) {
        val normalized = item.copy(
            title = item.title.trim(),
            memo = item.memo?.trim()?.takeUnless { it.isEmpty() },
        )
        localDataSource.update(normalized)
    }

    override suspend fun delete(id: String) = localDataSource.delete(id)

    override suspend fun toggleDone(id: String) {
        val current = localDataSource.getById(id) ?: return
        localDataSource.update(
            current.copy(
                isDone = !current.isDone,
                updatedAt = System.currentTimeMillis(),
            ),
        )
    }

    override suspend fun reorder(orderedIds: List<String>) {
        val orders = orderedIds.withIndex().associate { (index, id) -> id to index }
        localDataSource.updateSortOrders(orders)
    }
}
