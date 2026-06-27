import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/edit/todo_edit_screen.dart';
import 'ui/list/todo_list_screen.dart';

/// Application root: hosts navigation between the list (S01) and edit (S02)
/// screens via go_router.
class TodoApp extends StatelessWidget {
  TodoApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => TodoListScreen(
          onNavigateToAdd: () => context.push('/edit'),
          onNavigateToEdit: (id) => context.push('/edit/$id'),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => TodoEditScreen(
              todoId: null,
              onNavigateBack: () => context.pop(),
            ),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) => TodoEditScreen(
              todoId: state.pathParameters['id'],
              onNavigateBack: () => context.pop(),
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TODO',
      // Default Material 3 palette, following the system light/dark setting,
      // matching the framework-default theming used by all-kotlin/all-swift.
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      routerConfig: _router,
    );
  }
}
