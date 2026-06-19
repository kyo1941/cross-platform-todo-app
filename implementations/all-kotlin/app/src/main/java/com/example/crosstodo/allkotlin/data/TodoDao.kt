package com.example.crosstodo.allkotlin.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface TodoDao {

    @Query("SELECT * FROM todo_item ORDER BY sort_order ASC")
    fun observeAll(): Flow<List<TodoEntity>>

    @Query("SELECT * FROM todo_item WHERE id = :id")
    suspend fun getById(id: String): TodoEntity?

    @Insert
    suspend fun insert(entity: TodoEntity)

    @Update
    suspend fun update(entity: TodoEntity)

    @Query("DELETE FROM todo_item WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("UPDATE todo_item SET sort_order = :sortOrder WHERE id = :id")
    suspend fun updateSortOrder(id: String, sortOrder: Int)

    /** Reassigns sort orders for the given items within a single transaction. */
    @Transaction
    suspend fun updateSortOrders(orders: Map<String, Int>) {
        orders.forEach { (id, sortOrder) -> updateSortOrder(id, sortOrder) }
    }
}
