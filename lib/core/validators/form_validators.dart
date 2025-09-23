/// Form validation utilities for the application
class FormValidators {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }

    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  /// Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير';
    }

    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير';
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم';
    }

    // Check for special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص';
    }

    return null;
  }

  /// Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }

    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }

    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    if (value.trim().length > 50) {
      return 'الاسم يجب أن يكون أقل من 50 حرف';
    }

    // Check for valid characters (Arabic, English, spaces)
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على أحرف فقط';
    }

    return null;
  }

  /// Phone number validation (Saudi format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // Remove spaces and special characters
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Saudi phone number patterns
    final saudiMobileRegex = RegExp(r'^((\+966)|0)?5[0-9]{8}$');
    final saudiLandlineRegex = RegExp(r'^((\+966)|0)?1[1-9][0-9]{7}$');

    if (!saudiMobileRegex.hasMatch(cleanPhone) &&
        !saudiLandlineRegex.hasMatch(cleanPhone)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  /// Minimum length validation
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $minLength أحرف على الأقل';
    }

    return null;
  }

  /// Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون أقل من $maxLength حرف';
    }

    return null;
  }

  /// Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقم';
    }

    return null;
  }

  /// Positive number validation
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final numberValidation = validateNumber(value, fieldName: fieldName);
    if (numberValidation != null) return numberValidation;

    final number = double.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقم موجب';
    }

    return null;
  }

  /// URL validation
  static String? validateUrl(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'رابط غير صحيح';
    }

    return null;
  }

  /// Credit card number validation
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم البطاقة مطلوب';
    }

    // Remove spaces and dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if it's all digits
    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'رقم البطاقة يجب أن يحتوي على أرقام فقط';
    }

    // Check length (most cards are 13-19 digits)
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'رقم البطاقة غير صحيح';
    }

    // Luhn algorithm validation
    if (!_isValidCreditCard(cleanNumber)) {
      return 'رقم البطاقة غير صحيح';
    }

    return null;
  }

  /// CVV validation
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV مطلوب';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV يجب أن يكون 3 أو 4 أرقام';
    }

    return null;
  }

  /// Expiry date validation (MM/YY)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'تاريخ الانتهاء مطلوب';
    }

    if (!RegExp(r'^\d{2}\/\d{2}$').hasMatch(value)) {
      return 'تاريخ الانتهاء يجب أن يكون بالصيغة MM/YY';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null || month < 1 || month > 12) {
      return 'تاريخ الانتهاء غير صحيح';
    }

    final now = DateTime.now();
    final expiryDate = DateTime(2000 + year, month);

    if (expiryDate.isBefore(now)) {
      return 'البطاقة منتهية الصلاحية';
    }

    return null;
  }

  /// Custom validation with regex
  static String? validateWithRegex(
    String? value,
    RegExp regex,
    String errorMessage, {
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'هذا الحقل مطلوب' : null;
    }

    if (!regex.hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Luhn algorithm for credit card validation
  static bool _isValidCreditCard(String number) {
    int sum = 0;
    bool isEven = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }
}