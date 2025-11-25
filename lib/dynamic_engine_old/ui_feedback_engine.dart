import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

class UiFeedbackEngine {
  static Future<void> handleFeedback(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final ctx = nav.currentContext;
    if (ctx == null) return;

    final type = action['type'];

    if (type == 'toast') {
      final msg = action['message']?.toString() ?? '';
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
      );
    }

    if (type == 'snackbar') {
      final msg = action['message']?.toString() ?? '';
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
    }

    if (type == 'dialog') {
      final msg = action['message']?.toString() ?? '';
      await showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          title: const Text('Notice'),
          content: Text(msg),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            )
          ],
        ),
      );
    }
  }
}
