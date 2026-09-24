import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/cashier/presentation/screens/cashier_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shell/placeholder_screen.dart';
import '../constants/app_strings.dart';

/// تعريف مسارات التنقل في النظام
abstract final class AppRoutes {
  static const String dashboard = '/';
  static const String cashier = '/cashier';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String inventory = '/inventory';
  static const String orders = '/orders';
  static const String reports = '/reports';
  static const String expenses = '/expenses';
  static const String users = '/users';
  static const String settings = '/settings';
}

/// عناصر الـ Navigation
class NavItem {
  const NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.isActive = true,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
}

/// قائمة التنقل الرئيسية
const List<NavItem> mainNavItems = [
  NavItem(
    route: AppRoutes.dashboard,
    label: AppStrings.navDashboard,
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
  ),
  NavItem(
    route: AppRoutes.cashier,
    label: AppStrings.navCashier,
    icon: Icons.point_of_sale_outlined,
    activeIcon: Icons.point_of_sale_rounded,
  ),
  NavItem(
    route: AppRoutes.products,
    label: AppStrings.navProducts,
    icon: Icons.fastfood_outlined,
    activeIcon: Icons.fastfood_rounded,
  ),
  NavItem(
    route: AppRoutes.categories,
    label: AppStrings.navCategories,
    icon: Icons.category_outlined,
    activeIcon: Icons.category_rounded,
    isActive: true,
  ),
  NavItem(
    route: AppRoutes.inventory,
    label: AppStrings.navInventory,
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    isActive: true,
  ),
  NavItem(
    route: AppRoutes.orders,
    label: AppStrings.navOrders,
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    isActive: true,
  ),
];

/// قائمة التنقل الثانوية (إدارة)
const List<NavItem> managementNavItems = [
  NavItem(
    route: AppRoutes.reports,
    label: AppStrings.navReports,
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    isActive: true,
  ),
  NavItem(
    route: AppRoutes.expenses,
    label: AppStrings.navExpenses,
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet_rounded,
    isActive: true,
  ),
  NavItem(
    route: AppRoutes.users,
    label: AppStrings.navUsers,
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    isActive: true,
  ),
  NavItem(
    route: AppRoutes.settings,
    label: AppStrings.navSettings,
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    isActive: true,
  ),
];

/// بناء الـ Widget المناسب للمسار
Widget buildRouteWidget(String route) {
  return switch (route) {
    AppRoutes.dashboard => const DashboardScreen(),
    AppRoutes.cashier => const CashierScreen(),
    AppRoutes.products => const ProductsScreen(),
    AppRoutes.categories => const CategoriesScreen(),
    AppRoutes.inventory => const InventoryScreen(),
    AppRoutes.orders => const OrdersScreen(),
    AppRoutes.reports => const ReportsScreen(),
    AppRoutes.expenses => const ExpensesScreen(),
    AppRoutes.users => const UsersScreen(),
    AppRoutes.settings => const SettingsScreen(),
    _ => PlaceholderScreen(title: _routeLabel(route), route: route),
  };
}

String _routeLabel(String route) {
  const labels = {
    AppRoutes.categories: AppStrings.navCategories,
    AppRoutes.inventory: AppStrings.navInventory,
    AppRoutes.orders: AppStrings.navOrders,
    AppRoutes.reports: AppStrings.navReports,
    AppRoutes.expenses: AppStrings.navExpenses,
    AppRoutes.users: AppStrings.navUsers,
    AppRoutes.settings: AppStrings.navSettings,
  };
  return labels[route] ?? route;
}
