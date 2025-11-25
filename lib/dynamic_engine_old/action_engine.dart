import 'package:superbankapp/dynamic_engine/api_engine.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

class DynamicActionEngine {
  static Future<void> handle(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final type = action['type'];
    // print("Type $type");

    // if (type == 'navigate') {
    //   final target = action['target']?.toString();
    //   if (target != null) nav.navigateTo(target);
    // } else if (type == 'api_call') {
    //   await DynamicApiEngine.executeApi(action, nav);
    // }

    if (type == 'navigate') {
      nav.navigateTo(action['target']);
    } else if (type == 'api_call') {
      await DynamicApiEngine.executeApi(action, nav);
    } else if (type == 'action_sequence') {
      await _runActionSequence(action, nav);
    } else if (type == 'toast' || type == 'snackbar' || type == 'dialog') {
      //await UiFeedbackEngine.handleFeedback(action, nav);
    } else if (type == 'label_update') {
      //LabelEngine.updateLabel(action, nav);
    }
  }

  static Future<void> _runActionSequence(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final steps = action['steps'] as List<dynamic>? ?? [];

    for (var step in steps) {
      await handle(step, nav); // recursion handles all step types
    }
  }
}
