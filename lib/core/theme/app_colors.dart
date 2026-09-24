import 'package:flutter/material.dart';

/// نظام الألوان المركزي — يدعم كلاً من الوضع الفاتح والوضع الداكن
abstract final class AppColors {
  /// التحقق من الوضع الحالي
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// الحصول على ألوان الثيم المناسب بناءً على BuildContext
  static _DarkColors of(BuildContext context) =>
      isDark(context) ? dk : const _LightAsAdapter();

  /// ثيم الألوان الداكنة
  static const dk = _DarkColors();

  // ═══════════════════════════════════════════════════════════════════════════
  // الألوان الأساسية للوضع الفاتح (Light Clean Theme)
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── اللون الأساسي (Vibrant Food Orange & Amber) ───────────────────────────
  static const Color primary = Color(0xFFEA580C);       // Orange-600 — دافئ وجذاب
  static const Color primaryLight = Color(0xFFFB923C);  // Orange-400
  static const Color primaryDark = Color(0xFFC2410C);   // Orange-700
  static const Color accent = Color(0xFFF59E0B);        // Amber-500

  // ─── الخلفيات الفاتحة والناصعة (Clean Slate Light) ────────────────────────
  static const Color background = Color(0xFFF8FAFC);     // Slate-50 — مريح جداً للعين
  static const Color surface = Color(0xFFFFFFFF);        // Pure White — كروت وجداول
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate-100 — حقول و Hover
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ─── الـ Sidebar ──────────────────────────────────────────────────────────
  static const Color sidebarBg = Color(0xFFFFFFFF);         // أبيض ناصع
  static const Color sidebarItemActive = Color(0xFFEA580C); // برتقالي أساسي
  static const Color sidebarItemHover = Color(0xFFF8FAFC);  // Slate-50
  static const Color sidebarText = Color(0xFF475569);       // Slate-600
  static const Color sidebarTextActive = Color(0xFFEA580C);
  static const Color sidebarDivider = Color(0xFFE2E8F0);    // Slate-200

  // ─── النصوص (High Contrast) ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);    // Slate-900 — عالي التباين
  static const Color textSecondary = Color(0xFF475569);  // Slate-600
  static const Color textDisabled = Color(0xFF94A3B8);   // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);
  static const Color textOnSurface = Color(0xFF0F172A);

  // ─── الحالات ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // Emerald-500
  static const Color successLight = Color(0xFFECFDF5);  // Emerald-50
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);       // Amber-500
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);         // Red-500
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);          // Blue-600
  static const Color infoLight = Color(0xFFEFF6FF);

  // ─── الحدود والفواصل ──────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);       // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9);  // Slate-100
  static const Color borderFocus = Color(0xFFEA580C);  // Orange-600
  static const Color divider = Color(0xFFE2E8F0);      // Slate-200

  // ─── الـ Top Bar ──────────────────────────────────────────────────────
  static const Color topBarBg = Color(0xFFFFFFFF);
  static const Color topBarBorder = Color(0xFFE2E8F0);

  // ─── الكروت ───────────────────────────────────────────────────────────
  static const Color cardShadow = Color(0x0A0F172A);

  // ─── ألوان كروت الإحصائيات ────────────────────────────────────────────
  static const Color statSales = Color(0xFFEA580C);
  static const Color statOrders = Color(0xFF10B981);
  static const Color statItems = Color(0xFF8B5CF6);
  static const Color statStock = Color(0xFFF59E0B);

  // ─── Overlay ──────────────────────────────────────────────────────────
  static const Color overlay = Color(0x4D0F172A);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ألوان الوضع الداكن — Dark Professional Theme (Royal Blue & Slate-900)
/// ═══════════════════════════════════════════════════════════════════════════
class _DarkColors {
  const _DarkColors();

  // ─── اللون الأساسي (Royal Blue) ───────────────────────────────────────
  Color get primary => const Color(0xFF3B82F6);       // Blue-500
  Color get primaryLight => const Color(0xFF60A5FA);  // Blue-400
  Color get primaryDark => const Color(0xFF2563EB);   // Blue-600
  Color get accent => const Color(0xFFF59E0B);        // Amber-500

  // ─── الخلفيات الداكنة ─────────────────────────────────────────────────
  Color get background => const Color(0xFF0F172A);     // Slate-900
  Color get surface => const Color(0xFF1E293B);        // Slate-800
  Color get surfaceVariant => const Color(0xFF334155); // Slate-700
  Color get surfaceElevated => const Color(0xFF263348); // بين 800 و 900

  // ─── الـ Sidebar ──────────────────────────────────────────────────────
  Color get sidebarBg => const Color(0xFF0A111E);         // أغمق من background
  Color get sidebarItemActive => const Color(0xFF3B82F6); // Primary
  Color get sidebarItemHover => const Color(0xFF1E293B);  // Slate-800
  Color get sidebarText => const Color(0xFF94A3B8);       // Slate-400
  Color get sidebarTextActive => const Color(0xFFFFFFFF);
  Color get sidebarDivider => const Color(0xFF1E293B);    // Slate-800

  // ─── النصوص (High Contrast) ───────────────────────────────────────────
  Color get textPrimary => const Color(0xFFF1F5F9);    // Slate-100
  Color get textSecondary => const Color(0xFF94A3B8);  // Slate-400
  Color get textDisabled => const Color(0xFF475569);   // Slate-600
  Color get textOnPrimary => const Color(0xFFFFFFFF);
  Color get textOnDark => const Color(0xFFF1F5F9);
  Color get textOnSurface => const Color(0xFFE2E8F0);  // Slate-200

  // ─── الحالات ──────────────────────────────────────────────────────────
  Color get success => const Color(0xFF10B981);       // Emerald-500
  Color get successLight => const Color(0xFF064E3B);  // Emerald-900
  Color get successSurface => const Color(0xFF065F46);
  Color get warning => const Color(0xFFF59E0B);       // Amber-500
  Color get warningLight => const Color(0xFF78350F);  // Amber-900
  Color get warningSurface => const Color(0xFF92400E);
  Color get error => const Color(0xFFEF4444);         // Red-500
  Color get errorLight => const Color(0xFF7F1D1D);    // Red-900
  Color get errorSurface => const Color(0xFF991B1B);
  Color get info => const Color(0xFF3B82F6);
  Color get infoLight => const Color(0xFF1E3A5F);

  // ─── الحدود والفواصل ──────────────────────────────────────────────────
  Color get border => const Color(0xFF334155);       // Slate-700
  Color get borderLight => const Color(0xFF1E293B);  // Slate-800
  Color get borderFocus => const Color(0xFF3B82F6);  // Primary
  Color get divider => const Color(0xFF1E293B);      // Slate-800

  // ─── الـ Top Bar ──────────────────────────────────────────────────────
  Color get topBarBg => const Color(0xFF0F172A);       // نفس الخلفية
  Color get topBarBorder => const Color(0xFF1E293B);   // حد خفيف

  // ─── الكروت ───────────────────────────────────────────────────────────
  Color get cardShadow => const Color(0x40000000);

  // ─── ألوان كروت الإحصائيات ────────────────────────────────────────────
  Color get statSales => const Color(0xFF3B82F6);   // Blue
  Color get statOrders => const Color(0xFF10B981);  // Emerald
  Color get statItems => const Color(0xFF8B5CF6);   // Violet
  Color get statStock => const Color(0xFFF59E0B);   // Amber

  // ─── Overlay ──────────────────────────────────────────────────────────
  Color get overlay => const Color(0xCC0A111E);
}

/// مُحوِّل الألوان الفاتحة — نفس واجهة _DarkColors لكن يرجع ألوان AppColors الفاتحة
final class _LightAsAdapter extends _DarkColors {
  const _LightAsAdapter();

  @override Color get primary         => AppColors.primary;
  @override Color get primaryLight    => AppColors.primaryLight;
  @override Color get primaryDark     => AppColors.primaryDark;
  @override Color get accent          => AppColors.accent;

  @override Color get background      => AppColors.background;
  @override Color get surface         => AppColors.surface;
  @override Color get surfaceVariant  => AppColors.surfaceVariant;
  @override Color get surfaceElevated => AppColors.surfaceElevated;

  @override Color get sidebarBg         => AppColors.sidebarBg;
  @override Color get sidebarItemActive => AppColors.sidebarItemActive;
  @override Color get sidebarItemHover  => AppColors.sidebarItemHover;
  @override Color get sidebarText       => AppColors.sidebarText;
  @override Color get sidebarTextActive => AppColors.sidebarTextActive;
  @override Color get sidebarDivider    => AppColors.sidebarDivider;

  @override Color get textPrimary   => AppColors.textPrimary;
  @override Color get textSecondary => AppColors.textSecondary;
  @override Color get textDisabled  => AppColors.textDisabled;
  @override Color get textOnPrimary => AppColors.textOnPrimary;
  @override Color get textOnDark    => AppColors.textOnDark;
  @override Color get textOnSurface => AppColors.textOnSurface;

  @override Color get success        => AppColors.success;
  @override Color get successLight   => AppColors.successLight;
  @override Color get successSurface => AppColors.successSurface;
  @override Color get warning        => AppColors.warning;
  @override Color get warningLight   => AppColors.warningLight;
  @override Color get warningSurface => AppColors.warningSurface;
  @override Color get error          => AppColors.error;
  @override Color get errorLight     => AppColors.errorLight;
  @override Color get errorSurface   => AppColors.errorSurface;
  @override Color get info           => AppColors.info;
  @override Color get infoLight      => AppColors.infoLight;

  @override Color get border      => AppColors.border;
  @override Color get borderLight => AppColors.borderLight;
  @override Color get borderFocus => AppColors.borderFocus;
  @override Color get divider     => AppColors.divider;

  @override Color get topBarBg     => AppColors.topBarBg;
  @override Color get topBarBorder => AppColors.topBarBorder;

  @override Color get cardShadow => AppColors.cardShadow;

  @override Color get statSales  => AppColors.statSales;
  @override Color get statOrders => AppColors.statOrders;
  @override Color get statItems  => AppColors.statItems;
  @override Color get statStock  => AppColors.statStock;

  @override Color get overlay    => AppColors.overlay;
}
