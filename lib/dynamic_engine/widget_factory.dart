import 'package:flutter/material.dart';
import 'package:superbankapp/dynamic_engine/action_engine.dart';
import 'package:superbankapp/dynamic_engine/context_store.dart';
import 'package:superbankapp/dynamic_engine/navigation_engine.dart';

class WidgetFactory {
  static Widget buildField(
      Map<String, dynamic> field, DynamicContextStore ctx) {
    final type = field['type'];
    switch (type) {
      case 'text':
        return _buildTextField(field, ctx);
      case 'pin':
        return _buildPinField(field, ctx);
      case 'textview':
        return _buildTextView(field, ctx);
      case 'dropdown':
        return _buildDropdown(field, ctx);
      default:
        return Text('Unknown field type: $type');
    }
  }

  static Widget _buildDropdown(
      Map<String, dynamic> field, DynamicContextStore ctx) {
    final name = field['name']?.toString() ??
        ''; // where selected value will be stored in ctx
    final label = field['label']?.toString() ?? '';

    // Support BOTH:
    // A) static items: "items": [{"label":"Wallet","value":"wallet"}, ...]
    // B) context items: "items_key": "accounts"  (ctx.getValue("accounts") returns List<Map>)
    List<Map<String, dynamic>> items = [];

    if (field['items'] is List) {
      items = List<Map<String, dynamic>>.from(field['items']);
    } else if (field['items_key'] != null) {
      final list = ctx.getValue(field['items_key']!.toString());
      if (list is List) {
        items = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }

    final itemLabelKey = field['item_label_key']?.toString() ?? 'label';
    final itemValueKey = field['item_value_key']?.toString() ?? 'value';

    final selected = ctx.getValue(name); // current selected value (can be null)

    return DropdownButtonFormField<dynamic>(
      value: selected,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<dynamic>(
          value: item[itemValueKey],
          child: Text((item[itemLabelKey] ?? '').toString()),
        );
      }).toList(),
      onChanged: (value) {
        ctx.setValue(name, value);
      },
    );
  }

  static Widget _buildTextField(
      Map<String, dynamic> field, DynamicContextStore ctx) {
    final controller = TextEditingController();
    final name = field['name']?.toString() ?? '';
    //key value pair for the each text editing controller for each text field.
    controller.addListener(() {
      ctx.setValue(name, controller.text);
    });
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field['label']?.toString(),
        hintText: field['placeholder']?.toString(),
        border: const OutlineInputBorder(),
      ),
    );
  }

  static Widget _buildPinField(
      Map<String, dynamic> field, DynamicContextStore ctx) {
    final controller = TextEditingController();
    final name = field['name']?.toString() ?? '';

    controller.addListener(() {
      ctx.setValue(name, controller.text);
    });

    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: field['label']?.toString(),
        border: const OutlineInputBorder(),
      ),
    );
  }

  static Widget _buildTextView(
      Map<String, dynamic> field, DynamicContextStore ctx) {
    final valueKey = field['value_key']?.toString();
    final value = valueKey != null ? ctx.getValue(valueKey) : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(field['label']?.toString() ?? ''),
        Text(value?.toString() ?? ''),
      ],
    );
  }

  static Widget buildAction(
      Map<String, dynamic> action, DynamicNavigationEngine nav) {
    return ElevatedButton(
      onPressed: () => DynamicActionEngine.handle(action, nav),
      child: Text(action['label']?.toString() ?? 'Button'),
    );
  }
}
