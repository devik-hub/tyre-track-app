import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/cart_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/razorpay_service.dart';
import '../../../app/theme/clay_decorations.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/customer_background.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'online';
  DeliveryAddress? _deliveryAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).userModel;
      if (user != null && _deliveryAddress == null) {
        setState(() {
          _deliveryAddress = DeliveryAddress(
            recipientName: user.name,
            phone: user.phone,
            city: 'Pune',
            state: 'Maharashtra',
          );
        });
      }
    });
  }

  void _showAddressSheet(BuildContext context) {
    final user = ref.read(authProvider).userModel;
    final nameC = TextEditingController(text: _deliveryAddress?.recipientName ?? user?.name ?? '');
    final phoneC = TextEditingController(text: _deliveryAddress?.phone ?? user?.phone ?? '');
    final addressC = TextEditingController(text: _deliveryAddress?.address ?? '');
    final landmarkC = TextEditingController(text: _deliveryAddress?.landmark ?? '');
    final cityC = TextEditingController(text: _deliveryAddress?.city ?? 'Pune');
    final stateC = TextEditingController(text: _deliveryAddress?.state ?? 'Maharashtra');
    final pincodeC = TextEditingController(text: _deliveryAddress?.pincode ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DCDC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),
              Text('Delivery Address', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
              const Gap(4),
              Text('Where should we dispatch your tyres?', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              const Gap(16),
              TextField(
                controller: nameC,
                style: AppTextStyles.body1,
                decoration: ClayDecorations.inputDecoration(
                  labelText: 'Recipient Name *',
                  prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppColors.primary),
                ),
              ),
              const Gap(12),
              TextField(
                controller: phoneC,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.body1,
                decoration: ClayDecorations.inputDecoration(
                  labelText: 'Mobile Number *',
                  prefixIcon: const Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
                ),
              ),
              const Gap(12),
              TextField(
                controller: addressC,
                maxLines: 2,
                style: AppTextStyles.body1,
                decoration: ClayDecorations.inputDecoration(
                  labelText: 'Premises / Flat / Street Address *',
                  prefixIcon: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.primary),
                ),
              ),
              const Gap(12),
              TextField(
                controller: landmarkC,
                style: AppTextStyles.body1,
                decoration: ClayDecorations.inputDecoration(
                  labelText: 'Landmark (Optional)',
                  prefixIcon: const Icon(LucideIcons.navigation, size: 18, color: AppColors.primary),
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityC,
                      style: AppTextStyles.body1,
                      decoration: ClayDecorations.inputDecoration(
                        labelText: 'City *',
                        prefixIcon: const Icon(LucideIcons.building2, size: 18, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: TextField(
                      controller: pincodeC,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.body1,
                      decoration: ClayDecorations.inputDecoration(
                        labelText: 'PIN Code *',
                        prefixIcon: const Icon(LucideIcons.hash, size: 18, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(20),
              LiquidGlassButton(
                label: 'Save Address',
                onPressed: () {
                  if (addressC.text.trim().isEmpty || pincodeC.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Please enter street address and PIN code')),
                    );
                    return;
                  }
                  setState(() {
                    _deliveryAddress = DeliveryAddress(
                      recipientName: nameC.text.trim().isNotEmpty ? nameC.text.trim() : (user?.name ?? 'Customer'),
                      phone: phoneC.text.trim().isNotEmpty ? phoneC.text.trim() : (user?.phone ?? ''),
                      address: addressC.text.trim(),
                      landmark: landmarkC.text.trim(),
                      city: cityC.text.trim().isNotEmpty ? cityC.text.trim() : 'Pune',
                      state: stateC.text.trim().isNotEmpty ? stateC.text.trim() : 'Maharashtra',
                      pincode: pincodeC.text.trim(),
                    );
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckout(double totalRupees, int totalPaise, List<OrderItem> cartItems) async {
    final user = ref.read(authProvider).userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to checkout.')));
      return;
    }

    if (_deliveryAddress == null || _deliveryAddress!.address.trim().isEmpty || _deliveryAddress!.pincode.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your delivery address before checkout.')),
      );
      _showAddressSheet(context);
      return;
    }

    setState(() => _isProcessing = true);

    if (_selectedPaymentMethod == 'cod') {
      try {
        await ref.read(orderRepositoryProvider).checkoutAtomicWithStockReduction(
              items: cartItems,
              customer: user,
              paymentMethod: 'cod',
              paymentStatus: 'pending',
              deliveryAddress: _deliveryAddress,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed! COD confirmed!')));
          context.go(AppRoutes.home);
          Future.delayed(const Duration(milliseconds: 300), () => ref.read(cartProvider.notifier).clear());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
          setState(() => _isProcessing = false);
        }
      }
      return;
    }

    final razorpay = ref.read(razorpayServiceProvider);
    razorpay.onSuccess = (response) async {
      try {
        await ref.read(orderRepositoryProvider).checkoutAtomicWithStockReduction(
              items: cartItems,
              customer: user,
              paymentMethod: 'razorpay',
              paymentStatus: 'paid',
              paymentId: response.paymentId,
              deliveryAddress: _deliveryAddress,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
          context.go(AppRoutes.home);
          Future.delayed(const Duration(milliseconds: 300), () => ref.read(cartProvider.notifier).clear());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order save failed: $e')));
          setState(() => _isProcessing = false);
        }
      }
    };
    razorpay.onFailure = (response) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: ${response.message}')));
        setState(() => _isProcessing = false);
      }
    };
    razorpay.openCheckout(
      amount: totalRupees,
      contact: _deliveryAddress?.phone.isNotEmpty == true ? _deliveryAddress!.phone : user.phone,
      email: user.email.isNotEmpty ? user.email : 'customer@jagadale.com',
      description: 'Jagadale Retreads Tyre Order',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final totalRupees = notifier.totalAmount;
    final totalPaise = notifier.totalAmountPaise;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            const LiquidGlassAppBar(
              title: 'My Cart',
              showBrandSubtitle: true,
            ),
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.92),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.shoppingCart, size: 40, color: AppColors.textTertiary),
                          ),
                          const Gap(18),
                          Text('Your cart is empty', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                          const Gap(6),
                          Text(
                            'Browse tyres and casings to add items to your cart',
                            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, i) {
                        final item = cartItems[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LiquidGlassCard(
                            borderRadius: 22,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: AppColors.surface,
                                  ),
                                  child: const Icon(LucideIcons.disc, color: AppColors.primary, size: 26),
                                ),
                                const Gap(14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName.isNotEmpty ? item.productName : 'Product',
                                        style: AppTextStyles.label1.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        '₹${item.unitPriceRupees.toStringAsFixed(0)} each',
                                        style: AppTextStyles.h3.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(item.productId, item.quantity - 1),
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            border: Border.all(color: const Color(0xFFE8DCDC)),
                                          ),
                                          child: const Icon(LucideIcons.minus, size: 14, color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${item.quantity}',
                                        style: AppTextStyles.label1.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(item.productId, item.quantity + 1),
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary,
                                          ),
                                          child: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (cartItems.isNotEmpty) _buildCheckoutBar(totalRupees, totalPaise, cartItems),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(double totalRupees, int totalPaise, List<OrderItem> cartItems) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: LiquidGlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Address',
                    style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => _showAddressSheet(context),
                    child: Text(
                      _deliveryAddress != null && _deliveryAddress!.address.isNotEmpty ? 'Edit' : 'Add',
                      style: AppTextStyles.label2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              GestureDetector(
                onTap: () => _showAddressSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8DCDC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 18, color: AppColors.primary),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          _deliveryAddress != null && _deliveryAddress!.address.isNotEmpty
                              ? '${_deliveryAddress!.recipientName} • ${_deliveryAddress!.address}, ${_deliveryAddress!.city} ${_deliveryAddress!.pincode}'
                              : 'Tap to enter delivery location',
                          style: AppTextStyles.body2.copyWith(
                            color: _deliveryAddress != null && _deliveryAddress!.address.isNotEmpty
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              const Divider(color: Color(0xFFE8DCDC), height: 1),
              const Gap(14),
              Text('Select Payment Method', style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = 'online'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: _selectedPaymentMethod == 'online' ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: _selectedPaymentMethod == 'online' ? AppColors.primary : const Color(0xFFE8DCDC),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Online / UPI',
                            style: AppTextStyles.label1.copyWith(
                              color: _selectedPaymentMethod == 'online' ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = 'cod'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: _selectedPaymentMethod == 'cod' ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: _selectedPaymentMethod == 'cod' ? AppColors.primary : const Color(0xFFE8DCDC),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cash on Delivery',
                            style: AppTextStyles.label1.copyWith(
                              color: _selectedPaymentMethod == 'cod' ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              const Divider(color: Color(0xFFE8DCDC), height: 1),
              const Gap(14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
                  Text(
                    '₹${totalRupees.toStringAsFixed(0)}',
                    style: AppTextStyles.display2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Gap(16),
              LiquidGlassButton(
                label: _selectedPaymentMethod == 'cod' ? 'Confirm Order (COD)' : 'Proceed to Checkout',
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : () => _handleCheckout(totalRupees, totalPaise, cartItems),
              ),
            ],
          ),
        ),
      ),
    );
  }
}