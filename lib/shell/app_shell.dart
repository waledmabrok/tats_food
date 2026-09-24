import 'package:flutter/material.dart';
import '../core/routing/app_router.dart';
import '../core/widgets/app_sidebar.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/services/session_service.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/cashier/presentation/screens/cashier_screen.dart';
import '../models/app_user.dart';

/// الـ Shell الرئيسي للتطبيق
/// Owner → يرى الـ Sidebar الكامل + كل الشاشات
/// Cashier → يرى POS فقط بدون Sidebar
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user});

  final AppUser user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _currentRoute = AppRoutes.dashboard;

  @override
  void initState() {
    super.initState();
    // الكاشير يبدأ مباشرة على POS
    if (!widget.user.isManager) {
      _currentRoute = AppRoutes.cashier;
    }
  }

  void _onRouteSelected(String route) {
    // حماية: الكاشير لا يستطيع التنقل خارج POS
    if (!widget.user.isManager) return;
    if (_currentRoute == route) return;
    setState(() => _currentRoute = route);
  }

  void _logout() {
    SessionService.instance.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // ─── واجهة الكاشير (POS فقط، بدون Sidebar) ─────────────────────
    if (!widget.user.isManager) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _CashierTopBar(userName: widget.user.name, onLogout: _logout),
            const Expanded(child: CashierScreen()),
          ],
        ),
      );
    }

    // ─── واجهة المالك (النظام الكامل) ───────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        // ─── الخلفية الموحدة للنظام كله ──────────────────────────
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF0F172A), // Slate-900
              Color(0xFF0A111E), // أغمق قليلاً
            ],
          ),
        ),
        child: Row(
          children: [
            // ─── الـ Sidebar على اليمين (RTL) ───────────────────────
            AppSidebar(
              currentRoute: _currentRoute,
              onRouteSelected: _onRouteSelected,
              user: widget.user,
              onLogout: _logout,
            ),

            // ─── فاصل عمودي ──────────────────────────────────────────
            Container(width: 1, color: AppColors.borderLight),

            // ─── المحتوى الرئيسي ──────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_currentRoute),
                  child: buildRouteWidget(_currentRoute),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── شريط الكاشير العلوي ───────────────────────────────────────────────────
class _CashierTopBar extends StatelessWidget {
  const _CashierTopBar({required this.userName, required this.onLogout});

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: [
          // اسم النظام
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/logo.png',
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'طاطس — نقطة البيع',
            style: AppTypography.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          // اسم الكاشير
          const Icon(Icons.person_rounded, color: Color(0xFF94A3B8), size: 18),
          const SizedBox(width: 6),
          Text(
            userName,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '• كاشير',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 16),

          // زر الخروج
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('خروج'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}
