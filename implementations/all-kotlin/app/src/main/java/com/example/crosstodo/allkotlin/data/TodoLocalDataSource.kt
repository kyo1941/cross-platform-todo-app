package com.example.crosstodo.allkotlin.data

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

/** Abstraction over the local persistence layer. Works in terms of [TodoItem]. */
interface TodoLocalDataSource {
    fun observeAll(): Flow<List<TodoItem>>
    suspend fun getById(id: String): TodoItem?
    suspend fun insert(item: TodoItem)
    suspend fun update(item: TodoItem)
    suspend fun delete(id: String)
    suspend fun updateSortOrders(orders: Map<String, Int>)
}

/** Room-backed implementation of [TodoLocalDataSource]. */
class RoomTodoLocalDataSource @Inject constructor(
    private val dao: TodoDao,
) : TodoLocalDataSource {

    override fun observeAll(): Flow<List<TodoItem>> =
        dao.observeAll().map { entities -> entities.map { it.toDomain() } }

    override suspend fun getById(id: String): TodoItem? = dao.getById(id)?.toDomain()

    override suspend fun insert(item: TodoItem) = dao.insert(item.toEntity())

    override suspend fun update(item: TodoItem) = dao.update(item.toEntity())

    override suspend fun delete(id: String) = dao.deleteById(id)

    override suspend fun updateSortOrders(orders: Map<String, Int>) =
        dao.updateSortOrders(orders)
}
