import 'package:flutter/material.dart';

/// Password validation criteria results.
class PasswordCriteria {
  final bool hasMin8Chars;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;

  const PasswordCriteria({
    required this.hasMin8Chars,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  bool get isAllSatisfied =>
      hasMin8Chars && hasUppercase && hasLowercase && hasDigit && hasSpecialChar;

  int get metCount {
    int count = 0;
    if (hasMin8Chars) count++;
    if (hasUppercase) count++;
    if (hasLowercase) count++;
    if (hasDigit) count++;
    if (hasSpecialChar) count++;
    return count;
  }
}

enum PasswordStrengthLevel {
  empty("Chưa nhập", Colors.grey, 0.0),
  weak("Yếu", Colors.red, 0.25),
  medium("Trung bình", Colors.orange, 0.5),
  strong("Mạnh", Colors.amber, 0.75),
  veryStrong("Rất mạnh", Colors.green, 1.0);

  final String label;
  final Color color;
  final double ratio;

  const PasswordStrengthLevel(this.label, this.color, this.ratio);
}

class PasswordUtils {
  /// Evaluates the 5 password security criteria for a given password string.
  static PasswordCriteria evaluateCriteria(String password) {
    return PasswordCriteria(
      hasMin8Chars: password.length >= 8,
      hasUppercase: RegExp(r'[A-Z]').hasMatch(password),
      hasLowercase: RegExp(r'[a-z]').hasMatch(password),
      hasDigit: RegExp(r'[0-9]').hasMatch(password),
      hasSpecialChar: RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+]').hasMatch(password),
    );
  }

  /// Calculates the strength level based on criteria met and length.
  static PasswordStrengthLevel calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrengthLevel.empty;

    final criteria = evaluateCriteria(password);
    final count = criteria.metCount;

    if (count <= 2 || password.length < 6) {
      return PasswordStrengthLevel.weak;
    } else if (count == 3 || count == 4) {
      return PasswordStrengthLevel.medium;
    } else if (count == 5 && password.length < 12) {
      return PasswordStrengthLevel.strong;
    } else if (count == 5 && password.length >= 12) {
      return PasswordStrengthLevel.veryStrong;
    } else {
      return PasswordStrengthLevel.strong;
    }
  }
}
