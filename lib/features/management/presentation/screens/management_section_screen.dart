import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/session_service.dart';
import '../../../Shift/screens/PurchaseReceiveScreen.dart';
import '../../../../models/product.dart';
import '../../../../repositories/product_repository.dart';

enum ManagementSection {
  suppliers,
  customers,
  shifts,
  rawMaterials,
  accounting,
  employees,
}

class ManagementSectionScreen extends StatelessWidget {
  const ManagementSectionScreen({super.key, required this.section});

  final ManagementSection section;

  @override
  Widget build(BuildContext context) {
    if (section == ManagementSection.suppliers) {
      return const _ManagementRecordsScreen(type: _RecordType.suppliers);
    }
    if (section == ManagementSection.customers) {
      return const _ManagementRecordsScreen(type: _RecordType.customers);
    }
    if (section == ManagementSection.rawMaterials) {
      return const _ManagementRecordsScreen(type: _RecordType.rawMaterials);
    }
    if (section == ManagementSection.employees) {
      return const _ManagementRecordsScreen(type: _RecordType.employees);
    }
    if (section == ManagementSection.accounting) {
      return const _AccountsScreen();
    }

    final content = _sectionContent(section);

    return Scaffold(
      appBar: AppTopBar(title: content.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.subtitle, style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.space24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 900 ? 3 : 1;
                return GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppDimensions.space16,
                  mainAxisSpacing: AppDimensions.space16,
                  childAspectRatio: columns == 1 ? 4.2 : 2.4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final card in content.cards) _SummaryCard(card: card),
                  ],
                );
              },
            ),
            const SizedBox(height: AppDimensions.space24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(content.icon, color: AppColors.primary),
                      const SizedBox(width: AppDimensions.space12),
                      Text(content.workflowTitle,
                          style: AppTypography.titleLarge),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  for (final step in content.steps) ...[
                    _WorkflowStep(step: step),
                    const SizedBox(height: AppDimensions.space12),
                  ],
                  const SizedBox(height: AppDimensions.space8),
                  FilledButton.icon(
                    onPressed: () => _showComingSoon(context, content.action),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(content.action),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('سيتم فتح نموذج $action بعد تجهيز قاعدة البيانات')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.card});

  final _SummaryData card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(card.icon, color: card.color, size: AppDimensions.iconLg),
          const SizedBox(width: AppDimensions.space12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(card.label, style: AppTypography.bodySmall),
              const SizedBox(height: AppDimensions.space4),
              Text(card.value, style: AppTypography.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({required this.step});

  final String step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
        const SizedBox(width: AppDimensions.space8),
        Text(step, style: AppTypography.bodyMedium),
      ],
    );
  }
}

class _SummaryData {
  const _SummaryData(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _SectionContent {
  const _SectionContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.workflowTitle,
    required this.action,
    required this.cards,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String workflowTitle;
  final String action;
  final List<_SummaryData> cards;
  final List<String> steps;
}

_SectionContent _sectionContent(ManagementSection section) {
  return switch (section) {
    ManagementSection.suppliers => _SectionContent(
        title: 'الموردون',
        subtitle: 'إدارة الموردين وفواتير الشراء والمدفوعات الآجلة.',
        icon: Icons.local_shipping_rounded,
        workflowTitle: 'دورة استلام البضاعة',
        action: 'إضافة مورد',
        cards: [
          _SummaryData('عدد الموردين', '0', Icons.people_alt_outlined,
              AppColors.primary),
          _SummaryData('مستحقات الموردين', '0 ج.م', Icons.credit_card_outlined,
              AppColors.warning),
          _SummaryData('فواتير هذا الشهر', '0', Icons.receipt_long_outlined,
              AppColors.success),
        ],
        steps: [
          'إنشاء بيانات المورد',
          'تسجيل فاتورة شراء نقدي أو آجل',
          'تسجيل السداد وكشف الحساب'
        ],
      ),
    ManagementSection.customers => _SectionContent(
        title: 'العملاء والدليفري',
        subtitle: 'حفظ بيانات العملاء وعناوينهم ومتابعة طلبات التوصيل.',
        icon: Icons.delivery_dining_rounded,
        workflowTitle: 'بيانات عميل الدليفري',
        action: 'إضافة عميل',
        cards: [
          _SummaryData('العملاء', '0', Icons.people_outline, AppColors.primary),
          _SummaryData('عناوين محفوظة', '0', Icons.location_on_outlined,
              AppColors.success),
          _SummaryData('طلبات توصيل اليوم', '0', Icons.delivery_dining_outlined,
              AppColors.warning),
        ],
        steps: [
          'الاسم ورقم الهاتف',
          'أكثر من عنوان مع ملاحظات التوصيل',
          'ربط العميل بالطلب والتحصيل'
        ],
      ),
    ManagementSection.shifts => _SectionContent(
        title: 'الشيفتات والدرج',
        subtitle: 'متابعة مبيعات كل شيفت ومطابقة النقد الموجود في الدرج.',
        icon: Icons.point_of_sale_rounded,
        workflowTitle: 'إقفال الشيفت',
        action: 'فتح شيفت',
        cards: [
          _SummaryData(
              'الشيفت الحالي', 'مغلق', Icons.lock_outline, AppColors.warning),
          _SummaryData(
              'مبيعات اليوم', '0 ج.م', Icons.trending_up, AppColors.success),
          _SummaryData('نقد الدرج المتوقع', '0 ج.م', Icons.payments_outlined,
              AppColors.primary),
        ],
        steps: [
          'تسجيل رصيد بداية الدرج',
          'تجميع المبيعات حسب طريقة الدفع',
          'إدخال النقد الفعلي وتسجيل العجز أو الزيادة'
        ],
      ),
    ManagementSection.rawMaterials => _SectionContent(
        title: 'الخامات والوصفات',
        subtitle: 'إدارة الخامات والوحدات والوصفات وحساب تكلفة الأصناف.',
        icon: Icons.science_rounded,
        workflowTitle: 'حساب تكلفة الصنف',
        action: 'إضافة خامة',
        cards: [
          _SummaryData(
              'الخامات', '0', Icons.inventory_2_outlined, AppColors.primary),
          _SummaryData(
              'وصفات مرتبطة', '0', Icons.menu_book_outlined, AppColors.success),
          _SummaryData('تنبيهات المخزون', '0', Icons.warning_amber_outlined,
              AppColors.warning),
        ],
        steps: [
          'تعريف الخامة ووحدة القياس',
          'ربط الكميات بالوصفة',
          'استهلاك الخامة عند البيع وإعادة حساب الربح'
        ],
      ),
    ManagementSection.accounting => _SectionContent(
        title: 'الحسابات',
        subtitle: 'دليل الحسابات والقيود والحركة النقدية والتقارير المالية.',
        icon: Icons.account_balance_rounded,
        workflowTitle: 'الدورة المحاسبية',
        action: 'إضافة حساب',
        cards: [
          _SummaryData('الحسابات الرئيسية', '0', Icons.account_tree_outlined,
              AppColors.primary),
          _SummaryData('قيود هذا الشهر', '0', Icons.receipt_long_outlined,
              AppColors.success),
          _SummaryData('صافي التدفق النقدي', '0 ج.م', Icons.currency_exchange,
              AppColors.warning),
        ],
        steps: [
          'بناء دليل حسابات هرمي',
          'إنشاء قيد من كل بيع أو شراء أو مصروف',
          'عرض الأرباح والخسائر والتدفق النقدي'
        ],
      ),
    ManagementSection.employees => _SectionContent(
        title: 'الموظفون والرواتب',
        subtitle: 'إدارة الموظفين والرواتب والسلف والمدفوعات المتبقية.',
        icon: Icons.badge_rounded,
        workflowTitle: 'حساب مستحق الموظف',
        action: 'إضافة موظف',
        cards: [
          _SummaryData(
              'الموظفون', '0', Icons.people_outline, AppColors.primary),
          _SummaryData('رواتب الشهر', '0 ج.م', Icons.payments_outlined,
              AppColors.success),
          _SummaryData('سلف مستحقة', '0 ج.م', Icons.request_quote_outlined,
              AppColors.warning),
        ],
        steps: [
          'تسجيل الراتب الأساسي وبيانات الموظف',
          'تسجيل السلف والخصومات',
          'صرف الراتب وإظهار المتبقي وكشف الحساب'
        ],
      ),
  };
}

enum _RecordType { suppliers, customers, rawMaterials, employees }

class _ManagementRecordsScreen extends StatefulWidget {
  const _ManagementRecordsScreen({required this.type});

  final _RecordType type;

  @override
  State<_ManagementRecordsScreen> createState() =>
      _ManagementRecordsScreenState();
}

class _ManagementRecordsScreenState extends State<_ManagementRecordsScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  String get _title => switch (widget.type) {
        _RecordType.suppliers => 'الموردون',
        _RecordType.customers => 'العملاء والدليفري',
        _RecordType.rawMaterials => 'الخامات',
        _RecordType.employees => 'الموظفون والرواتب',
      };

  IconData get _icon => switch (widget.type) {
        _RecordType.suppliers => Icons.local_shipping_outlined,
        _RecordType.customers => Icons.delivery_dining_outlined,
        _RecordType.rawMaterials => Icons.science_outlined,
        _RecordType.employees => Icons.badge_outlined,
      };

  String get _addLabel => switch (widget.type) {
        _RecordType.suppliers => 'إضافة مورد',
        _RecordType.customers => 'إضافة عميل',
        _RecordType.rawMaterials => 'إضافة خامة',
        _RecordType.employees => 'إضافة موظف',
      };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final records = switch (widget.type) {
      _RecordType.suppliers => await db.getSuppliers(),
      _RecordType.customers => await db.getCustomers(),
      _RecordType.rawMaterials => await db.getRawMaterials(),
      _RecordType.employees => await db.getEmployees(),
    };
    if (mounted) {
      setState(() {
        _records = records;
        _loading = false;
      });
    }
  }

  Future<void> _showAddDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _RecordFormDialog(type: widget.type),
    );
    if (saved == true) _load();
  }

  Future<void> _editRawMaterial(Map<String, dynamic> record) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _RecordFormDialog(type: widget.type, record: record),
    );
    if (saved == true) _load();
  }

  Future<void> _hideRawMaterial(Map<String, dynamic> record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إخفاء الخامة'),
        content: Text(
            'هل تريد إخفاء خامة ${record['name']}؟ ستظل محفوظة في الوصفات والحركات السابقة.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('إخفاء')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance
          .setRawMaterialActive(record['id'] as String, false);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: _title),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Text('${_records.length} سجل', style: AppTypography.bodyMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(_addLabel),
                ),
                if (widget.type == _RecordType.rawMaterials) ...[
                  const SizedBox(width: AppDimensions.space8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipesScreen()),
                    ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('الوصفات'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_icon,
                                size: 64, color: AppColors.textDisabled),
                            const SizedBox(height: AppDimensions.space12),
                            Text('لا توجد بيانات بعد',
                                style: AppTypography.titleMedium),
                            const SizedBox(height: AppDimensions.space16),
                            OutlinedButton.icon(
                              onPressed: _showAddDialog,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(_addLabel),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.space24),
                        itemCount: _records.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppDimensions.space10),
                        itemBuilder: (_, index) => _recordTile(_records[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _recordTile(Map<String, dynamic> record) {
    final name = record['name'] as String? ?? 'بدون اسم';
    final subtitle = switch (widget.type) {
      _RecordType.suppliers =>
        '${record['phone'] ?? 'بدون هاتف'} • مستحق: ${record['balance'] ?? 0} ج.م',
      _RecordType.customers =>
        '${record['phone'] ?? ''} • ${record['address'] ?? 'بدون عنوان'}',
      _RecordType.rawMaterials =>
        '${record['unit'] ?? ''} • المخزون: ${record['stock'] ?? 0} • التكلفة: ${record['cost_per_unit'] ?? 0} ج.م',
      _RecordType.employees =>
        '${record['position'] ?? 'بدون وظيفة'} • الراتب: ${record['monthly_salary'] ?? 0} ج.م',
    };

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Icon(_icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: InkWell(
              onTap: widget.type == _RecordType.employees
                  ? () => _showEmployeeStatement(record)
                  : widget.type == _RecordType.customers
                      ? () => _showCustomerHistory(record)
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.titleMedium),
                  const SizedBox(height: AppDimensions.space4),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
          ),
          if (widget.type == _RecordType.employees)
            IconButton(
              tooltip: 'تسجيل حركة مالية',
              onPressed: () => _showEmployeeTransaction(record),
              icon: const Icon(Icons.payments_outlined),
            ),
          if (widget.type == _RecordType.suppliers)
            IconButton(
              tooltip: 'استلام بضاعة',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PurchaseReceiveScreen(),
                ),
              ),
              icon: const Icon(Icons.move_to_inbox_outlined),
            ),
          if (widget.type == _RecordType.rawMaterials) ...[
            IconButton(
              tooltip: 'تعديل الخامة',
              onPressed: () => _editRawMaterial(record),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'حذف الخامة',
              onPressed: () => _hideRawMaterial(record),
              icon: Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showEmployeeTransaction(Map<String, dynamic> employee) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EmployeeTransactionDialog(employee: employee),
    );
    if (saved == true) _load();
  }

  Future<void> _showEmployeeStatement(Map<String, dynamic> employee) async {
    final statement = await DatabaseHelper.instance.getEmployeeMonthlyStatement(
      employee['id'] as String,
    );
    if (!mounted) return;
    final remaining = (statement['remaining'] as num).toDouble();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('كشف حساب ${employee['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الراتب: ${statement['monthly_salary']} ج.م'),
            Text('السلف: ${statement['advances']} ج.م'),
            Text('المدفوع: ${statement['payments']} ج.م'),
            Text('الخصومات: ${statement['deductions']} ج.م'),
            const Divider(),
            Text(
              'المتبقي: ${remaining.toStringAsFixed(2)} ج.م',
              style: AppTypography.titleMedium.copyWith(
                color: remaining < 0 ? AppColors.error : AppColors.success,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomerHistory(Map<String, dynamic> customer) async {
    final orders = await DatabaseHelper.instance.rawQuery(
      '''
      SELECT o.order_number, o.created_at, o.final_amount, o.order_type,
             GROUP_CONCAT(oi.product_name || ' x' || oi.quantity, '، ') AS items
      FROM orders o
      LEFT JOIN order_items oi ON oi.order_id = o.id
      WHERE o.customer_id = ? AND o.status = 'completed'
      GROUP BY o.id
      ORDER BY o.created_at DESC
      ''',
      [customer['id']],
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('مشتريات ${customer['name']}'),
        content: SizedBox(
          width: 520,
          child: orders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(AppDimensions.space16),
                  child: Text('لا توجد مشتريات مسجلة لهذا العميل'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text(
                          '#${order['order_number']} • ${order['order_type'] == 'delivery' ? 'دليفري' : 'تيك أواي'}'),
                      subtitle: Text(
                          '${order['items'] ?? 'بدون أصناف'}\n${order['created_at']}'),
                      isThreeLine: true,
                      trailing: Text('${order['final_amount']} ج.م'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _RecordFormDialog extends StatefulWidget {
  const _RecordFormDialog({required this.type, this.record});

  final _RecordType type;
  final Map<String, dynamic>? record;

  @override
  State<_RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<_RecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _detail = TextEditingController();
  final _amount = TextEditingController(text: '0');
  final _minimum = TextEditingController(text: '0');
  final _initialStock = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record != null) {
      _name.text = record['name'] as String? ?? '';
      _detail.text = record['unit'] as String? ?? '';
      _amount.text = '${record['cost_per_unit'] ?? 0}';
      _minimum.text = '${record['min_stock'] ?? 0}';
      _initialStock.text = '${record['stock'] ?? 0}';
    }
  }

  String get _title => switch (widget.type) {
        _RecordType.suppliers => 'إضافة مورد',
        _RecordType.customers => 'إضافة عميل',
        _RecordType.rawMaterials => 'إضافة خامة',
        _RecordType.employees => 'إضافة موظف',
      };

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _detail.dispose();
    _amount.dispose();
    _minimum.dispose();
    _initialStock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final db = DatabaseHelper.instance;
    final amount = double.tryParse(_amount.text) ?? 0;
    final minimum = double.tryParse(_minimum.text) ?? 0;
    final initialStock = double.tryParse(_initialStock.text) ?? 0;
    switch (widget.type) {
      case _RecordType.suppliers:
        await db.addSupplier(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            address: _detail.text.trim());
      case _RecordType.customers:
        await db.addCustomer(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            address: _detail.text.trim());
      case _RecordType.rawMaterials:
        if (widget.record == null) {
          await db.addRawMaterial(
              name: _name.text.trim(),
              unit: _detail.text.trim().isEmpty ? 'كجم' : _detail.text.trim(),
              costPerUnit: amount,
              minStock: minimum,
              initialStock: initialStock);
        } else {
          await db.updateRawMaterial(
            id: widget.record!['id'] as String,
            name: _name.text.trim(),
            unit: _detail.text.trim().isEmpty ? 'كجم' : _detail.text.trim(),
            costPerUnit: amount,
            minStock: minimum,
            stock: initialStock,
          );
        }
      case _RecordType.employees:
        await db.addEmployee(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            position: _detail.text.trim(),
            monthlySalary: amount);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final detailLabel = switch (widget.type) {
      _RecordType.suppliers => 'العنوان',
      _RecordType.customers => 'العنوان',
      _RecordType.rawMaterials => 'وحدة القياس',
      _RecordType.employees => 'الوظيفة',
    };
    final amountLabel = switch (widget.type) {
      _RecordType.rawMaterials => 'تكلفة الوحدة',
      _RecordType.employees => 'الراتب الشهري',
      _ => null,
    };
    return AlertDialog(
      title: Text(widget.record == null ? _title : 'تعديل خامة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                    validator: (v) => v!.trim().isEmpty ? 'الاسم مطلوب' : null),
                const SizedBox(height: AppDimensions.space16),
                if (widget.type != _RecordType.rawMaterials)
                  TextFormField(
                      controller: _phone,
                      decoration:
                          const InputDecoration(labelText: 'رقم الهاتف'),
                      validator: widget.type == _RecordType.customers
                          ? (v) => v!.trim().isEmpty ? 'رقم الهاتف مطلوب' : null
                          : null),
                if (widget.type != _RecordType.rawMaterials)
                  const SizedBox(height: AppDimensions.space16),
                TextFormField(
                    controller: _detail,
                    decoration: InputDecoration(labelText: detailLabel),
                    validator: widget.type == _RecordType.rawMaterials
                        ? (v) => v!.trim().isEmpty ? 'الوحدة مطلوبة' : null
                        : null),
                const SizedBox(height: AppDimensions.space16),
                if (amountLabel != null)
                  TextFormField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: amountLabel)),
                if (amountLabel != null)
                  const SizedBox(height: AppDimensions.space16),
                if (widget.type == _RecordType.rawMaterials)
                  TextFormField(
                      controller: _initialStock,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'الكمية الحالية / الكمية الابتدائية',
                        helperText: 'اكتب الكمية الموجودة حاليًا من الخامة',
                      )),
                if (widget.type == _RecordType.rawMaterials)
                  const SizedBox(height: AppDimensions.space16),
                if (widget.type == _RecordType.rawMaterials)
                  TextFormField(
                      controller: _minimum,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'الحد الأدنى للمخزون')),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('إلغاء')),
        FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'جاري الحفظ...' : 'حفظ')),
      ],
    );
  }
}

class _EmployeeTransactionDialog extends StatefulWidget {
  const _EmployeeTransactionDialog({required this.employee});

  final Map<String, dynamic> employee;

  @override
  State<_EmployeeTransactionDialog> createState() =>
      _EmployeeTransactionDialogState();
}

class _EmployeeTransactionDialogState
    extends State<_EmployeeTransactionDialog> {
  String _type = 'advance';
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) return;
    await DatabaseHelper.instance.addEmployeeTransaction(
      employeeId: widget.employee['id'] as String,
      type: _type,
      amount: amount,
      notes: _notes.text.trim(),
      userId: SessionService.instance.currentUser?.id,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('حركة مالية - ${widget.employee['name']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: const [
              DropdownMenuItem(value: 'advance', child: Text('سلفة')),
              DropdownMenuItem(
                  value: 'salary_payment', child: Text('صرف راتب')),
              DropdownMenuItem(value: 'bonus', child: Text('مكافأة')),
              DropdownMenuItem(value: 'deduction', child: Text('خصم')),
            ],
            onChanged: (value) => setState(() => _type = value!),
            decoration: const InputDecoration(labelText: 'نوع الحركة'),
          ),
          TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ')),
          TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'ملاحظات')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        FilledButton(onPressed: _save, child: const Text('تسجيل')),
      ],
    );
  }
}

class _AccountsScreen extends StatefulWidget {
  const _AccountsScreen();

  @override
  State<_AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<_AccountsScreen> {
  List<Map<String, dynamic>> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final accounts = await DatabaseHelper.instance.getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _loading = false;
      });
    }
  }

  String _typeLabel(String type) => switch (type) {
        'asset' => 'أصل',
        'liability' => 'التزام',
        'equity' => 'حقوق ملكية',
        'revenue' => 'إيراد',
        'expense' => 'مصروف',
        _ => type,
      };

  List<Map<String, dynamic>> get _orderedAccounts {
    final result = <Map<String, dynamic>>[];
    void addChildren(String? parentId, int level) {
      final children = _accounts
          .where((account) => account['parent_id'] == parentId)
          .toList();
      for (final account in children) {
        result.add({...account, '_level': level});
        addChildren(account['id'] as String, level + 1);
      }
    }

    addChildren(null, 0);
    return result;
  }

  double _sumByType(String type) =>
      _accounts.where((account) => account['type'] == type).fold(0,
          (sum, account) => sum + (account['balance'] as num).toDouble().abs());

  Future<void> _showTransactions(Map<String, dynamic> account) async {
    final rows = await DatabaseHelper.instance.rawQuery(
      '''SELECT created_at, debit, credit, description, ref_type
         FROM account_transactions WHERE account_id = ?
         ORDER BY created_at DESC LIMIT 100''',
      [account['id']],
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('حركات ${account['name']}'),
        content: SizedBox(
          width: 620,
          height: 460,
          child: rows.isEmpty
              ? const Center(child: Text('لا توجد حركات على هذا الحساب'))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final row = rows[index];
                    final debit = (row['debit'] as num).toDouble();
                    final credit = (row['credit'] as num).toDouble();
                    return ListTile(
                      title:
                          Text(row['description'] as String? ?? 'حركة محاسبية'),
                      subtitle: Text(
                          '${row['created_at']} • ${row['ref_type'] ?? ''}'),
                      trailing: Text(
                        debit > 0
                            ? '+${debit.toStringAsFixed(2)} مدين'
                            : '-${credit.toStringAsFixed(2)} دائن',
                        style: AppTypography.bodySmall.copyWith(
                          color:
                              debit > 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'دليل الحسابات',
        action: IconButton(
          tooltip: 'تحديث',
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppDimensions.space24,
                      AppDimensions.space20,
                      AppDimensions.space24,
                      AppDimensions.space8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 900 ? 3 : 1;
                      return GridView.count(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppDimensions.space12,
                        mainAxisSpacing: AppDimensions.space12,
                        childAspectRatio: columns == 1 ? 5.5 : 2.8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _AccountSummary(
                              label: 'الأصول',
                              value: _sumByType('asset'),
                              color: AppColors.primary),
                          _AccountSummary(
                              label: 'الإيرادات',
                              value: _sumByType('revenue'),
                              color: AppColors.success),
                          _AccountSummary(
                              label: 'المصروفات',
                              value: _sumByType('expense'),
                              color: AppColors.warning),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _accounts.isEmpty
                      ? const Center(child: Text('لا توجد حسابات'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          itemCount: _orderedAccounts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final account = _orderedAccounts[index];
                            final level = account['_level'] as int;
                            return ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: 8, right: 8 + level * 24.0),
                              leading: Icon(
                                level == 0
                                    ? Icons.account_tree_rounded
                                    : Icons.subdirectory_arrow_left_rounded,
                                color: level == 0
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              title: Text(account['name'] as String,
                                  style: level == 0
                                      ? AppTypography.titleMedium
                                      : AppTypography.bodyMedium),
                              subtitle: Text(
                                  '${account['code']} • ${_typeLabel(account['type'] as String)}',
                                  style: AppTypography.bodySmall),
                              trailing: Text(
                                  '${(account['balance'] as num).abs().toStringAsFixed(2)} ج.م',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: account['type'] == 'revenue'
                                        ? AppColors.success
                                        : AppColors.textPrimary,
                                  )),
                              onTap: () => _showTransactions(account),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary(
      {required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: color),
          const SizedBox(width: AppDimensions.space8),
          Text(label, style: AppTypography.bodySmall),
          const Spacer(),
          Text('${value.toStringAsFixed(2)} ج.م',
              style: AppTypography.titleSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _productsRepo = ProductRepository();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final products = await _productsRepo.getAll(activeOnly: true, limit: 1000);
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _edit(Product product) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RecipeDialog(product: product),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'وصفات الأصناف وتكلفتها',
        onBack: () => Navigator.pop(context),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('لا توجد أصناف متاحة'))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.space24),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.space10),
                  itemBuilder: (_, index) {
                    final product = _products[index];
                    return FutureBuilder<Map<String, dynamic>>(
                      future: DatabaseHelper.instance
                          .getProductCostAndProfit(product.id),
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        return Container(
                          padding: const EdgeInsets.all(AppDimensions.space16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMd),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Text(product.icon ?? '🍽️',
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: AppDimensions.space12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name,
                                        style: AppTypography.titleMedium),
                                    Text(
                                      data == null
                                          ? 'جاري حساب التكلفة...'
                                          : 'التكلفة: ${data['cost'].toStringAsFixed(2)} ج.م  •  الربح: ${data['profit'].toStringAsFixed(2)} ج.م (${data['profit_percent'].toStringAsFixed(1)}%)',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: data == null ||
                                                (data['profit'] as num) >= 0
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'تعديل الوصفة',
                                onPressed: () => _edit(product),
                                icon: const Icon(Icons.edit_note_rounded),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class _RecipeDialog extends StatefulWidget {
  const _RecipeDialog({required this.product});

  final Product product;

  @override
  State<_RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<_RecipeDialog> {
  List<Map<String, dynamic>> _materials = [];
  final Map<String, TextEditingController> _quantities = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final materials = await DatabaseHelper.instance.getRawMaterials();
    final existing = await DatabaseHelper.instance.rawQuery(
      'SELECT raw_material_id, quantity_used FROM product_recipes WHERE product_id = ?',
      [widget.product.id],
    );
    for (final material in materials) {
      final id = material['id'] as String;
      final match =
          existing.where((row) => row['raw_material_id'] == id).firstOrNull;
      _quantities[id] = TextEditingController(
        text: match == null ? '' : '${match['quantity_used']}',
      );
    }
    if (mounted) {
      setState(() {
        _materials = materials;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _quantities.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _recipeCost {
    return _materials.fold(0, (total, material) {
      final quantity =
          double.tryParse(_quantities[material['id']]?.text ?? '') ?? 0;
      final unitCost = (material['cost_per_unit'] as num?)?.toDouble() ?? 0;
      return total + quantity * unitCost;
    });
  }

  Future<void> _save() async {
    final ingredients = <Map<String, dynamic>>[];
    for (final material in _materials) {
      final quantity = double.tryParse(_quantities[material['id']]!.text) ?? 0;
      if (quantity > 0) {
        ingredients.add({
          'raw_material_id': material['id'],
          'quantity_used': quantity,
        });
      }
    }
    await DatabaseHelper.instance
        .setProductRecipe(widget.product.id, ingredients);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('وصفة ${widget.product.name}'),
      content: SizedBox(
        width: 560,
        height: 520,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _materials.isEmpty
                ? const Center(child: Text('أضف خامات أولًا ثم عد إلى الوصفة.'))
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اكتب الكمية المستخدمة في وحدة بيع واحدة للصنف',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _materials.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final material = _materials[index];
                            final cost = (material['cost_per_unit'] as num?)
                                    ?.toDouble() ??
                                0;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.inventory_2_outlined,
                                color: (_quantities[material['id']]
                                            ?.text
                                            .isNotEmpty ??
                                        false)
                                    ? AppColors.primary
                                    : AppColors.textDisabled,
                              ),
                              title: Text(material['name'] as String),
                              subtitle: Text(
                                '${material['unit']} • تكلفة الوحدة: ${cost.toStringAsFixed(2)} ج.م • المتاح: ${material['stock']}',
                                style: AppTypography.caption,
                              ),
                              trailing: SizedBox(
                                width: 105,
                                child: TextField(
                                  controller: _quantities[material['id']],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: material['unit'] as String?,
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('تكلفة الوصفة',
                              style: AppTypography.titleMedium),
                          Text(
                            '${_recipeCost.toStringAsFixed(2)} ج.م',
                            style: AppTypography.titleMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        FilledButton(
            onPressed: _loading ? null : _save,
            child: const Text('حفظ الوصفة')),
      ],
    );
  }
}
