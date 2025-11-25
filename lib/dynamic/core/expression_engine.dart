import '../context/context_store.dart';

class ExpressionEngine {
  static String evaluate(
    String expr,
    DynamicContextStore ctx,
  ) {
    // Example: "customer_name + ' (' + customer_id + ')'"
    final parts = expr.split('+').map((e) => e.trim()).toList();

    String result = '';

    for (final p in parts) {
      if (p.startsWith("'") && p.endsWith("'")) {
        result += p.substring(1, p.length - 1);
      } else {
        final val = ctx.getValue(p);
        if (val != null) {
          result += val.toString();
        }
      }
    }

    return result;
  }
}
