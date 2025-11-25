// import 'package:flutter/material.dart';
//
// import '../constants/action_types.dart';
// import 'navigation_engine.dart';
// import 'api_engine.dart';
//
// class DynamicActionEngine {
//   static Future<void> handle(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final type = action['type']?.toString();
//
//     switch (type) {
//       case ActionTypes.navigate:
//         await _handleNavigate(action, nav);
//         break;
//       case ActionTypes.apiCall:
//         await _handleApiCall(action, nav, context);
//         break;
//       case ActionTypes.actionSequence:
//         await _handleActionSequence(action, nav, context);
//         break;
//       case ActionTypes.snackbar:
//         _handleSnackbar(action, context);
//         break;
//       case ActionTypes.dialog:
//         await _handleDialog(action, context);
//         break;
//       case ActionTypes.ifAction:
//         await _handleIf(action, nav, context);
//         break;
//       case ActionTypes.switchAction:
//         await _handleSwitch(action, nav, context);
//         break;
//       case ActionTypes.parallel:
//         await _handleParallel(action, nav, context);
//         break;
//       default:
//         break;
//     }
//   }
//
//   static Future<void> _handleNavigate(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//   ) async {
//     final target = action['target']?.toString();
//     if (target == null) return;
//
//     final rawParams = action['params'] as Map<String, dynamic>? ?? {};
//     final resolvedParams = <String, dynamic>{};
//
//     rawParams.forEach((key, value) {
//       if (value is String) {
//         final fromCtx = nav.contextStore.getValue(value);
//         resolvedParams[key] = fromCtx ?? value;
//       } else {
//         resolvedParams[key] = value;
//       }
//     });
//
//     nav.navigateTo(target, params: resolvedParams);
//   }
//
//   static Future<void> _handleApiCall(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final apiId = action['api_id']?.toString();
//     if (apiId == null) return;
//     await DynamicApiEngine.executeApiById(apiId, nav, context);
//   }
//
//   static Future<void> _handleActionSequence(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final steps = action['steps'] as List<dynamic>? ?? [];
//     for (final s in steps) {
//       await handle(s as Map<String, dynamic>, nav, context);
//     }
//   }
//
//   static void _handleSnackbar(
//     Map<String, dynamic> action,
//     BuildContext context,
//   ) {
//     final msg = action['message']?.toString() ?? '';
//     if (msg.isEmpty) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
//
//   static Future<void> _handleDialog(
//     Map<String, dynamic> action,
//     BuildContext context,
//   ) async {
//     final msg = action['message']?.toString() ?? '';
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Notice'),
//         content: Text(msg),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static Future<void> _handleIf(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final condition = action['condition'] as Map<String, dynamic>?;
//
//     if (condition == null) return;
//
//     final boolResult = _evaluateCondition(condition, nav);
//
//     if (boolResult) {
//       final thenAction = action['then'] as Map<String, dynamic>?;
//       if (thenAction != null) {
//         await handle(thenAction, nav, context);
//       }
//     } else {
//       final elseAction = action['else'] as Map<String, dynamic>?;
//       if (elseAction != null) {
//         await handle(elseAction, nav, context);
//       }
//     }
//   }
//
//   static bool _evaluateCondition(
//     Map<String, dynamic> condition,
//     DynamicNavigationEngine nav,
//   ) {
//     final leftRaw = condition['left'];
//     final op = condition['op']?.toString() ?? '==';
//     final rightRaw = condition['right'];
//
//     final left = _resolveValue(leftRaw, nav);
//     final right = _resolveValue(rightRaw, nav);
//
//     final leftNum = num.tryParse(left.toString());
//     final rightNum = num.tryParse(right.toString());
//
//     if (leftNum != null && rightNum != null) {
//       switch (op) {
//         case '>':
//           return leftNum > rightNum;
//         case '<':
//           return leftNum < rightNum;
//         case '>=':
//           return leftNum >= rightNum;
//         case '<=':
//           return leftNum <= rightNum;
//         case '!=':
//           return leftNum != rightNum;
//         case '==':
//         default:
//           return leftNum == rightNum;
//       }
//     }
//
//     final ls = left?.toString() ?? '';
//     final rs = right?.toString() ?? '';
//
//     switch (op) {
//       case '!=':
//         return ls != rs;
//       case '==':
//       default:
//         return ls == rs;
//     }
//   }
//
//   static dynamic _resolveValue(
//     dynamic raw,
//     DynamicNavigationEngine nav,
//   ) {
//     if (raw is String) {
//       final ctxValue = nav.contextStore.getValue(raw);
//       return ctxValue ?? raw;
//     }
//     return raw;
//   }
//
//   static Future<void> _handleSwitch(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final valueRaw = action['value'];
//     final value = _resolveValue(valueRaw, nav)?.toString() ?? '';
//
//     final cases = action['cases'] as List<dynamic>? ?? [];
//     for (final c in cases) {
//       final caseMap = c as Map<String, dynamic>;
//       final equals = caseMap['equals']?.toString() ?? '';
//       if (equals == value) {
//         final caseAction = caseMap['action'] as Map<String, dynamic>?;
//         if (caseAction != null) {
//           await handle(caseAction, nav, context);
//         }
//         return;
//       }
//     }
//
//     final defaultAction = action['default'] as Map<String, dynamic>?;
//     if (defaultAction != null) {
//       await handle(defaultAction, nav, context);
//     }
//   }
//
//   static Future<void> _handleParallel(
//     Map<String, dynamic> action,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) async {
//     final tasks = action['tasks'] as List<dynamic>? ?? [];
//     final futures = <Future<void>>[];
//
//     for (final t in tasks) {
//       futures.add(handle(t as Map<String, dynamic>, nav, context));
//     }
//
//     await Future.wait(futures);
//
//     final thenAction = action['then'] as Map<String, dynamic>?;
//     if (thenAction != null) {
//       await handle(thenAction, nav, context);
//     }
//   }
// }
