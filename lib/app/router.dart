import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/widgets/common/main_scaffold.dart';
import '../presentation/widgets/admin/admin_scaffold.dart';

import '../presentation/screens/new_tyre/tyre_catalog_screen.dart';
import '../presentation/screens/new_tyre/tyre_detail_screen.dart';
import '../presentation/screens/new_tyre/cart_screen.dart';
import '../presentation/screens/remold_service/services_home_screen.dart';
import '../presentation/screens/my_vehicles/vehicle_list_screen.dart';
import '../presentation/screens/profile/account_home_screen.dart';
import '../presentation/screens/profile/orders_screen.dart';
import '../presentation/screens/profile/help_support_screen.dart';
import '../presentation/screens/profile/notifications_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/manage_inventory_screen.dart';
import '../presentation/screens/admin/manage_bookings_screen.dart';
import '../presentation/screens/admin/admin_orders_screen.dart';

import '../presentation/screens/public/about_us_screen.dart';
import '../presentation/screens/public/contact_us_screen.dart';
import '../presentation/screens/public/gallery_screen.dart';
import '../presentation/screens/public/products_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GlobalKey<NavigatorState> _adminShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'admin_shell');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final verificationId = state.extra as String? ?? '';
          return OtpScreen(verificationId: verificationId);
        },
      ),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/tyre_detail',
        builder: (context, state) {
          final productId = state.extra as String? ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
      GoRoute(path: '/help', builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

      // Public routes
      GoRoute(path: '/about', builder: (context, state) => const CompanyAboutUsScreen()),
      GoRoute(path: '/contact', builder: (context, state) => const CompanyContactScreen()),
      GoRoute(path: '/gallery', builder: (context, state) => const CompanyGalleryScreen()),
      GoRoute(path: '/legacy-products', builder: (context, state) => const CompanyProductsScreen()),

      // Admin Shell Route
      ShellRoute(
        navigatorKey: _adminShellNavigatorKey,
        builder: (context, state, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/inventory', builder: (context, state) => const ManageInventoryScreen()),
          GoRoute(path: '/admin/bookings', builder: (context, state) => const ManageBookingsScreen()),
          GoRoute(path: '/admin/orders', builder: (context, state) => const AdminOrdersScreen()),
        ],
      ),


      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/tyres', builder: (context, state) => const TyreCatalogScreen()),
          GoRoute(path: '/services', builder: (context, state) => const ServicesHomeScreen()),
          GoRoute(path: '/vehicles', builder: (context, state) => const VehicleListScreen()),
          GoRoute(path: '/account', builder: (context, state) => const AccountHomeScreen()),
        ],
      ),
    ],
  );
}
