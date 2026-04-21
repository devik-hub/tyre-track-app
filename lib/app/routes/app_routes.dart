/// Central route constants — single source of truth for all navigation paths.
/// Every context.go() and context.push() must reference these constants.
abstract class AppRoutes {
  // ─── Auth ───
  static const String splash      = '/splash';
  static const String onboarding  = '/onboarding';
  static const String login       = '/login';
  static const String otp         = '/otp';
  static const String register    = '/register';

  // ─── Customer Shell (bottom nav) ───
  static const String home        = '/home';
  static const String tyres       = '/tyres';
  static const String services    = '/services';
  static const String casings     = '/casings';
  static const String account     = '/account';

  // ─── Customer Sub-screens ───
  static const String tyreDetail    = '/tyre_detail';
  static const String cart          = '/cart';
  static const String orders        = '/orders';
  static const String help          = '/help';
  static const String notifications = '/notifications';

  // ─── Public Info ───
  static const String about         = '/about';
  static const String contact       = '/contact';
  static const String gallery       = '/gallery';
  static const String legacyProducts = '/legacy-products';

  // ─── Admin Shell ───
  static const String admin            = '/admin';
  static const String adminInventory   = '/admin/inventory';
  static const String adminBookings    = '/admin/bookings';
  static const String adminOrders      = '/admin/orders';
  static const String adminSettings    = '/admin/settings';
  static const String adminServices    = '/admin/services';
  static const String adminCategories  = '/admin/categories';
  static const String adminOrderDetail = '/admin/order-detail';

  // ─── Customer sub-screens ───
  static const String orderTracker    = '/order-tracker';
}

