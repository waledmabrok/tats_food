import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/database/database_helper.dart';
import 'core/services/device_lock_service.dart';
import 'core/widgets/device_locked_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // السماح بتحميل الخطوط من الإنترنت
  GoogleFonts.config.allowRuntimeFetching = true;

  // تهيئة قاعدة البيانات المحلية (SQLite عبر FFI للـ Windows)
  await DatabaseHelper.instance.database;

  // ─── التحقق من ربط الجهاز ────────────────────────────────────────
  final deviceCheck = await DeviceLockService.instance.checkDevice();

  runApp(FoodProApp(isDeviceLocked: deviceCheck == DeviceCheckResult.mismatch));
}

/// نقطة الدخول الرئيسية لنظام فود برو
class FoodProApp extends StatelessWidget {
  const FoodProApp({super.key, required this.isDeviceLocked});
  final bool isDeviceLocked;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ─── دعم التعريب الكامل (ضروري لـ Date Pickers و Dialogs) ──────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),

      // ─── الـ Theme المركزي ─────────────────────────────────────────
      theme: AppTheme.light,

      // ─── الشاشة الرئيسية مع RTL ───────────────────────────────────
      home: isDeviceLocked ? const DeviceLockedScreen() : const LoginScreen(),
    );
  }
}
