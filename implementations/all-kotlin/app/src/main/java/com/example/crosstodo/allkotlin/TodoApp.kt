package com.example.crosstodo.allkotlin

import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.crosstodo.allkotlin.presentation.edit.TodoEditViewModel
import com.example.crosstodo.allkotlin.ui.edit.TodoEditScreen
import com.example.crosstodo.allkotlin.ui.list.TodoListScreen

private object Routes {
    const val LIST = "list"
    const val EDIT = "edit"
    const val ARG_TODO_ID = TodoEditViewModel.ARG_TODO_ID
    const val EDIT_WITH_ARG = "$EDIT?$ARG_TODO_ID={$ARG_TODO_ID}"

    fun edit(todoId: String? = null): String =
        if (todoId == null) EDIT else "$EDIT?$ARG_TODO_ID=$todoId"
}

/** Application root composable hosting navigation between the list and edit screens. */
@Composable
fun TodoApp() {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = Routes.LIST) {
        composable(Routes.LIST) {
            TodoListScreen(
                onNavigateToAdd = { navController.navigate(Routes.edit()) },
                onNavigateToEdit = { id -> navController.navigate(Routes.edit(id)) },
            )
        }
        composable(
            route = Routes.EDIT_WITH_ARG,
            arguments = listOf(
                navArgument(Routes.ARG_TODO_ID) {
                    type = NavType.StringType
                    nullable = true
                    defaultValue = null
                },
            ),
        ) {
            TodoEditScreen(onNavigateBack = { navController.popBackStack() })
        }
    }
}
