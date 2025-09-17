import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/raqim_app_bar.dart';
import '../providers/payment_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  final double amount;

  const PaymentMethodsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.amount,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String? _selectedMethodId;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    if (provider.paymentMethods.isNotEmpty) {
      _selectedMethodId = provider.paymentMethods
          .firstWhere((m) => m.isDefault, orElse: () => provider.paymentMethods.first)
          .id;
    }
  }

  Widget _getPaymentIcon(String iconType) {
    switch (iconType) {
      case 'credit_card':
        return const Icon(Icons.credit_card, size: 32);
      case 'paypal':
        return const Icon(Icons.payment, size: 32, color: Colors.blue);
      case 'apple_pay':
        return const Icon(Icons.apple, size: 32);
      case 'google_pay':
        return const Icon(Icons.g_mobiledata, size: 32);
      case 'bank_transfer':
        return const Icon(Icons.account_balance, size: 32);
      default:
        return const Icon(Icons.payment, size: 32);
    }
  }

  void _proceedToPayment() {
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار طريقة الدفع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedMethod = Provider.of<PaymentProvider>(context, listen: false)
        .paymentMethods
        .firstWhere((m) => m.id == _selectedMethodId);

    if (selectedMethod.type == 'credit_card') {
      context.go('/payment/credit-card', extra: {
        'courseId': widget.courseId,
        'courseName': widget.courseName,
        'amount': widget.amount,
        'methodId': _selectedMethodId,
      });
    } else {
      context.go('/payment/process', extra: {
        'courseId': widget.courseId,
        'courseName': widget.courseName,
        'amount': widget.amount,
        'methodId': _selectedMethodId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: RaqimAppBar(
        title: AppLocalizations.of(context)?.translate('paymentMethods') ?? 'اختر طريقة الدفع',
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل الشراء',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'دورة تدريبية',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.amount.toStringAsFixed(2)} ر.س',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          'شامل الضريبة',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWideScreen ? 48 : 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'طرق الدفع المتاحة',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...paymentProvider.paymentMethods.map((method) {
                        final isSelected = _selectedMethodId == method.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                ? AppColors.primaryColor 
                                : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMethodId = method.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: method.id,
                                    groupValue: _selectedMethodId,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedMethodId = value;
                                      });
                                    },
                                    activeColor: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 16),
                                  _getPaymentIcon(method.icon),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (method.isDefault) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'موصى به',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (method.type == 'credit_card')
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('MC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.security, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'جميع المعاملات آمنة ومشفرة بتقنية SSL',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(isWideScreen ? 32 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: isWideScreen ? 400 : double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.translate('continueToPayment') ?? 'المتابعة للدفع',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}