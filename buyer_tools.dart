import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_state.dart';
import 'models.dart';

class PrivateMessagesScreen extends StatelessWidget {
  const PrivateMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final threads = state.visibleThreads;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: threads.isEmpty
          ? const Center(
              child: Text(
                'No conversations yet. Message a seller to get started.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(thread.seller.imagePath),
                    ),
                    title: Text(thread.seller.name),
                    subtitle: Text(
                      thread.last?.text ?? 'Start a private conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: thread.unread > 0
                        ? Badge(label: Text('${thread.unread}'))
                        : const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DirectMessageScreen(thread: thread),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class DirectMessageScreen extends StatefulWidget {
  const DirectMessageScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.thread.open = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppScope.read(context).markRead(widget.thread);
    });
  }

  @override
  void dispose() {
    widget.thread.open = false;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(
    String text, {
    String? imagePath,
    String? productName,
  }) async {
    final value = text.trim();
    if (value.isEmpty && imagePath == null && productName == null) return;
    _controller.clear();
    final sending = AppScope.read(context).sendMessage(
      widget.thread.seller,
      value,
      imagePath: imagePath,
      productName: productName,
    );
    if (mounted) setState(() {});
    await sending;
    if (mounted) setState(() {});
  }

  Future<void> _shareOffering() async {
    final offering = await showModalBottomSheet<Offering>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Share a product or service')),
            for (final offering in widget.thread.seller.offerings)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: imageProviderFor(offering.imagePath),
                ),
                title: Text(offering.name),
                subtitle: Text('R${offering.price}'),
                onTap: () => Navigator.pop(context, offering),
              ),
          ],
        ),
      ),
    );
    if (offering == null || !mounted) return;
    await _send(
      'Shared listing: ${offering.name} • R${offering.price}',
      imagePath: offering.imagePath,
      productName: offering.name,
    );
  }

  Future<void> _shareOrder() async {
    final orders = AppScope.read(context).buyerOrders;
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have no orders to share.')),
      );
      return;
    }
    final order = await showModalBottomSheet<CampusOrder>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Share an order')),
            for (final order in orders)
              ListTile(
                title: Text('${order.id} • ${order.item}'),
                subtitle: Text(order.status.label),
                onTap: () => Navigator.pop(context, order),
              ),
          ],
        ),
      ),
    );
    if (order == null || !mounted) return;
    await _send('Order ${order.id}: ${order.item} • ${order.status.label}');
  }

  Future<void> _reportOrBlock() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report this conversation'),
              subtitle: const Text('Flag it for review by the Hub.'),
              onTap: () => Navigator.pop(context, 'report'),
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block this seller'),
              subtitle: const Text('Hide this conversation and stop messages.'),
              onTap: () => Navigator.pop(context, 'block'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == 'report') {
      AppScope.read(context).reportSeller(widget.thread);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation reported for Hub review.')),
      );
      return;
    }
    AppScope.read(context).blockSeller(widget.thread);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(thread.seller.name),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Conversation safety',
            onSelected: (_) => _reportOrBlock(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'safety', child: Text('Report or block')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Text(
              'Private messages • avoid sharing phone numbers or sensitive information.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: thread.messages.length + (thread.typing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == thread.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Seller is typing…'),
                  );
                }
                final message = thread.messages[index];
                return Align(
                  alignment: message.fromMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Card(
                      color: message.fromMe
                          ? colors.primaryContainer
                          : colors.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.imagePath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  message.imagePath!,
                                  height: 140,
                                  width: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (message.productName != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    message.productName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            if (message.text.isNotEmpty) Text(message.text),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a').format(message.time),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Share listing',
                    onPressed: _shareOffering,
                    icon: const Icon(Icons.sell_outlined),
                  ),
                  IconButton(
                    tooltip: 'Share order',
                    onPressed: _shareOrder,
                    icon: const Icon(Icons.receipt_long_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) => _send(value),
                      decoration: const InputDecoration(
                        hintText: 'Private message',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: () => _send(_controller.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _ticketCategories = [
  'Order problem',
  'Payment',
  'Account',
  'Report a user',
  'Request a product',
  'Feedback',
  'Other',
];

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Quick answers',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final (question, answer) in const [
            (
              'How do I track an order?',
              'Open My orders from the home screen to view order status and appointment details.',
            ),
            (
              'How do I book a service?',
              'Open a service listing, choose an available date and time, then add the appointment to your cart.',
            ),
            (
              'Is checkout live?',
              'No. Card, EFT and bank approval are simulated in this demo. Never enter real financial details.',
            ),
            (
              'How do sellers receive payouts?',
              'Payouts are not connected in this demo. Contact the Hub before treating an order as paid.',
            ),
          ])
            Card(
              child: ExpansionTile(
                title: Text(question),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(answer),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SubmitSupportTicketScreen(),
              ),
            ),
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Submit a query'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MySupportTicketsScreen(),
              ),
            ),
            icon: const Icon(Icons.confirmation_number_outlined),
            label: Text('My queries (${state.supportTickets.length})'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SupportAssistantScreen(),
              ),
            ),
            icon: const Icon(Icons.smart_toy_outlined),
            label: const Text('Ask the support assistant'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HubDemoOverviewScreen(),
              ),
            ),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('Hub overview (demo)'),
          ),
          const SizedBox(height: 12),
          Text(
            'Support hours: Monday–Friday, 08:00–17:00. Target first response: within 24 hours.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SubmitSupportTicketScreen extends StatefulWidget {
  const SubmitSupportTicketScreen({super.key});

  @override
  State<SubmitSupportTicketScreen> createState() =>
      _SubmitSupportTicketScreenState();
}

class _SubmitSupportTicketScreenState extends State<SubmitSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _category = _ticketCategories.first;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final ticket = AppScope.read(context)
        .createSupportTicket(_category, _descriptionController.text.trim());
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Query submitted'),
        content: Text(
          'Reference ${ticket.reference}\nStatus: ${ticket.status.label}\nTarget first response: within 24 hours.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a query')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in _ticketCategories)
                  DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Describe your query',
                hintText: 'Include the order number if this is order-related.',
                alignLabelWithHint: true,
              ),
              validator: (value) => (value?.trim().length ?? 0) < 10
                  ? 'Please add at least 10 characters'
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Submit query')),
          ],
        ),
      ),
    );
  }
}

class MySupportTicketsScreen extends StatelessWidget {
  const MySupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = AppScope.of(context).supportTickets;
    return Scaffold(
      appBar: AppBar(title: const Text('My queries')),
      body: tickets.isEmpty
          ? const Center(child: Text('You have not submitted any queries.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: Text('${ticket.category} • ${ticket.reference}'),
                    subtitle: Text(
                      '${ticket.description}\n${DateFormat('d MMM yyyy, h:mm a').format(ticket.createdAt)} • Response target: within 24 hours',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<SupportTicketStatus>(
                      tooltip: 'Update demo ticket status',
                      initialValue: ticket.status,
                      onSelected: (status) =>
                          AppScope.read(context)
                              .updateSupportTicket(ticket, status),
                      itemBuilder: (_) => [
                        for (final status in SupportTicketStatus.values)
                          PopupMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                      ],
                      child: Chip(label: Text(ticket.status.label)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SupportAssistantScreen extends StatefulWidget {
  const SupportAssistantScreen({super.key});

  @override
  State<SupportAssistantScreen> createState() => _SupportAssistantScreenState();
}

class _SupportAssistantScreenState extends State<SupportAssistantScreen> {
  final _controller = TextEditingController();
  final List<(String, bool)> _messages = [
    (
      'Hi! I’m the demo support assistant. Ask about listings, payouts, orders, or checkout.',
      false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _answer(String question) {
    final text = question.toLowerCase();
    if (text.contains('payout') || text.contains('finance')) {
      return 'Payouts are not connected in this demo. Check Seller Studio > Sales & finances for illustrative figures, then submit a query if you need help.';
    }
    if (text.contains('order') || text.contains('delivery')) {
      return 'Buyers can track orders from My orders. Sellers can accept, reject, and update progress in Seller Studio > View orders.';
    }
    if (text.contains('list') || text.contains('stock')) {
      return 'Sellers can create and edit listings in Seller Studio. Manage listings includes stock counts, variants, and low-stock alerts.';
    }
    if (text.contains('pay') || text.contains('card') || text.contains('eft')) {
      return 'Checkout is simulated. Never enter real financial details. Payment settlement and refunds need a live payment provider.';
    }
    return 'I can help with orders, payments, listings, and payouts. For a person to investigate, submit a support query; the demo target response time is within 24 hours.';
  }

  void _send() {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _messages
        ..add((question, true))
        ..add((_answer(question), false));
    });
    _controller.clear();
  }

  void _escalate() {
    final latestQuestion = _messages.lastWhere(
      (message) => message.$2,
      orElse: () => ('Support request', true),
    );
    final ticket = AppScope.read(context).createSupportTicket(
      'Other',
      'Escalated from support assistant: ${latestQuestion.$1}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent to the Hub • ${ticket.reference}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support assistant')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Automated demo assistant • answers may be incomplete.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final (text, fromMe) in _messages)
                  Align(
                    alignment: fromMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(text),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Ask a question',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Send question',
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _escalate,
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Escalate to the Hub'),
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

class HubDemoOverviewScreen extends StatelessWidget {
  const HubDemoOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final categoryCounts = <String, int>{};
    for (final ticket in state.supportTickets) {
      categoryCounts.update(
        ticket.category,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final reportedContent = state.reportedContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Hub overview • demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Local prototype moderation and support summary. This is not a secured admin console.',
          ),
          const SizedBox(height: 16),
          Text(
            'Query trends',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final category in _ticketCategories)
            ListTile(
              title: Text(category),
              trailing: Text('${categoryCounts[category] ?? 0}'),
            ),
          const Divider(),
          Text(
            'Reported content (${reportedContent.length})',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (reportedContent.isEmpty)
            const ListTile(title: Text('No reports in this demo session.')),
          for (final report in reportedContent)
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(report),
              subtitle: const Text('Flagged for moderator review'),
            ),
          const SizedBox(height: 12),
          const Text(
            'Production moderation queues, account enforcement, and audit history require secured Hub staff access.',
          ),
        ],
      ),
    );
  }
}
