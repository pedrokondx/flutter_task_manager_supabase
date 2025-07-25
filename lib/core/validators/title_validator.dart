class TitleValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }
}
