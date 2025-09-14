import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailValidationService {
  static final EmailValidationService _instance = EmailValidationService._internal();
  factory EmailValidationService() => _instance;
  EmailValidationService._internal();

  // Basic email regex pattern
  static final RegExp _basicEmailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Common disposable email domains to block
  static final Set<String> _disposableDomains = {
    '10minutemail.com',
    'guerrillamail.com',
    'mailinator.com',
    'tempmail.org',
    'yopmail.com',
    'sharklasers.com',
    'throwaway.email',
    'maildrop.cc',
    'temp-mail.org',
    'dispostable.com',
    'getnada.com',
    '20minutemail.it',
    'fakeinbox.com',
    'armyspy.com',
    'cuvox.de',
    'dayrep.com',
    'einrot.com',
    'fleckens.hu',
    'gustr.com',
    'jourrapide.com',
    'rhyta.com',
    'superrito.com',
    'teleworm.us',
  };

  // Common typos in popular domains
  static final Map<String, String> _domainSuggestions = {
    'gmial.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'gmil.com': 'gmail.com',
    'yahooo.com': 'yahoo.com',
    'yaho.com': 'yahoo.com',
    'outlok.com': 'outlook.com',
    'outloo.com': 'outlook.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.co': 'hotmail.com',
    'iclou.com': 'icloud.com',
    'icoud.com': 'icloud.com',
  };

  /// Validates email format and quality
  /// Returns [EmailValidationResult] with validation details
  Future<EmailValidationResult> validateEmail(String email) async {
    try {
      // Basic format check
      if (!_isValidFormat(email)) {
        return EmailValidationResult(
          isValid: false,
          reason: 'تنسيق البريد الإلكتروني غير صحيح',
          suggestion: null,
        );
      }

      String normalizedEmail = email.toLowerCase().trim();
      String domain = normalizedEmail.split('@')[1];

      // Check for typos and suggest corrections
      if (_domainSuggestions.containsKey(domain)) {
        String suggestedEmail = normalizedEmail.replaceAll(domain, _domainSuggestions[domain]!);
        return EmailValidationResult(
          isValid: false,
          reason: 'يبدو أن هناك خطأ في كتابة النطاق',
          suggestion: suggestedEmail,
        );
      }

      // Check if it's a disposable email
      if (_isDisposableEmail(domain)) {
        return EmailValidationResult(
          isValid: false,
          reason: 'لا يُسمح باستخدام عناوين البريد الإلكتروني المؤقتة',
          suggestion: 'يرجى استخدام بريد إلكتروني دائم مثل Gmail أو Outlook',
        );
      }

      // Enhanced validation using external service (optional)
      bool isRealEmail = await _validateWithExternalService(normalizedEmail);

      if (!isRealEmail) {
        return EmailValidationResult(
          isValid: false,
          reason: 'البريد الإلكتروني غير موجود أو غير صحيح',
          suggestion: 'تأكد من صحة عنوان البريد الإلكتروني',
        );
      }

      return EmailValidationResult(
        isValid: true,
        reason: 'البريد الإلكتروني صحيح',
        suggestion: null,
      );

    } catch (e) {
      print('ERROR EmailValidationService: $e');
      // If external validation fails, use basic validation
      return EmailValidationResult(
        isValid: _isValidFormat(email) && !_isDisposableEmail(email.split('@')[1]),
        reason: _isValidFormat(email) ? 'تم التحقق باستخدام التحقق الأساسي فقط' : 'تنسيق البريد الإلكتروني غير صحيح',
        suggestion: null,
      );
    }
  }

  /// Basic format validation using regex
  bool _isValidFormat(String email) {
    return _basicEmailRegex.hasMatch(email.trim());
  }

  /// Check if the domain is a known disposable email provider
  bool _isDisposableEmail(String domain) {
    return _disposableDomains.contains(domain.toLowerCase());
  }

  /// Validate email using external service (mock implementation)
  /// In production, you might use services like:
  /// - Abstract API Email Validation
  /// - Hunter.io
  /// - ZeroBounce
  /// - EmailListVerify
  Future<bool> _validateWithExternalService(String email) async {
    try {
      // Mock implementation - in production, replace with real API
      // Example using a hypothetical email validation API:

      /*
      final response = await http.get(
        Uri.parse('https://api.example.com/validate?email=$email'),
        headers: {'Authorization': 'Bearer YOUR_API_KEY'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_valid'] == true;
      }
      */

      // For now, we'll do basic MX record simulation
      // In a real implementation, you would check MX records
      return await _simulateMXRecordCheck(email);

    } catch (e) {
      print('WARNING EmailValidationService: External validation failed: $e');
      return true; // Return true to fall back to basic validation
    }
  }

  /// Simulate MX record check (basic domain validation)
  Future<bool> _simulateMXRecordCheck(String email) async {
    try {
      String domain = email.split('@')[1];

      // List of known valid domains
      Set<String> knownValidDomains = {
        'gmail.com',
        'yahoo.com',
        'outlook.com',
        'hotmail.com',
        'icloud.com',
        'aol.com',
        'live.com',
        'msn.com',
        'yandex.com',
        'protonmail.com',
        'mail.com',
        'edu.sa',
        'gov.sa',
      };

      // If it's a known domain, it's valid
      if (knownValidDomains.contains(domain)) {
        return true;
      }

      // For unknown domains, simulate a network check
      // In production, you would actually check MX records
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      // For demonstration, we'll accept most domains but reject obvious fakes
      Set<String> invalidDomains = {
        'fake.com',
        'test.com',
        'example.com',
        'invalid.com',
        'notreal.com',
      };

      return !invalidDomains.contains(domain);

    } catch (e) {
      return true; // If check fails, assume valid
    }
  }

  /// Get email suggestions for common typos
  String? getEmailSuggestion(String email) {
    try {
      if (!email.contains('@')) return null;

      String domain = email.split('@')[1].toLowerCase();
      if (_domainSuggestions.containsKey(domain)) {
        return email.toLowerCase().replaceAll(domain, _domainSuggestions[domain]!);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if email domain is from an educational institution
  bool isEducationalEmail(String email) {
    try {
      String domain = email.toLowerCase().split('@')[1];
      return domain.endsWith('.edu') ||
             domain.endsWith('.edu.sa') ||
             domain.endsWith('.ac.uk') ||
             domain.endsWith('.edu.eg') ||
             domain.endsWith('.edu.jo');
    } catch (e) {
      return false;
    }
  }

  /// Check if email domain is from a government institution
  bool isGovernmentEmail(String email) {
    try {
      String domain = email.toLowerCase().split('@')[1];
      return domain.endsWith('.gov') ||
             domain.endsWith('.gov.sa') ||
             domain.endsWith('.gov.ae') ||
             domain.endsWith('.gov.eg');
    } catch (e) {
      return false;
    }
  }

  /// Normalize email address (lowercase, trim)
  String normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  /// Extract username from email
  String getEmailUsername(String email) {
    try {
      return email.split('@')[0];
    } catch (e) {
      return email;
    }
  }

  /// Extract domain from email
  String getEmailDomain(String email) {
    try {
      return email.split('@')[1];
    } catch (e) {
      return '';
    }
  }
}

/// Result of email validation
class EmailValidationResult {
  final bool isValid;
  final String reason;
  final String? suggestion;

  EmailValidationResult({
    required this.isValid,
    required this.reason,
    this.suggestion,
  });

  @override
  String toString() {
    return 'EmailValidationResult(isValid: $isValid, reason: $reason, suggestion: $suggestion)';
  }
}

/// Email quality score (for future use)
class EmailQualityScore {
  final double score; // 0.0 to 1.0
  final List<String> factors;

  EmailQualityScore({
    required this.score,
    required this.factors,
  });
}