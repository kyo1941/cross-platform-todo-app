import 'package:flutter/material.dart';

/// S03: confirmation dialog shown before deleting a to-do entry.
///
/// [onConfirm] runs only when the user taps "削除"; any other dismissal
/// (cancel button or tapping outside) runs [onDismiss].
Future<void> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required VoidCallback onConfirm,
  required VoidCallback onDismiss,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('削除の確認'),
      content: Text('「$title」を削除しますか？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            '削除',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );

  if (confirmed ?? false) {
    onConfirm();
  } else {
    onDismiss();
  }
}
