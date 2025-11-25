import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

class UiFeedbackEngine {
  static Future<void> handleFeedback(
      Map<String, dynamic> cfg, DynamicNavigationEngine nav) async {
    final type =
        cfg['feedback_type']?.toString() ?? cfg['type']?.toString() ?? '';

    switch (type) {
      case 'snackbar':
        _showSnackbar(cfg, nav);
        break;

      case 'toast':
        _showToast(cfg, nav);
        break;

      case 'dialog':
        await _showDialog(cfg, nav);
        break;
    }
  }

  static String _localized(dynamic obj, {String lang = 'en'}) {
    if (obj == null) return '';
    if (obj is String) return obj;
    if (obj is Map) {
      return obj[lang]?.toString() ?? obj.values.first.toString();
    }
    return obj.toString();
  }

  static void _showSnackbar(
      Map<String, dynamic> cfg, DynamicNavigationEngine nav) {
    final ctx = nav.currentContext;
    if (ctx == null) return;

    final msg = _localized(cfg['message']);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
      ),
    );
  }

  static void _showToast(
      Map<String, dynamic> cfg, DynamicNavigationEngine nav) {
    final ctx = nav.currentContext;
    if (ctx == null) return;

    final msg = _localized(cfg['message']);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
      ),
    );
  }

  static Future<void> _showDialog(
      Map<String, dynamic> cfg, DynamicNavigationEngine nav) async {
    final ctx = nav.currentContext;
    if (ctx == null) return;

    final title = _localized(cfg['title']);
    final message = _localized(cfg['message']);

    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(ctx),
          )
        ],
      ),
    );
  }
}
