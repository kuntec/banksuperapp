class PluginException implements Exception {
  final String message;
  PluginException(this.message);

  @override
  String toString() => 'PluginException: $message';
}
