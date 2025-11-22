import 'package:superbankapp/dynamic_engine/api_engine.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

class DynamicActionEngine {
  static Future<void> handle(
      Map<String, dynamic> action, DynamicNavigationEngine nav) async {
    final type = action['type'];
    print("Type $type");
    if (type == 'navigate') {
      final target = action['target']?.toString();
      if (target != null) nav.navigateTo(target);
    } else if (type == 'api_call') {
      await DynamicApiEngine.executeApi(action, nav);
    }
  }
}
