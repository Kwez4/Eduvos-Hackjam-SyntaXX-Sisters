import 'package:flutter/material.dart';

import 'app_state.dart';
import 'mock_data.dart';
import 'models.dart';

class SellerFinancesScreen extends StatelessWidget {
  const SellerFinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders;
    final sales = orders
        .where((order) => order.status != DeliveryStatus.cancelled)
        .toList();
    final gross = sales.fold<int>(0, (sum, order) => sum + order.amount);
    final pending = sales
        .where((order) => order.status.isOpen)
        .fold<int>(0, (sum, order) => sum + order.amount);
    final now = DateTime.now();
    int totalSince(Duration duration) => sales
        .where(
          (order) =>
              order.createdAt != null &&
              order.createdAt!.isAfter(now.subtract(duration)),
        )
        .fold<int>(0, (sum, order) => sum + order.amount);
    final held = sales
        .where((order) => order.isPaymentHeld)
        .fold<int>(0, (sum, order) => sum + order.amount);
    final fees = (gross * 0.08).round();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Finances')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _AmountCard(
                  label: 'Today',
                  amount: totalSince(const Duration(days: 1)),
                  icon: Icons.today_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AmountCard(
                  label: '7 days',
                  amount: totalSince(const Duration(days: 7)),
                  icon: Icons.date_range_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AmountCard(
                  label: '30 days',
                  amount: totalSince(const Duration(days: 30)),
                  icon: Icons.calendar_month_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AmountCard(
                  label: 'All-time gross sales',
                  amount: gross,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AmountCard(
                  label: 'Pending fulfilment',
                  amount: pending,
                  icon: Icons.pending_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AmountCard(
            label: 'Estimated platform fees (8%)',
            amount: fees,
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 10),
          _AmountCard(
            label: 'Held until buyer confirms receipt',
            amount: held,
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.account_balance_wallet_outlined,
                color: colors.primary,
              ),
              title: const Text('Payout balance'),
              subtitle: const Text(
                'Payout history and bank withdrawals require a live payment provider.',
              ),
              trailing: const Text('Not connected'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.history, color: colors.primary),
              title: const Text('Payout history'),
              subtitle: const Text('No demo payouts have been processed.'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order ledger',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (sales.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Completed sales will appear here.'),
            )
          else
            for (final order in sales)
              Card(
                child: ListTile(
                  title: Text('${order.id} • ${order.item}'),
                  subtitle: Text(
                    '${order.status.label} • ${order.paymentMethod}',
                  ),
                  trailing: Text(
                    'R${order.amount}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class SellerInsightsScreen extends StatelessWidget {
  const SellerInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final reviews = kMockSellerReviews.values
        .expand((sellerReviews) => sellerReviews)
        .take(6)
        .toList();
    final orders = state.orders;
    final salesCount = orders
        .where((order) => order.status != DeliveryStatus.cancelled)
        .length;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights & reviews')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Orders',
                  value: '$salesCount',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Sample video views',
                  value: '128',
                  icon: Icons.play_circle_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Sample conversion',
                  value: '4.8%',
                  icon: Icons.show_chart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent customer feedback',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Customer reviews will appear here.'),
            )
          else
            for (final review in reviews)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer,
                          child: const Icon(Icons.person_outline),
                        ),
                        title: Text(
                          '${review.author} • ${'★' * review.rating}',
                        ),
                        subtitle: Text(
                          '${review.comment}\n${review.dateLabel}',
                        ),
                        isThreeLine: true,
                      ),
                      Builder(
                        builder: (context) {
                          final reviewId = '${review.author}:${review.comment}';
                          final reply = AppScope.of(context)
                              .sellerReviewReplies[reviewId];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reply != null) Text('Your reply: $reply'),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _writeReply(context, reviewId, reply),
                                  icon: const Icon(Icons.reply),
                                  label: Text(
                                    reply == null ? 'Reply' : 'Edit reply',
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _writeReply(
    BuildContext context,
    String reviewId,
    String? existingReply,
  ) async {
    final controller = TextEditingController(text: existingReply);
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to review'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Write a reply'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save reply'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reply == null || reply.isEmpty || !context.mounted) return;
    AppScope.read(context).setSellerReviewReply(reviewId, reply);
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final int amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              'R$amount',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
