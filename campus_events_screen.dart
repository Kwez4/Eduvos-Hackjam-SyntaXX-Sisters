import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_state.dart';
import 'models.dart';

class CampusEventsScreen extends StatelessWidget {
  const CampusEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final events = state.upcomingEvents;

    return Scaffold(
      appBar: AppBar(title: const Text('Campus events')),
      body: events.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No upcoming events for ${state.campus}. '
                  'Choose another campus in Settings to explore more events.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) => _EventCard(event: events[index]),
            ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final CampusEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat('EEE, d MMM • h:mm a').format(event.start);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            event.imagePath,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 190,
              color: colors.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Icon(event.category.icon, size: 48, color: colors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Chip(label: Text(event.category.label)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(event.description),
                const SizedBox(height: 12),
                _EventDetail(icon: Icons.schedule_outlined, text: date),
                _EventDetail(
                  icon: Icons.location_on_outlined,
                  text: '${event.location} • ${event.campus}',
                ),
                _EventDetail(
                  icon: Icons.groups_outlined,
                  text: '${event.going} going • Hosted by ${event.host}',
                ),
                const SizedBox(height: 8),
                Text(
                  event.priceLabel,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
