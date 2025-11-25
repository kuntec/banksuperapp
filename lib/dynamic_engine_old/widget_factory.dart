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
      default:
        return Text('Unknown field type: $type');
    }
  }

  static Widget _buildTextField(
      Map<String, dynamic> field, DynamicContextStore ctx) {
    final controller = TextEditingController();
    final name = field['name']?.toString() ?? '';
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
