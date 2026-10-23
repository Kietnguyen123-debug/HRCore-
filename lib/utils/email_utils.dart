/// Utility helpers for email masking and validation.
class EmailUtils {
  /// Masks an email address for security UI display.
  /// Example: "john.doe@gmail.com" -> "j***e@gmail.com"
  /// Example: "ab@domain.com" -> "a***b@domain.com"
  static String maskEmail(String? email) {
    if (email == null || email.trim().isEmpty) return "Chưa cập nhật Email";
    final clean = email.trim();
    if (!clean.contains('@')) return clean;

    final parts = clean.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 1) {
      return "${username}***@$domain";
    } else if (username.length == 2) {
      return "${username[0]}***${username[1]}@$domain";
    } else {
      final firstChar = username[0];
      final lastChar = username[username.length - 1];
      return "$firstChar***$lastChar@$domain";
    }
  }

  /// Basic regex email format validation.
  static bool isValidEmail(String email) {
    final clean = email.trim();
    if (clean.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(clean);
  }
}
