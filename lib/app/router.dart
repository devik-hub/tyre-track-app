import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_routes.dart';
import '../domain/providers/auth_provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/role_select_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/admin_login_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/widgets/common/main_scaffold.dart';
import '../presentation/widgets/admin/admin_scaffold.dart';

import '../presentation/screens/new_tyre/tyre_catalog_screen.dart';
import '../presentation/screens/new_tyre/tyre_detail_screen.dart';
import '../presentation/screens/new_tyre/cart_screen.dart';
import '../presentation/screens/remold_service/services_home_screen.dart';
import '../presentation/screens/remold_service/book_service_screen.dart';
import '../presentation/screens/my_vehicles/vehicle_list_screen.dart';
import '../presentation/screens/new_tyre/casing_catalog_screen.dart';
import '../presentation/screens/profile/account_home_screen.dart';
import '../presentation/screens/profile/orders_screen.dart';
import '../presentation/screens/profile/help_support_screen.dart';
import '../presentation/screens/profile/notifications_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/manage_inventory_screen.dart';
import '../presentation/screens/admin/manage_bookings_screen.dart';
import '../presentation/screens/admin/admin_orders_screen.dart';
import '../presentation/screens/admin/manage_services_screen.dart';
import '../presentation/screens/admin/manage_categories_screen.dart';
import '../presentation/screens/admin/admin_settings_screen.dart';

import '../presentation/screens/public/about_us_screen.dart';
import '../presentation/screens/public/contact_us_screen.dart';
import '../presentation/screens/public/gallery_screen.dart';
import '../presentation/screens/public/products_screen.dart';
import '../presentation/screens/admin/order_detail_screen.dart';
import '../presentation/screens/customer/order_tracker_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _adminShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'admin_shell');

/// Notifier that triggers GoRouter's redirect re-evaluation whenever
/// the auth state changes (login, logout, role change).
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      notifyListeners();
    });
  }
}

/// Riverpod provider for GoRouter.
/// The redirect guard checks the user's Firestore role on every navigation
/// and blocks non-admin users from /admin/** routes.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final path = state.uri.path;
      final authState = ref.read(authProvider);

      // Allow splash, login, register, onboarding, OTP, role-select, admin-login to pass ungated
      const ungatedPaths = [
        AppRoutes.splash,
        AppRoutes.roleSelect,
        AppRoutes.login,
        AppRoutes.adminLogin,
        AppRoutes.register,
        AppRoutes.onboarding,
        AppRoutes.otp,
      ];
      if (ungatedPaths.contains(path)) return null;

      // If auth is still loading, don't redirect yet
      if (authState.isLoading) return null;

      // If no user is logged in, redirect to role selection
      final user = authState.userModel;
      if (user == null) return AppRoutes.roleSelect;

      // ── Admin Route Guard ──
      // Block non-admin users from any /admin/** path
      if (path.startsWith('/admin') && user.role != 'admin') {
        return AppRoutes.home;
      }

      return null; // No redirect needed
    },
    routes: [
      // ── Splash ────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.splash,      builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding,  builder: (context, state) => const OnboardingScreen()),

      // ── Role Selection (Devika's UI — first screen for unauthenticated users) ──
      GoRoute(path: AppRoutes.roleSelect,  builder: (context, state) => const RoleSelectScreen()),

      // ── User Auth ─────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.login,       builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final verificationId = state.extra as String? ?? '';
          return OtpScreen(verificationId: verificationId);
        },
      ),
      GoRoute(path: AppRoutes.register,    builder: (context, state) => const RegisterScreen()),

      // ── Admin Auth (Devika's dedicated admin login) ────────────────────
      GoRoute(path: AppRoutes.adminLogin,  builder: (context, state) => const AdminLoginScreen()),

      // ── Shared / Deep-link routes ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.tyreDetail,
        builder: (context, state) {
          final productId = state.extra as String? ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(path: AppRoutes.cart,          builder: (context, state) => const CartScreen()),
      GoRoute(path: AppRoutes.orders,        builder: (context, state) => const OrdersScreen()),
      GoRoute(path: AppRoutes.help,          builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.bookService,   builder: (context, state) => const BookServiceScreen()),
      GoRoute(
        path: AppRoutes.orderTracker,
        builder: (context, state) {
          final orderId = state.extra as String? ?? '';
          return OrderTrackerScreen(orderId: orderId);
        },
      ),

      // ── Public Pages ──────────────────────────────────────────────────
      GoRoute(path: AppRoutes.about,          builder: (context, state) => const CompanyAboutUsScreen()),
      GoRoute(path: AppRoutes.contact,        builder: (context, state) => const CompanyContactScreen()),
      GoRoute(path: AppRoutes.gallery,        builder: (context, state) => const CompanyGalleryScreen()),
      GoRoute(path: AppRoutes.legacyProducts, builder: (context, state) => const CompanyProductsScreen()),

      // ── Admin Shell (protected by redirect above) ─────────────────────
      ShellRoute(
        navigatorKey: _adminShellNavigatorKey,
        builder: (context, state, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.admin,          builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: AppRoutes.adminInventory, builder: (context, state) => const ManageInventoryScreen()),
          GoRoute(path: AppRoutes.adminBookings,  builder: (context, state) => const ManageBookingsScreen()),
          GoRoute(path: AppRoutes.adminOrders,    builder: (context, state) => const AdminOrdersScreen()),
          GoRoute(path: AppRoutes.adminSettings,  builder: (context, state) => const AdminSettingsScreen()),
          GoRoute(path: AppRoutes.adminServices,  builder: (context, state) => const ManageServicesScreen()),
          GoRoute(path: AppRoutes.adminCategories, builder: (context, state) => const ManageCategoriesScreen()),
          GoRoute(
            path: AppRoutes.adminOrderDetail,
            builder: (context, state) {
              final orderId = state.extra as String? ?? '';
              return OrderDetailScreen(orderId: orderId);
            },
          ),
        ],
      ),

      // ── User Shell ────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.home,     builder: (context, state) => const HomeScreen()),
          GoRoute(path: AppRoutes.tyres,    builder: (context, state) => const TyreCatalogScreen()),
          GoRoute(path: AppRoutes.services, builder: (context, state) => const ServicesHomeScreen()),
          GoRoute(path: AppRoutes.casings,  builder: (context, state) => const CasingCatalogScreen()),
          GoRoute(path: AppRoutes.account,  builder: (context, state) => const AccountHomeScreen()),
        ],
      ),
    ],
  );
});
