import 'package:superbankapp/dynamic_engine/api_engine.dart';
import 'package:superbankapp/dynamic_engine/label_engine.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/dynamic_engine/ui_feedback_engine.dart';

class DynamicActionEngine {
  static Future<void> handle(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final type = action['type']?.toString();

    switch (type) {
      case 'navigate':
        _handleNavigate(action, nav);
        break;

      case 'api_call':
        await _handleApiCall(action, nav);
        break;

      case 'action_sequence':
      case 'sequence':
        await _runActionSequence(action, nav);
        break;

      case 'toast':
      case 'snackbar':
      case 'dialog':
      case 'ui_feedback':
        await UiFeedbackEngine.handleFeedback(action, nav);
        break;

      case 'label_update':
        LabelEngine.updateLabel(action, nav);
        break;

      case 'screen_refresh':
        nav.notifyScreenRefresh();
        break;

      default:
        // Unknown type -> ignore silently for now
        break;
    }
  }

  static void _handleNavigate(
      Map<String, dynamic> action, DynamicNavigationEngine nav) {
    final target =
        action['target_screen_id']?.toString() ?? action['target']?.toString();
    if (target != null && target.isNotEmpty) {
      nav.navigateTo(target);
    }
  }

  static Future<void> _handleApiCall(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    try {
      await DynamicApiEngine.executeApi(action, nav);

      final onSuccess = action['on_success'];
      if (onSuccess is Map<String, dynamic>) {
        await _handlePostAction(onSuccess, nav);
      }
    } catch (e) {
      final onFailure = action['on_failure'];
      if (onFailure is Map<String, dynamic>) {
        await _handlePostAction(onFailure, nav);
      }
      // 🔥 RE-THROW so parent sequence knows this step failed
      throw e;
    }
  }

  static Future<void> _handlePostAction(
      Map<String, dynamic> cfg, DynamicNavigationEngine nav) async {
    final navigateTo = cfg['navigate_to']?.toString();
    if (navigateTo != null && navigateTo.isNotEmpty) {
      nav.navigateTo(navigateTo);
    }

    final uiFeedback = cfg['ui_feedback'];
    if (uiFeedback is Map<String, dynamic>) {
      await UiFeedbackEngine.handleFeedback(uiFeedback, nav);
    }

    final labelUpdates = cfg['label_updates'];
    if (labelUpdates is List) {
      for (final lu in labelUpdates) {
        if (lu is Map<String, dynamic>) {
          LabelEngine.updateLabel(lu, nav);
        }
      }
    }

    if (cfg['screen_refresh'] == true) {
      nav.notifyScreenRefresh();
    }
  }

  static Future<void> _runActionSequence(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final steps = action['steps'] as List<dynamic>? ?? [];

    for (final stepRaw in steps) {
      if (stepRaw is! Map<String, dynamic>) continue;
      final step = Map<String, dynamic>.from(stepRaw);
      try {
        await handle(step, nav);
      } catch (_) {
        // Read stop_sequence from on_failure
        final onFailure = step['on_failure'];
        if (onFailure is Map<String, dynamic>) {
          final stop = onFailure['stop_sequence'] == true;
          if (stop) break;
        }
      }
    }
  }
}
