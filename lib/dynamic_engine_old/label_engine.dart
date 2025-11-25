import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

class LabelEngine {
  static void updateLabel(
      Map<String, dynamic> action, DynamicNavigationEngine nav) {
    final target = action['target'];
    final valueKey = action['value_key'];

    final newValue = nav.contextStore.getValue(valueKey);
    nav.contextStore.setValue(target, newValue);

    nav.notifyScreenRefresh();
  }
}
