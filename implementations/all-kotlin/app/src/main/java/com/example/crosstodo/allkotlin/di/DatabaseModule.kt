package com.example.crosstodo.allkotlin.di

import android.content.Context
import androidx.room.Room
import com.example.crosstodo.allkotlin.data.TodoDao
import com.example.crosstodo.allkotlin.data.TodoDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): TodoDatabase =
        Room.databaseBuilder(context, TodoDatabase::class.java, TodoDatabase.DATABASE_NAME)
            .build()

    @Provides
    fun provideTodoDao(database: TodoDatabase): TodoDao = database.todoDao()
}
