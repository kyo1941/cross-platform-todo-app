import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/edit/todo_edit_screen.dart';
import 'ui/list/todo_list_screen.dart';

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
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      routerConfig: _router,
    );
  }
}
