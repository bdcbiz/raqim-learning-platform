import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../../../core/theme/app_theme.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({super.key});

  @override
  State<FinancialManagementScreen> createState() => _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              selectedIndex: 4,
              onItemSelected: (index) {
                _navigateToSection(index);
              },
            ),

          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      const SizedBox(width: 16),
                      Text(
                        'الإدارة المالية',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: AppColors.primaryColor,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.receipt_long),
                        text: 'سجل المعاملات',
                      ),
                      Tab(
                        icon: Icon(Icons.verified),
                        text: 'التحقق اليدوي',
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionsTab(),
                      _buildManualVerificationTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: 4,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _navigateToSection(index);
                },
              ),
            )
          : null,
    );
  }

  // Transactions Tab
  Widget _buildTransactionsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Statistics cards
          Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              final transactions = adminProvider.transactions;
              final totalRevenue = transactions.fold<double>(
                0,
                (sum, t) => sum + (t['amount'] ?? 0),
              );
              final completedCount = transactions
                  .where((t) => t['status'] == 'مكتمل')
                  .length;
              final pendingCount = transactions
                  .where((t) => t['status'] == 'معلق')
                  .length;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي الإيرادات',
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'معاملات مكتملة',
                      completedCount.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'معاملات معلقة',
                      pendingCount.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي المعاملات',
                      transactions.length.toString(),
                      Icons.receipt,
                      Colors.purple,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'البحث بالبريد الإلكتروني أو اسم الدورة...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('جميع المعاملات')),
                    DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                    DropdownMenuItem(value: 'pending', child: Text('معلقة')),
                    DropdownMenuItem(value: 'failed', child: Text('فاشلة')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _selectedDateRange,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDateRange = picked;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDateRange == null
                    ? 'تاريخ'
                    : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Transactions table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<AdminProvider>(
                builder: (context, adminProvider, child) {
                  if (adminProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var transactions = adminProvider.transactions;

                  // Apply filters
                  if (_selectedFilter != 'all') {
                    transactions = transactions.where((t) {
                      switch (_selectedFilter) {
                        case 'completed':
                          return t['status'] == 'مكتمل';
                        case 'pending':
                          return t['status'] == 'معلق';
                        case 'failed':
                          return t['status'] == 'فاشل';
                        default:
                          return true;
                      }
                    }).toList();
                  }

                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد معاملات',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('رقم المعاملة')),
                        DataColumn(label: Text('البريد الإلكتروني')),
                        DataColumn(label: Text('اسم الدورة')),
                        DataColumn(label: Text('المبلغ')),
                        DataColumn(label: Text('طريقة الدفع')),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('التاريخ')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows: transactions.map((transaction) {
                        return DataRow(
                          cells: [
                            DataCell(Text(transaction['id'] ?? '')),
                            DataCell(Text(transaction['userEmail'] ?? '')),
                            DataCell(Text(transaction['courseName'] ?? '')),
                            DataCell(Text('\$${transaction['amount'] ?? 0}')),
                            DataCell(Text(transaction['paymentMethod'] ?? '')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(transaction['status']).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  transaction['status'] ?? '',
                                  style: TextStyle(
                                    color: _getStatusColor(transaction['status']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(_formatDate(transaction['createdAt']))),
                            DataCell(
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, size: 20),
                                        SizedBox(width: 8),
                                        Text('عرض التفاصيل'),
                                      ],
                                    ),
                                  ),
                                  if (transaction['status'] == 'معلق')
                                    const PopupMenuItem(
                                      value: 'verify',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check, size: 20, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('تأكيد', style: TextStyle(color: Colors.green)),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'refund',
                                    child: Row(
                                      children: [
                                        Icon(Icons.replay, size: 20, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('استرداد', style: TextStyle(color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'view') {
                                    _showTransactionDetails(transaction);
                                  } else if (value == 'verify') {
                                    _confirmTransaction(transaction);
                                  } else if (value == 'refund') {
                                    _refundTransaction(transaction);
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Manual Verification Tab
  Widget _buildManualVerificationTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التحقق اليدوي من الدفع',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'استخدم هذا النموذج لتأكيد المدفوعات التي تمت عبر التحويل البنكي أو الطرق اليدوية الأخرى',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // User selection
              TextField(
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني للمستخدم',
                  hintText: 'أدخل البريد الإلكتروني',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // Course selection
              TextField(
                decoration: InputDecoration(
                  labelText: 'معرف الدورة',
                  hintText: 'أدخل معرف الدورة',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 16),

              // Payment details
              TextField(
                decoration: InputDecoration(
                  labelText: 'رقم الحوالة (اختياري)',
                  hintText: 'أدخل رقم الحوالة البنكية',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  hintText: 'أضف أي ملاحظات حول هذه المعاملة',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showVerificationConfirmation();
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('تأكيد الدفع ومنح الوصول'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Clear form
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('مسح النموذج'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'معلق':
        return Colors.orange;
      case 'فاشل':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تفاصيل المعاملة #${transaction['id']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('البريد الإلكتروني', transaction['userEmail']),
                _buildDetailRow('اسم الدورة', transaction['courseName']),
                _buildDetailRow('المبلغ', '\$${transaction['amount']}'),
                _buildDetailRow('طريقة الدفع', transaction['paymentMethod']),
                _buildDetailRow('الحالة', transaction['status']),
                _buildDetailRow('التاريخ', _formatDate(transaction['createdAt'])),
                if (transaction['verifiedManually'] == true)
                  _buildDetailRow('التحقق', 'يدوي', color: Colors.orange),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'غير محدد',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد المعاملة'),
          content: Text('هل أنت متأكد من تأكيد المعاملة #${transaction['id']}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تأكيد المعاملة بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _refundTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('استرداد المبلغ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت متأكد من استرداد المبلغ للمعاملة #${transaction['id']}؟'),
              const SizedBox(height: 16),
              Text(
                'المبلغ: \$${transaction['amount']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم استرداد المبلغ بنجاح'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('استرداد'),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد التحقق اليدوي'),
          content: const Text(
            'سيتم منح المستخدم حق الوصول إلى الدورة المحددة. هل أنت متأكد؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call admin provider to verify payment
                context.read<AdminProvider>().verifyManualPayment('userId', 'courseId');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم التحقق من الدفع ومنح الوصول بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/courses');
        break;
      case 2:
        context.go('/admin/users');
        break;
      case 3:
        context.go('/admin/content');
        break;
      case 4:
        // Already on finance
        break;
      case 5:
        context.go('/admin/settings');
        break;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.parse(date);
    } else {
      return 'غير محدد';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}