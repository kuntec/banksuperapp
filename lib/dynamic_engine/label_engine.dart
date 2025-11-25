import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

/// Simple label engine that copies a value from one context key to another.
/// The widgets that display labels can bind to the target key.
class LabelEngine {
  static void updateLabel(
      Map<String, dynamic> action, DynamicNavigationEngine nav) {
    final target = action['target']?.toString();
    final valueKey = action['value_key']?.toString();

    if (target == null || valueKey == null) return;

    final newValue = nav.contextStore.getValue(valueKey);
    nav.contextStore.setValue(target, newValue);

    nav.notifyScreenRefresh();
  }
}
