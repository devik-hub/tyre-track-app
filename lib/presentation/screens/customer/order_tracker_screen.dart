import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/providers/customer_order_providers.dart';

class OrderTrackerScreen extends ConsumerWidget{
  final String orderId;
  const OrderTrackerScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final orderAsync = ref.watch(customerOrderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId}'),
        backgroundColor: AppColors.mrfRed,
        foregroundColor: Colors.white,
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mrfRed),
        ),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.mrfRed, size: 56),
              const SizedBox(height: 16),
              const Text('Unable to load order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey),),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back'),),
            ],
          ),
        ),
        data: (order){
          if(order==null){
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Order not found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
                ],
              ),
            );
          }
          return _OrderTrackerBody(order: order);
        },
      ),
    );
  }
}

class _OrderTrackerBody extends StatelessWidget{
  final OrderModel order;
  const _OrderTrackerBody({required this.order});

  static const _statusSteps = [
    'pending_confirmation',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
  ];

  @override
  Widget build(BuildContext context){
    final currentStep = _statusSteps.indexOf(order.orderStatus);
    final isCancelled = order.orderStatus == 'cancelled';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('Live tracking active',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status timeline
          if(!isCancelled) ...[
            const Text('Order Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._statusSteps.asMap().entries.map((entry){
              final idx = entry.key;
              final status = entry.value;
              final done = currentStep >= idx;
              final current = currentStep == idx;
              return _TimelineStep(
                label: status.replaceAll('_', ' ').toUpperCase(),
                subtitle: _stepSubtitle(status, order),
                done: done,
                isCurrent: current,
              );
            }),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Cancelled',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                      ),
                      if(order.cancelledAt != null)
                        Text('On ${_date(order.cancelledAt!)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Payment status
          _infoCard('Payment', [
            _infoRow('Method', order.paymentMethod == 'cod' ? 'Cash on Delivery' : 'Online Payment'),
            _infoRow('Status', order.paymentStatus.toUpperCase()),
            _infoRow('Amount', '₹${order.finalAmountRupees.toStringAsFixed(0)}'),
          ]),
          const SizedBox(height: 16),

          // Items
          _infoCard('Items', [
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${item.productName.isNotEmpty ? item.productName : 'Item'} × ${item.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text('₹${item.totalPriceRupees.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed),
                  ),
                ],
              ),
            ),),
          ],),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          const Divider(),
        ...children,
        ],
      ),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13),),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),),
    ],),
  );

  String _stepSubtitle(String status, OrderModel order){
    switch(status){
      case 'pending_confirmation':
        return order.createdAt != null ? _date(order.createdAt) : '';
      case 'confirmed':
        return order.confirmedAt != null ? _date(order.confirmedAt!) : '';
      case 'shipped':
        return order.shippedAt   != null ? _date(order.shippedAt!)   : '';
      case 'delivered':
        return order.deliveredAt != null ? _date(order.deliveredAt!) : '';
      default:
        return '';
    }
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
}

class _TimelineStep extends StatelessWidget{
  final String label, subtitle;
  final bool done, isCurrent;
  const _TimelineStep({required this.label, required this.subtitle, required this.done, required this.isCurrent});

  @override
  Widget build(BuildContext context){
    final color = done ? AppColors.mrfRed : Colors.grey.shade300;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(
              color: done ? AppColors.mrfRed : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(color: isCurrent ? AppColors.mrfRed : Colors.transparent, width: 2),
            ),
            child: Icon(done ? Icons.check : Icons.circle, size: 14, color: done ? Colors.white : Colors.grey.shade400),
          ),
          Container(width: 2, height: 40, color: Colors.grey.shade200),
        ],),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: done ? Colors.black87 : Colors.grey.shade400, fontSize: 13),
              ),
              if(subtitle.isNotEmpty)
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11),),
              const SizedBox(height: 20),
            ],
          ),
        ),),
    ],);
  }
}
