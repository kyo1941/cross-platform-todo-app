package com.example.crosstodo.allkotlin.data

/**
 * Domain model for a single to-do entry. Shared across all implementations
 * (see the data model in the project spec).
 */
data class TodoItem(
    val id: String,
    val title: String,
    val memo: String?,
    val isDone: Boolean,
    val sortOrder: Int,
    val createdAt: Long,
    val updatedAt: Long,
)
