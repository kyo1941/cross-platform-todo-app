package com.example.crosstodo.allkotlin.di

import com.example.crosstodo.allkotlin.data.DefaultTodoRepository
import com.example.crosstodo.allkotlin.data.RoomTodoLocalDataSource
import com.example.crosstodo.allkotlin.data.TodoLocalDataSource
import com.example.crosstodo.allkotlin.data.TodoRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class DataModule {

    @Binds
    @Singleton
    abstract fun bindTodoLocalDataSource(
        impl: RoomTodoLocalDataSource,
    ): TodoLocalDataSource

    @Binds
    @Singleton
    abstract fun bindTodoRepository(
        impl: DefaultTodoRepository,
    ): TodoRepository
}
