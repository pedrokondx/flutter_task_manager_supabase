bool isValidFileName(String name) {
  final forbidden = RegExp(r'[\/\\\x00-\x1F]');
  if (forbidden.hasMatch(name)) return false;
  if (name.length > 255) return false;
  if (name.contains('..')) return false;
  return true;
}

String sanitizeFileName(String name) {
  var sanitized = name.replaceAll(RegExp(r'[\/\\\x00-\x1F]'), '_');
  if (sanitized.contains('..')) sanitized = sanitized.replaceAll('..', '_');
  if (sanitized.length > 255) sanitized = sanitized.substring(0, 255);
  return sanitized;
}
