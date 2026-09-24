import 'package:flutter/material.dart';

/// نظام الألوان المركزي — Dark Professional Theme
/// مائل للداكن مع Contrast عالٍ ومناسب للـ POS العربي
abstract final class AppColors {
  // ─── اللون الأساسي (Royal Blue) ───────────────────────────────────────
  static const Color primary = Color(0xFF3B82F6);       // Blue-500
  static const Color primaryLight = Color(0xFF60A5FA);  // Blue-400
  static const Color primaryDark = Color(0xFF2563EB);   // Blue-600
  static const Color accent = Color(0xFFF59E0B);        // Amber-500

  // ─── الخلفيات الداكنة ─────────────────────────────────────────────────
  static const Color background = Color(0xFF0F172A);     // Slate-900 — الخلفية الرئيسية
  static const Color surface = Color(0xFF1E293B);        // Slate-800 — سطح الكروت
  static const Color surfaceVariant = Color(0xFF334155); // Slate-700 — Inputs / Hover
  static const Color surfaceElevated = Color(0xFF263348); // بين 800 و 900

  // ─── الـ Sidebar ──────────────────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF0A111E);         // أغمق من background
  static const Color sidebarItemActive = Color(0xFF3B82F6); // Primary
  static const Color sidebarItemHover = Color(0xFF1E293B);  // Slate-800
  static const Color sidebarText = Color(0xFF94A3B8);       // Slate-400
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarDivider = Color(0xFF1E293B);    // Slate-800

  // ─── النصوص (High Contrast) ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);    // Slate-100 — على خلفية داكنة
  static const Color textSecondary = Color(0xFF94A3B8);  // Slate-400
  static const Color textDisabled = Color(0xFF475569);   // Slate-600
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF1F5F9);
  static const Color textOnSurface = Color(0xFFE2E8F0);  // Slate-200

  // ─── الحالات ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // Emerald-500
  static const Color successLight = Color(0xFF064E3B);  // Emerald-900 (dark bg)
  static const Color successSurface = Color(0xFF065F46);
  static const Color warning = Color(0xFFF59E0B);       // Amber-500
  static const Color warningLight = Color(0xFF78350F);  // Amber-900
  static const Color warningSurface = Color(0xFF92400E);
  static const Color error = Color(0xFFEF4444);         // Red-500
  static const Color errorLight = Color(0xFF7F1D1D);    // Red-900
  static const Color errorSurface = Color(0xFF991B1B);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF1E3A5F);

  // ─── الحدود والفواصل ──────────────────────────────────────────────────
  static const Color border = Color(0xFF334155);       // Slate-700 — حدود واضحة
  static const Color borderLight = Color(0xFF1E293B);  // Slate-800 — حدود خفيفة
  static const Color borderFocus = Color(0xFF3B82F6);  // Primary — عند Focus
  static const Color divider = Color(0xFF1E293B);      // Slate-800

  // ─── الـ Top Bar ──────────────────────────────────────────────────────
  static const Color topBarBg = Color(0xFF0F172A);       // نفس الخلفية
  static const Color topBarBorder = Color(0xFF1E293B);   // حد خفيف

  // ─── الكروت ───────────────────────────────────────────────────────────
  static const Color cardShadow = Color(0x40000000);  // ظل أوضح على خلفية داكنة

  // ─── ألوان كروت الإحصائيات ────────────────────────────────────────────
  static const Color statSales = Color(0xFF3B82F6);   // Blue
  static const Color statOrders = Color(0xFF10B981);  // Emerald
  static const Color statItems = Color(0xFF8B5CF6);   // Violet
  static const Color statStock = Color(0xFFF59E0B);   // Amber

  // ─── Overlay ──────────────────────────────────────────────────────────
  static const Color overlay = Color(0xCC0A111E);  // 80% opacity dark overlay
}
