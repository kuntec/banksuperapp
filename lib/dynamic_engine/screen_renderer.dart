import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';
import 'package:superbankapp/dynamic_engine/widget_factory.dart';
import 'package:superbankapp/dynamic_engine/action_engine.dart';

/// Renders a single dynamic screen from JSON using the current navigation engine.
///
/// Supports two schema styles:
///  1) Legacy:   { "type": "form", "fields": [...], "actions": [...] }
///  2) New B2B:  { "type": "form|details|list|status", "widgets": [...], ... }
class DynamicScreenRenderer extends StatelessWidget {
  final Map<String, dynamic> screenJson;
  final DynamicNavigationEngine navigation;

  const DynamicScreenRenderer({
    super.key,
    required this.screenJson,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    // Attach context so feedback engine can show snackbars/dialogs.
    navigation.currentContext = context;

    final type = (screenJson['type'] ?? 'form').toString();

    switch (type) {
      case 'list':
        return _buildListScreen(context);
      case 'details':
      case 'status':
      case 'form':
      default:
        return _buildFormLikeScreen(context);
    }
  }

  /// -----------------------
  /// FORM / DETAILS / STATUS
  /// -----------------------
  Widget _buildFormLikeScreen(BuildContext context) {
    // New schema: "widgets"
    final widgetsJson =
        (screenJson['widgets'] as List<dynamic>?) ?? const <dynamic>[];

    // Legacy schema: "fields" + "actions"
    final fieldsJson =
        (screenJson['fields'] as List<dynamic>?) ?? const <dynamic>[];
    final actionsJson =
        (screenJson['actions'] as List<dynamic>?) ?? const <dynamic>[];

    // Decide what to render:
    final hasWidgets = widgetsJson.isNotEmpty;
    final hasLegacy = fieldsJson.isNotEmpty || actionsJson.isNotEmpty;

    final children = <Widget>[];

    if (hasWidgets) {
      // Enterprise JSON path: widgets drive everything
      for (final w in widgetsJson) {
        if (w is! Map<String, dynamic>) continue;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildWidgetFromConfig(w),
          ),
        );
      }
    } else if (hasLegacy) {
      // Legacy JSON path: fields + actions
      for (final f in fieldsJson) {
        if (f is! Map<String, dynamic>) continue;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WidgetFactory.buildField(f, navigation.contextStore),
          ),
        );
      }

      if (actionsJson.isNotEmpty) {
        children.add(const SizedBox(height: 20));
        for (final a in actionsJson) {
          if (a is! Map<String, dynamic>) continue;
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WidgetFactory.buildAction(a, navigation),
            ),
          );
        }
      }
    } else {
      // Nothing configured – fallback text.
      children.add(const Text('No widgets configured for this screen.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  /// -----------------------
  /// LIST SCREEN
  /// -----------------------
  Widget _buildListScreen(BuildContext context) {
    // New schema for list:
    //  "list_source": "context.accounts",
    //  "item_template": [ { widget config... }, ... ],
    //  "item_tap_action_id": "select_account_from_list"
    final listSourceKey = screenJson['list_source']?.toString();
    final template =
        (screenJson['item_template'] as List<dynamic>?) ?? const <dynamic>[];
    final tapActionId = screenJson['item_tap_action_id']?.toString();

    final rawItems = listSourceKey != null
        ? navigation.contextStore.getValue(listSourceKey)
        : null;

    final items = (rawItems is List) ? rawItems : const [];

    if (items.isEmpty) {
      return const Center(child: Text('No data found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (ctx, index) {
        final item = items[index];

        final rowChildren = <Widget>[];
        for (final t in template) {
          if (t is! Map<String, dynamic>) continue;
          rowChildren.add(
            Expanded(
              child: _buildListItemWidget(t, item),
            ),
          );
        }

        final tile = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowChildren,
        );

        if (tapActionId == null || tapActionId.isEmpty) {
          return tile;
        }

        // Build an action map that updates "item.*" bindings in context
        // and then runs the real action referenced by id.
        return InkWell(
          onTap: () async {
            // Expose current item in context as "item"
            navigation.contextStore.setValue('item', item);

            final action = _findActionById(tapActionId);
            if (action != null) {
              await DynamicActionEngine.handle(action, navigation);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: tile,
          ),
        );
      },
    );
  }

  /// Build a single widget from "widgets" config (new schema).
  Widget _buildWidgetFromConfig(Map<String, dynamic> widgetJson) {
    final type = widgetJson['type']?.toString() ?? 'textview';

    switch (type) {
      case 'text_input':
      case 'text':
        // Map to legacy text field so existing WidgetFactory can render it.
        final legacyField = <String, dynamic>{
          'type': 'text',
          'name': widgetJson['name'],
          'label': _resolveLabel(widgetJson['label']),
          'placeholder': widgetJson['placeholder'],
        };
        return WidgetFactory.buildField(legacyField, navigation.contextStore);

      case 'pin':
        final legacyField = <String, dynamic>{
          'type': 'pin',
          'name': widgetJson['name'],
          'label': _resolveLabel(widgetJson['label']),
        };
        return WidgetFactory.buildField(legacyField, navigation.contextStore);

      case 'textview':
        final legacyField = <String, dynamic>{
          'type': 'textview',
          'label': _resolveLabel(widgetJson['label']),
          // Try both value_binding (new) and value_key (legacy).
          'value_key': widgetJson['value_binding']?.toString() ??
              widgetJson['value_key'],
        };
        return WidgetFactory.buildField(legacyField, navigation.contextStore);

      case 'button':
        final label = _resolveLabel(widgetJson['label']);
        final actionId = widgetJson['on_tap_action_id']?.toString();

        return ElevatedButton(
          onPressed: actionId == null
              ? null
              : () async {
                  final action = _findActionById(actionId);
                  if (action != null) {
                    await DynamicActionEngine.handle(action, navigation);
                  }
                },
          child: Text(label),
        );
      case 'dropdown':
        final legacyField = <String, dynamic>{
          'type': 'dropdown',
          'name': widgetJson['name'], // where selected value will be stored
          'label': _resolveLabel(widgetJson['label']),

          // Support static items OR context-based items
          'items': widgetJson['items'], // static list: [{label,value},...]
          'items_key': widgetJson[
              'items_source'], // context key: e.g. "context.accounts" or "accounts"

          // Optional mapping keys for context items
          'item_label_key': widgetJson['item_label_key'],
          'item_value_key': widgetJson['item_value_key'],
        };
        return WidgetFactory.buildField(legacyField, navigation.contextStore);

      default:
        return Text('Unsupported widget type: $type');
    }
  }

  /// For list item template widgets.
  Widget _buildListItemWidget(
      Map<String, dynamic> widgetJson, dynamic itemData) {
    final type = widgetJson['type']?.toString() ?? 'textview';

    switch (type) {
      case 'textview':
        final label = _resolveLabel(widgetJson['label']);
        final binding = widgetJson['value_binding']?.toString();
        dynamic value;

        if (binding != null && binding.startsWith('item.')) {
          final key = binding.substring(5); // remove "item."
          if (itemData is Map<String, dynamic>) {
            value = itemData[key];
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value?.toString() ?? ''),
          ],
        );

      default:
        // Fallback: try render as normal field with context only.
        return _buildWidgetFromConfig(widgetJson);
    }
  }

  /// Find an action definition in pluginConfig by id (enterprise JSON).
  Map<String, dynamic>? _findActionById(String actionId) {
    final allActions = navigation.pluginConfig['actions'];
    if (allActions is! List) return null;

    for (final raw in allActions) {
      if (raw is! Map<String, dynamic>) continue;
      if (raw['action_id']?.toString() == actionId) {
        return raw;
      }
    }
    return null;
  }

  /// Helper to resolve labels that may be String or { "en": "...", "ar": "..." }.
  String _resolveLabel(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is Map) {
      if (raw['en'] != null) return raw['en'].toString();
      if (raw.isNotEmpty) {
        final first = raw.values.first;
        if (first != null) return first.toString();
      }
    }
    return raw.toString();
  }
}
