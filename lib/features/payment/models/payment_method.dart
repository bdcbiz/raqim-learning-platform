class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String type;
  final bool isDefault;
  final Map<String, dynamic>? details;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isDefault = false,
    this.details,
  });
}

class CreditCard {
  final String cardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String? brand;

  CreditCard({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.brand,
  });

  String get maskedCardNumber {
    if (cardNumber.length >= 12) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }
}

class PaymentTransaction {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime date;
  final String description;
  final String paymentMethod;
  final String? courseId;
  final String? courseName;

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.date,
    required this.description,
    required this.paymentMethod,
    this.courseId,
    this.courseName,
  });
}