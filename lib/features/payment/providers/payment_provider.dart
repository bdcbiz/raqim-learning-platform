import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../../../services/api/api_service.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/handlers/error_handler.dart';

class PaymentProvider extends ChangeNotifier {
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService.instance;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<PaymentTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PaymentProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _apiService.initialize();
    _initializePaymentMethods();
    await _loadTransactions();
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

  Future<void> _loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ErrorHandler.safeAsyncCall<List<PaymentTransaction>>(
      () async {
        final response = await _apiService.get('/payments/transactions');

        if (response['data'] != null) {
          final transactionData = response['data'] as List;
          return transactionData.map((transactionJson) => _convertApiResponseToTransaction(transactionJson)).toList();
        } else {
          throw const NetworkException('Invalid API response structure', code: 'invalid_response');
        }
      },
      context: 'Loading payment transactions',
      fallbackValue: _generateMockTransactions(),
    );

    _transactions = result ?? _generateMockTransactions();
    _isLoading = false;
    notifyListeners();
  }

  List<PaymentTransaction> _generateMockTransactions() {
    return [
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

  PaymentTransaction _convertApiResponseToTransaction(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'].toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SAR',
      status: json['status'] ?? 'pending',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      paymentMethod: json['payment_method'] ?? 'غير محدد',
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name'] ?? '',
    );
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

    final result = await ErrorHandler.safeAsyncCall<Map<String, dynamic>>(
      () async {
        final response = await _apiService.post('/payments/process', body: {
          'payment_method_id': paymentMethodId,
          'amount': amount,
          'course_id': courseId,
          'course_name': courseName,
          'payment_details': paymentDetails ?? {},
        });

        if (response['status'] == 'success') {
          return response;
        } else {
          throw BusinessLogicException(
            response['message'] ?? 'فشل في معالجة الدفع',
            code: 'payment_failed',
          );
        }
      },
      context: 'Processing payment',
      fallbackValue: null,
    );

    if (result != null) {
      final paymentMethod = _paymentMethods.firstWhere(
        (method) => method.id == paymentMethodId,
        orElse: () => _paymentMethods.first,
      );

      final transaction = PaymentTransaction(
        id: result['data']['transaction_id'] ?? 'TRX${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        currency: 'SAR',
        status: result['data']['status'] ?? 'completed',
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
    } else {
      _error = 'فشل في معالجة الدفع';
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