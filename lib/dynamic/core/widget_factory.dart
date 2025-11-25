// import 'package:flutter/material.dart';
//
// import '../constants/screen_types.dart';
// import '../constants/field_types.dart';
// import 'navigation_engine.dart';
// import '../widgets/dynamic_text_field.dart';
// import '../widgets/dynamic_pin_field.dart';
// import '../widgets/dynamic_textview.dart';
// import '../widgets/dynamic_button.dart';
// import '../widgets/dynamic_list_item.dart';
// import 'expression_engine.dart';
//
// class WidgetFactory {
//   static Widget buildScreenBody(
//     Map<String, dynamic> screenJson,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) {
//     final type = screenJson['type']?.toString() ?? ScreenTypes.form;
//
//     switch (type) {
//       case ScreenTypes.form:
//         return _buildFormScreen(screenJson, nav, context);
//       case ScreenTypes.details:
//         return _buildDetailsScreen(screenJson, nav);
//       case ScreenTypes.list:
//         return _buildListScreen(screenJson, nav, context);
//       default:
//         return Center(child: Text('Unknown screen type: $type'));
//     }
//   }
//
//   static Widget _buildFormScreen(
//     Map<String, dynamic> screen,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) {
//     final fields = screen['fields'] as List<dynamic>? ?? [];
//     final actions = screen['actions'] as List<dynamic>? ?? [];
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           for (final f in fields)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: _buildField(
//                 f as Map<String, dynamic>,
//                 nav,
//                 context,
//               ),
//             ),
//           const SizedBox(height: 24),
//           for (final a in actions)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: DynamicButton.buildActionButton(
//                 a as Map<String, dynamic>,
//                 nav,
//                 context,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   static Widget _buildDetailsScreen(
//     Map<String, dynamic> screen,
//     DynamicNavigationEngine nav,
//   ) {
//     final fields = screen['fields'] as List<dynamic>? ?? [];
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           for (final f in fields)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: _buildField(
//                 f as Map<String, dynamic>,
//                 nav,
//                 null,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   static Widget _buildListScreen(
//     Map<String, dynamic> screen,
//     DynamicNavigationEngine nav,
//     BuildContext context,
//   ) {
//     final listCfg = screen['list_config'] as Map<String, dynamic>? ?? {};
//     final dataKey = listCfg['data_key']?.toString();
//     final itemVar = listCfg['item_var']?.toString() ?? 'item';
//     final itemTemplate = listCfg['item_template'] as List<dynamic>? ?? [];
//
//     final items = nav.contextStore.getValue(dataKey) as List<dynamic>? ?? [];
//
//     // Optional search fields at top (from screen.fields)
//     final searchFields = screen['fields'] as List<dynamic>? ?? [];
//
//     return Column(
//       children: [
//         if (searchFields.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 for (final f in searchFields)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _buildField(
//                       f as Map<String, dynamic>,
//                       nav,
//                       context,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: items.length,
//             itemBuilder: (ctx, index) {
//               final item = items[index];
//               return DynamicListItem.build(
//                 itemTemplate,
//                 item,
//                 itemVar,
//                 nav,
//                 context,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   static Widget _buildField(
//     Map<String, dynamic> field,
//     DynamicNavigationEngine nav,
//     BuildContext? context,
//   ) {
//     final type = field['type']?.toString() ?? FieldTypes.text;
//
//     switch (type) {
//       case FieldTypes.text:
//         return DynamicTextField.build(field, nav, context);
//       case FieldTypes.pin:
//         return DynamicPinField.build(field, nav, context);
//       case FieldTypes.textview:
//         return DynamicTextView.build(field, nav, context);
//       default:
//         return Text('Unknown field type: $type');
//     }
//   }
//
//   // Helper to evaluate expr for textview
//   static String resolveValueExpr(
//     String expr,
//     DynamicNavigationEngine nav,
//   ) {
//     return ExpressionEngine.evaluate(expr, nav.contextStore);
//   }
// }
