import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/payment_provider.dart';

class CreditCardPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const CreditCardPaymentScreen({
    super.key,
    required this.paymentData,
  });

  @override
  State<CreditCardPaymentScreen> createState() => _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState extends State<CreditCardPaymentScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _saveCard = false;
  String _cardBrand = '';

  String _detectCardBrand(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    if (number.startsWith('4')) {
      return 'visa';
    } else if (number.startsWith('5')) {
      return 'mastercard';
    } else if (number.startsWith('3')) {
      return 'amex';
    }
    return '';
  }

  void _handlePayment() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;
      final provider = Provider.of<PaymentProvider>(context, listen: false);

      final success = await provider.processPayment(
        paymentMethodId: widget.paymentData['methodId'],
        amount: widget.paymentData['amount'],
        courseId: widget.paymentData['courseId'],
        courseName: widget.paymentData['courseName'],
        paymentDetails: {
          'cardNumber': values['cardNumber'],
          'cardHolder': values['cardHolder'],
          'expiryMonth': values['expiryMonth'],
          'expiryYear': values['expiryYear'],
          'cvv': values['cvv'],
          'saveCard': _saveCard,
        },
      );

      if (success && mounted) {
        context.go('/payment/success', extra: {
          'amount': widget.paymentData['amount'],
          'courseName': widget.paymentData['courseName'],
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('الدفع بالبطاقة الائتمانية'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          if (paymentProvider.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paymentProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWideScreen ? 48 : 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_cardBrand == 'visa')
                                    const Text(
                                      'VISA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else if (_cardBrand == 'mastercard')
                                    const Text(
                                      'MasterCard',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  const Icon(
                                    Icons.contactless,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                '**** **** **** ****',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'حامل البطاقة',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'YOUR NAME',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تاريخ الانتهاء',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'MM/YY',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'معلومات البطاقة',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FormBuilderTextField(
                          name: 'cardNumber',
                          decoration: InputDecoration(
                            labelText: 'رقم البطاقة',
                            hintText: '1234 5678 9012 3456',
                            prefixIcon: const Icon(Icons.credit_card),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _CardNumberFormatter(),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _cardBrand = _detectCardBrand(value);
                              });
                            }
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'رقم البطاقة مطلوب'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'cardHolder',
                          decoration: InputDecoration(
                            labelText: 'اسم حامل البطاقة',
                            hintText: 'كما هو مكتوب على البطاقة',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'اسم حامل البطاقة مطلوب'),
                            FormBuilderValidators.minLength(3, errorText: 'الاسم قصير جداً'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FormBuilderTextField(
                                      name: 'expiryMonth',
                                      decoration: InputDecoration(
                                        labelText: 'الشهر',
                                        hintText: 'MM',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(errorText: 'مطلوب'),
                                        FormBuilderValidators.numeric(errorText: 'رقم فقط'),
                                        FormBuilderValidators.min(1, errorText: 'غير صحيح'),
                                        FormBuilderValidators.max(12, errorText: 'غير صحيح'),
                                      ]),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FormBuilderTextField(
                                      name: 'expiryYear',
                                      decoration: InputDecoration(
                                        labelText: 'السنة',
                                        hintText: 'YY',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(errorText: 'مطلوب'),
                                        FormBuilderValidators.numeric(errorText: 'رقم فقط'),
                                        FormBuilderValidators.min(24, errorText: 'منتهية'),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'cvv',
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: '123',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(errorText: 'CVV مطلوب'),
                                  FormBuilderValidators.minLength(3, errorText: 'CVV غير صحيح'),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CheckboxListTile(
                          value: _saveCard,
                          onChanged: (value) {
                            setState(() {
                              _saveCard = value ?? false;
                            });
                          },
                          title: const Text('حفظ البطاقة للمشتريات المستقبلية'),
                          subtitle: const Text('معلوماتك آمنة ومشفرة'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.green[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'دفع آمن 100%',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'معلوماتك محمية بتشفير SSL 256-bit',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
          ),
          Container(
            padding: EdgeInsets.all(isWideScreen ? 32 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'المبلغ الإجمالي',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${widget.paymentData['amount'].toStringAsFixed(2)} ر.س',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isWideScreen ? 200 : 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: paymentProvider.isLoading ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: paymentProvider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'ادفع الآن',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}