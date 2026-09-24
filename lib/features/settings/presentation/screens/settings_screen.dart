import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_top_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeletingSales = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    _nameCtrl.text = await _db.getSetting('restaurant_name') ?? '';
    _phoneCtrl.text = await _db.getSetting('restaurant_phone') ?? '';
    _addressCtrl.text = await _db.getSetting('restaurant_address') ?? '';
    _currencyCtrl.text =
        await _db.getSetting('currency') ?? AppStrings.currency;

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await _db.setSetting('restaurant_name', _nameCtrl.text.trim());
    await _db.setSetting('restaurant_phone', _phoneCtrl.text.trim());
    await _db.setSetting('restaurant_address', _addressCtrl.text.trim());
    await _db.setSetting('currency', _currencyCtrl.text.trim());

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.settingsSaved),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // ─── حذف كل المبيعات ────────────────────────────────────────────────
  Future<void> _confirmDeleteAllSales() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.error,
          size: 40,
        ),
        title: const Text('حذف كل المبيعات'),
        content: const Text(
          'هيتم حذف كل الطلبات وسجلات البيع نهائيًا من النظام.\n\n'
          'الأصناف والتصنيفات والمخزون الحالي مش هيتأثروا.\n\n'
          'الإجراء ده لا يمكن التراجع عنه، متأكد إنك عايز تكمل؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingSales = true);
    try {
      await _db.deleteAllSales();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف كل المبيعات بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحذف: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingSales = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: AppStrings.settingsTitle),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.space32),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── بيانات المطعم ─────────────────────────────────
                        Text(
                          AppStrings.settingsRestaurant,
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          AnimatedBuilder(
  animation: ThemeController.instance,
  builder: (context, _) {
    final mode = ThemeController.instance.mode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مظهر النظام',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),

        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_outlined),
              label: Text('فاتح'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_outlined),
              label: Text('داكن'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) {
            ThemeController.instance.setMode(selection.first);
          },
        ),

        const SizedBox(height: AppDimensions.space20),
      ],
    );
  },
),
                              _buildField(
                                AppStrings.settingsRestaurantName,
                                _nameCtrl,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'اسم المطعم مطلوب'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildPhoneField(),
                              const SizedBox(height: 16),
                              _buildField(
                                AppStrings.settingsRestaurantAddress,
                                _addressCtrl,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space32),

                        // ─── إعدادات النظام ────────────────────────────────
                        Text(
                          AppStrings.settingsSystem,
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildField(
                                AppStrings.settingsCurrency,
                                _currencyCtrl,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'سيتم تطبيق التغييرات في النظام بالكامل. برجاء إعادة تشغيل التطبيق في حالة تغيير العملة.',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.space32),

                        // زر الحفظ
                        SizedBox(
                          width: 200,
                          height: AppDimensions.buttonHeightLg,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveSettings,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              AppStrings.btnSave,
                              style: AppTypography.button,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.space32),

                        // ─── منطقة الخطر ────────────────────────────────────
                        Text(
                          'منطقة الخطر',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.delete_forever_rounded,
                                    color: AppColors.error,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'حذف كل المبيعات',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'هيمسح كل الطلبات وسجلات البيع نهائيًا. الأصناف والتصنيفات والمخزون '
                                'هيفضلوا زي ما هما من غير تأثير. الإجراء ده لا يمكن التراجع عنه.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: AppDimensions.buttonHeightLg,
                                child: OutlinedButton.icon(
                                  onPressed: _isDeletingSales
                                      ? null
                                      : _confirmDeleteAllSales,
                                  icon: _isDeletingSales
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.error,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.delete_forever_rounded,
                                        ),
                                  label: Text(
                                    _isDeletingSales
                                        ? 'جاري الحذف...'
                                        : 'حذف كل المبيعات',
                                    style: AppTypography.button.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
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
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.settingsRestaurantPhone,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 11,
          style: AppTypography.bodyMedium,
          validator: (v) {
            if (v == null || v.trim().isEmpty)
              return null; // رقم الهاتف اختياري
            if (v.trim().length != 11)
              return 'رقم الهاتف يجب أن يكون 11 رقم بالضبط';
            return null;
          },
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyMedium,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
