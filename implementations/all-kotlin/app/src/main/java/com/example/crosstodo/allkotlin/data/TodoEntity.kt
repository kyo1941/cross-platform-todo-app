package com.example.crosstodo.allkotlin.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Room persistence model. Column names follow the shared SQL schema
 * (snake_case); property names stay camelCase.
 */
@Entity(tableName = "todo_item")
data class TodoEntity(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "title") val title: String,
    @ColumnInfo(name = "memo") val memo: String?,
    @ColumnInfo(name = "is_done") val isDone: Boolean,
    @ColumnInfo(name = "sort_order") val sortOrder: Int,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
)

fun TodoEntity.toDomain(): TodoItem = TodoItem(
    id = id,
    title = title,
    memo = memo,
    isDone = isDone,
    sortOrder = sortOrder,
    createdAt = createdAt,
    updatedAt = updatedAt,
)

fun TodoItem.toEntity(): TodoEntity = TodoEntity(
    id = id,
    title = title,
    memo = memo,
    isDone = isDone,
    sortOrder = sortOrder,
    createdAt = createdAt,
    updatedAt = updatedAt,
)
