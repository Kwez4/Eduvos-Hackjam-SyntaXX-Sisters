import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'app_state.dart';
import 'models.dart';

class VibeWindowsScreen extends StatefulWidget {
  const VibeWindowsScreen({super.key, this.sellerMode = false});

  final bool sellerMode;

  @override
  State<VibeWindowsScreen> createState() => _VibeWindowsScreenState();
}

class _VibeWindowsScreenState extends State<VibeWindowsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  String _sellerId = 's3';
  DateTime _availableAt = DateTime.now().add(const Duration(hours: 2));
  String _timeFilter = 'Any time';

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _chooseDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      initialDate: _availableAt.isBefore(now)
          ? now
          : DateUtils.dateOnly(_availableAt),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_availableAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _availableAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _postWindow(AppState state) {
    if (!widget.sellerMode) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_availableAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future availability time.')),
      );
      return;
    }
    state.postVibeWindow(
      VibeWindow(
        id: 'window-${DateTime.now().microsecondsSinceEpoch}',
        sellerId: _sellerId,
        details: _detailsController.text.trim(),
        availableAt: _availableAt,
      ),
    );
    _detailsController.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Availability posted')));
  }

  bool _matchesTime(DateTime dateTime) => switch (_timeFilter) {
    'Morning' => dateTime.hour < 12,
    'Midday' => dateTime.hour >= 12 && dateTime.hour < 15,
    'Afternoon' => dateTime.hour >= 15,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final sellers = state.sellers;
    if (!sellers.any((seller) => seller.id == _sellerId)) {
      _sellerId = sellers.first.id;
    }
    final windows =
        state.vibeWindows
            .where(
              (window) =>
                  window.availableAt.isAfter(DateTime.now()) &&
                  _matchesTime(window.availableAt) &&
                  (state.campus == kAllCampuses ||
                      state.sellerById(window.sellerId).campus == state.campus),
            )
            .toList()
          ..sort(
            (first, second) => first.availableAt.compareTo(second.availableAt),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('VibeWindows')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Find what’s available when it works for you.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (widget.sellerMode)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Post an availability window',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _sellerId,
                        decoration: const InputDecoration(
                          labelText: 'Business',
                        ),
                        items: [
                          for (final seller in sellers)
                            DropdownMenuItem(
                              value: seller.id,
                              child: Text(seller.name),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _sellerId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _detailsController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'What’s available?',
                          hintText: 'Two cake boxes ready before 12',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Add a short availability note.'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _chooseDateTime,
                        icon: const Icon(Icons.schedule_outlined),
                        label: Text(
                          DateFormat('EEE d MMM • HH:mm').format(_availableAt),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => _postWindow(state),
                        child: const Text('Post window'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Browse availability',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final filter in [
                'Any time',
                'Morning',
                'Midday',
                'Afternoon',
              ])
                ChoiceChip(
                  label: Text(filter),
                  selected: _timeFilter == filter,
                  onSelected: (_) => setState(() => _timeFilter = filter),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (windows.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No upcoming windows match this time and campus.'),
              ),
            )
          else
            for (final window in windows)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.bolt_outlined)),
                  title: Text(window.details),
                  subtitle: Text(
                    '${state.sellerById(window.sellerId).name} • '
                    '${DateFormat('EEE d MMM, HH:mm').format(window.availableAt)}',
                  ),
                  isThreeLine: true,
                ),
              ),
        ],
      ),
    );
  }
}

class VibeCollabsScreen extends StatefulWidget {
  const VibeCollabsScreen({super.key, this.sellerMode = false});

  final bool sellerMode;

  @override
  State<VibeCollabsScreen> createState() => _VibeCollabsScreenState();
}

class _VibeCollabsScreenState extends State<VibeCollabsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final Set<String> _selectedSellerIds = {};
  final Map<String, String> _contributions = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _publish(AppState state) {
    if (!widget.sellerMode) return;
    if (_selectedSellerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least two businesses.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final partners = [
      for (final sellerId in _selectedSellerIds)
        CollabPartner(
          sellerId: sellerId,
          contribution: _contributions[sellerId]!.trim(),
        ),
    ];
    state.publishCollaborativeOffer(
      CollaborativeOffer(
        id: 'collab-${DateTime.now().microsecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        partners: partners,
      ),
    );
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _selectedSellerIds.clear();
    _contributions.clear();
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Joint offer published')));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final offers = state.collaborativeOffers;

    return Scaffold(
      appBar: AppBar(title: const Text('VibeCollabs')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.sellerMode
                ? 'Create a joint offer and help students discover each other’s businesses.'
                : 'Explore joint offers from student businesses.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (widget.sellerMode)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Build a collaborative offer',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final seller in state.sellers) ...[
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(seller.name),
                          value: _selectedSellerIds.contains(seller.id),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedSellerIds.add(seller.id);
                              } else {
                                _selectedSellerIds.remove(seller.id);
                                _contributions.remove(seller.id);
                              }
                            });
                          },
                        ),
                        if (_selectedSellerIds.contains(seller.id))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextFormField(
                              initialValue: _contributions[seller.id],
                              decoration: InputDecoration(
                                labelText: '${seller.name}’s contribution',
                                hintText: 'What will this business provide?',
                              ),
                              onChanged: (value) =>
                                  _contributions[seller.id] = value,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Describe this business’s contribution.'
                                  : null,
                            ),
                          ),
                      ],
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Offer name',
                          hintText: 'Study break bundle',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Add an offer name.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Offer details',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Add a short description.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bundle price (R)',
                        ),
                        validator: (value) {
                          final price = int.tryParse(value ?? '');
                          return price == null || price <= 0
                              ? 'Enter a price greater than R0.'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _publish(state),
                        child: const Text('Publish joint offer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Discover collaborations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final offer in offers)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          'R${offer.price}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(offer.description),
                    const Divider(height: 20),
                    for (final partner in offer.partners)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.handshake_outlined, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${state.sellerById(partner.sellerId).name}: '
                                '${partner.contribution}',
                              ),
                            ),
                          ],
                        ),
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

class VibeCoachScreen extends StatefulWidget {
  const VibeCoachScreen({super.key, this.sellerMode = false});

  final bool sellerMode;

  @override
  State<VibeCoachScreen> createState() => _VibeCoachScreenState();
}

class _VibeCoachScreenState extends State<VibeCoachScreen> {
  final _itemController = TextEditingController(text: 'Cupcake box (6)');
  final _descriptionController = TextEditingController(
    text: 'Freshly baked treats for a study break.',
  );
  final _priceController = TextEditingController(text: '120');
  String _sellerId = 's3';
  String _goal = 'Description';
  String? _advice;

  @override
  void dispose() {
    _itemController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _createAdvice(AppState state) {
    final item = _itemController.text.trim();
    final details = _descriptionController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final seller = state.sellerById(_sellerId);
    if (item.isEmpty) return 'Add an item or service name first.';

    return switch (_goal) {
      'Description' =>
        '$item from ${seller.name} at ${seller.campus}. '
            '${details.isEmpty ? 'Made for busy campus days.' : details} '
            'Message the business to ask a question or arrange collection.',
      'Promotion' =>
        'Ideas for promoting $item:\n'
            '• Offer a small bundle with a complementary campus business.\n'
            '• Share a limited-time pickup window between lectures.\n'
            '• Invite returning customers to bring a friend.\n'
            'Keep the offer clear, time-limited, and easy to redeem.',
      _ when price == null || price <= 0 =>
        'Enter a valid current price to get a simple price range.',
      _ =>
        'A simple test range for $item is R${((price * 1.1) / 5).round() * 5} '
            'to R${((price * 1.25) / 5).round() * 5}. '
            'Before choosing a price, account for materials, your time, '
            'packaging, delivery, and any platform fees.',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.sellerMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('VibeCoach')),
        body: const Center(child: Text('VibeCoach is available to sellers.')),
      );
    }

    final state = AppScope.of(context);
    if (!state.sellers.any((seller) => seller.id == _sellerId)) {
      _sellerId = state.sellers.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('VibeCoach')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Practical ideas to help your student business stand out.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _sellerId,
                    decoration: const InputDecoration(labelText: 'Business'),
                    items: [
                      for (final seller in state.sellers)
                        DropdownMenuItem(
                          value: seller.id,
                          child: Text(seller.name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _sellerId = value;
                        _advice = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final goal in [
                        'Description',
                        'Promotion',
                        'Pricing',
                      ])
                        ChoiceChip(
                          label: Text(goal),
                          selected: _goal == goal,
                          onSelected: (_) => setState(() {
                            _goal = goal;
                            _advice = null;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Product or service',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Current description or details',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current price (R)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        setState(() => _advice = _createAdvice(state)),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Get suggestions'),
                  ),
                ],
              ),
            ),
          ),
          if (_advice != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_advice!),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _advice!),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Suggestions copied'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copy'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
