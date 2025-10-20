class PlateValidator {
  static final _old = RegExp(r'^[A-Z]{3}\d{3}$');        // ABC123
  static final _new = RegExp(r'^[A-Z]{2}\d{3}[A-Z]{2}$'); // AB123CD
  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  static bool isValid(String input) {
    final p = normalize(input);
    return _old.hasMatch(p) || _new.hasMatch(p);
  }
}