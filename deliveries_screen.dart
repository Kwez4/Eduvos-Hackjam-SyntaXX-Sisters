import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_state.dart';
import 'models.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  Future<void> _reportOrderProblem(
    BuildContext context,
    AppState state,
    CampusOrder order,
  ) async {
    final controller = TextEditingController();
    final details = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an order problem'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe the issue so the Hub can help.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (details == null || details.isEmpty || !context.mounted) return;
    final ticket = state.disputeOrder(order.id, details);
    if (ticket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This order no longer has a payment hold.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Issue sent to the Hub • ${ticket.reference}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = Theme.of(context).colorScheme;
    final orders = state.buyerOrders;

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No orders yet. Your purchases and appointments will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final order in orders)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.item,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                order.id,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'From ${state.sellerById(order.sellerId).name} • Qty ${order.quantity}',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          DeliveryProgress(status: order.status),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.isAppointment
                                      ? 'Appointment: ${DateFormat('EEE, d MMM yyyy • h:mm a').format(order.appointmentAt!)}'
                                      : order.status == DeliveryStatus.delivered
                                      ? 'Delivered'
                                      : order.estimatedDelivery ==
                                            'Campus pickup to be arranged'
                                      ? 'Status: ${order.status.label} • ${order.estimatedDelivery}'
                                      : 'Estimated: ${order.estimatedDelivery}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (order.isAppointment)
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active_outlined,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Reminder set for 1 day before (demo)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Paid via ${order.paymentMethod}',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                          if (order.amount > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              order.isPaymentHeld
                                  ? 'R${order.amount} is held until you confirm receipt (demo).'
                                  : 'Receipt confirmed • R${order.amount} released (demo).',
                              style: TextStyle(
                                color: order.isPaymentHeld
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (order.isPaymentHeld &&
                              order.status == DeliveryStatus.delivered) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                FilledButton.tonal(
                                  onPressed: () {
                                    if (state.confirmOrderReceipt(order.id)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Receipt confirmed. Demo funds released.',
                                              ),
                                            ),
                                          );
                                    }
                                  },
                                  child: const Text('Confirm receipt'),
                                ),
                                TextButton(
                                  onPressed: () => _reportOrderProblem(
                                    context,
                                    state,
                                    order,
                                  ),
                                  child: const Text('Report a problem'),
                                ),
                              ],
                            ),
                          ] else if (order.isPaymentHeld &&
                              order.status.isOpen) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _reportOrderProblem(context, state, order),
                                child: const Text('Report a problem'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class DeliveryProgress extends StatelessWidget {
  const DeliveryProgress({super.key, required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentIndex = status.index;

    return Row(
      children: [
        for (var index = 0; index < DeliveryStatus.values.length; index++) ...[
          Icon(
            index <= currentIndex
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 18,
            color: index <= currentIndex
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
          if (index < DeliveryStatus.values.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: index < currentIndex
                    ? colors.primary
                    : colors.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }
}
