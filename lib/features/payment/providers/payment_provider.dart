import 'package:flutter/material.dart';
import '../models/payment_method.dart';

class PaymentProvider extends ChangeNotifier {
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<PaymentTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PaymentProvider() {
    _initializePaymentMethods();
    _loadTransactions();
  }

  void _initializePaymentMethods() {
    _paymentMethods = [
      PaymentMethod(
        id: '1',
        name: 'بطاقة ائتمان',
        icon: 'credit_card',
        type: 'credit_card',
        isDefault: true,
      ),
      PaymentMethod(
        id: '2',
        name: 'PayPal',
        icon: 'paypal',
        type: 'paypal',
      ),
      PaymentMethod(
        id: '3',
        name: 'Apple Pay',
        icon: 'apple_pay',
        type: 'apple_pay',
      ),
      PaymentMethod(
        id: '4',
        name: 'Google Pay',
        icon: 'google_pay',
        type: 'google_pay',
      ),
      PaymentMethod(
        id: '5',
        name: 'تحويل بنكي',
        icon: 'bank_transfer',
        type: 'bank_transfer',
      ),
    ];
  }

  void _loadTransactions() {
    _transactions = [
      PaymentTransaction(
        id: 'TRX001',
        amount: 299.99,
        currency: 'SAR',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'شراء دورة تطوير تطبيقات Flutter',
        paymentMethod: 'بطاقة ائتمان',
        courseId: '1',
        courseName: 'تطوير تطبيقات Flutter',
      ),
      PaymentTransaction(
        id: 'TRX002',
        amount: 199.99,
        currency: 'SAR',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'شراء دورة الذكاء الاصطناعي',
        paymentMethod: 'PayPal',
        courseId: '2',
        courseName: 'أساسيات الذكاء الاصطناعي',
      ),
      PaymentTransaction(
        id: 'TRX003',
        amount: 149.99,
        currency: 'SAR',
        status: 'pending',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        description: 'شراء دورة تصميم واجهات المستخدم',
        paymentMethod: 'تحويل بنكي',
        courseId: '3',
        courseName: 'تصميم واجهات المستخدم',
      ),
    ];
  }

  Future<bool> processPayment({
    required String paymentMethodId,
    required double amount,
    required String courseId,
    required String courseName,
    Map<String, dynamic>? paymentDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 3));

      final paymentMethod = _paymentMethods.firstWhere(
        (method) => method.id == paymentMethodId,
        orElse: () => _paymentMethods.first,
      );

      final transaction = PaymentTransaction(
        id: 'TRX${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        currency: 'SAR',
        status: 'completed',
        date: DateTime.now(),
        description: 'شراء دورة $courseName',
        paymentMethod: paymentMethod.name,
        courseId: courseId,
        courseName: courseName,
      );

      _transactions.insert(0, transaction);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ في معالجة الدفع';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}