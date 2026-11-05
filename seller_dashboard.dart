import 'package:flutter/material.dart';

import 'app_state.dart';
import 'deliveries_screen.dart';
import 'models.dart';
import 'seller_tools.dart';
import 'settings_screen.dart';
import 'vibe_features.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final List<_SellerListing> _listings = [
    const _SellerListing(
      title: 'Campus hoodie',
      price: 350,
      imagePath: 'lib/assets/hoodie.jpg',
      stock: 2,
    ),
    const _SellerListing(
      title: 'Custom study pack',
      price: 180,
      imagePath: 'lib/assets/full_module.jpg',
      stock: 0,
    ),
  ];

  Future<void> _createListing() async {
    final listing = await showDialog<_SellerListing>(
      context: context,
      builder: (_) => const _ListingEditor(),
    );
    if (listing != null && mounted) {
      setState(() => _listings.add(listing));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Listing created')));
    }
  }

  Future<void> _manageListings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _ManageListingsScreen(
          listings: List.of(_listings),
          onChanged: (listings) {
            if (mounted) {
              setState(() {
                _listings
                  ..clear()
                  ..addAll(listings);
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _viewOrders() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const _OrdersScreen()),
    );
  }

  void _showNotifications() {
    final orders = AppScope.read(context).orders;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery notifications'),
        content: SizedBox(
          width: 420,
          child: orders.isEmpty
              ? const Text('No order updates yet.')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final order in orders)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          order.status == DeliveryStatus.delivered
                              ? Icons.task_alt
                              : Icons.local_shipping_outlined,
                        ),
                        title: Text('${order.item} • ${order.status.label}'),
                        subtitle: Text(
                          order.status == DeliveryStatus.delivered
                              ? 'Successfully delivered'
                              : 'Delivery trip in progress • ETA ${order.estimatedDelivery}',
                        ),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = Theme.of(context).colorScheme;
    final openOrders = state.orders
        .where((order) => order.status.isOpen)
        .length;
    final grossSales = state.orders
        .where((order) => order.status != DeliveryStatus.cancelled)
        .fold<int>(0, (total, order) => total + order.amount);
    final lowStockCount = _listings
        .where((listing) => listing.stock <= 3)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Studio'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: Badge(
              isLabelVisible: openOrders > 0,
              label: Text('$openOrders'),
              child: const Icon(Icons.notifications_none_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your shop, at a glance',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Demo workspace • sales, stock, and orders at a glance.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _summary(
                    context,
                    'Active listings',
                    '${_listings.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summary(context, 'Open orders', '$openOrders'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summary(context, 'Demo gross sales', 'R$grossSales'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summary(context, 'Low-stock items', '$lowStockCount'),
                ),
              ],
            ),
            if (lowStockCount > 0) ...[
              const SizedBox(height: 12),
              Card(
                color: colors.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.warning_amber, color: colors.error),
                  title: Text('$lowStockCount listing(s) need restocking'),
                  subtitle: const Text(
                    'Restock or mark unavailable in Manage listings.',
                  ),
                  onTap: _manageListings,
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Seller tools',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _tool(
              context,
              Icons.add_box_outlined,
              'Create a listing',
              _createListing,
            ),
            _tool(
              context,
              Icons.inventory_2_outlined,
              'Manage listings',
              _manageListings,
            ),
            _tool(
              context,
              Icons.receipt_long_outlined,
              'View orders',
              _viewOrders,
            ),
            _tool(
              context,
              Icons.account_balance_wallet_outlined,
              'Sales & finances',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SellerFinancesScreen(),
                ),
              ),
            ),
            _tool(
              context,
              Icons.insights_outlined,
              'Insights & reviews',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SellerInsightsScreen(),
                ),
              ),
            ),
            _tool(
              context,
              Icons.bolt_outlined,
              'VibeWindows',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VibeWindowsScreen(sellerMode: true),
                ),
              ),
            ),
            _tool(
              context,
              Icons.handshake_outlined,
              'VibeCollabs',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VibeCollabsScreen(sellerMode: true),
                ),
              ),
            ),
            _tool(
              context,
              Icons.auto_awesome_outlined,
              'VibeCoach',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VibeCoachScreen(sellerMode: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _tool(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SellerListing {
  const _SellerListing({
    required this.title,
    required this.price,
    required this.imagePath,
    this.stock = 10,
    this.variants = '',
  });

  final String title;
  final int price;
  final String imagePath;
  final int stock;
  final String variants;

  _SellerListing copyWith({int? stock}) => _SellerListing(
    title: title,
    price: price,
    imagePath: imagePath,
    stock: stock ?? this.stock,
    variants: variants,
  );
}

class _ListingEditor extends StatefulWidget {
  const _ListingEditor({this.listing});

  final _SellerListing? listing;

  @override
  State<_ListingEditor> createState() => _ListingEditorState();
}

class _ListingEditorState extends State<_ListingEditor> {
  static const _images = {
    'Hoodie': 'lib/assets/hoodie.jpg',
    'Study pack': 'lib/assets/summary_pack.png',
    'Cake': 'lib/assets/custom_cake.jpg',
    'Nails': 'lib/assets/custom_nail_set.jpg',
  };

  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.listing?.title ?? '',
  );
  late final _priceController = TextEditingController(
    text: widget.listing?.price.toString() ?? '',
  );
  late final _stockController = TextEditingController(
    text: widget.listing?.stock.toString() ?? '10',
  );
  late final _variantsController = TextEditingController(
    text: widget.listing?.variants ?? '',
  );
  late String _imagePath = widget.listing?.imagePath ?? _images.values.first;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _variantsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _SellerListing(
        title: _titleController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        imagePath: _imagePath,
        stock: int.parse(_stockController.text.trim()),
        variants: _variantsController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.listing == null ? 'Create a listing' : 'Edit listing'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Listing name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a listing name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (R)'),
                validator: (value) {
                  final price = int.tryParse(value?.trim() ?? '');
                  return price == null || price <= 0
                      ? 'Enter a price greater than zero'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock quantity'),
                validator: (value) {
                  final stock = int.tryParse(value?.trim() ?? '');
                  return stock == null || stock < 0
                      ? 'Enter zero or more'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _variantsController,
                decoration: const InputDecoration(
                  labelText: 'Variants (optional)',
                  hintText: 'e.g. sizes S, M, L; colours navy, grey',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _imagePath,
                decoration: const InputDecoration(labelText: 'Photo'),
                items: [
                  for (final entry in _images.entries)
                    DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _imagePath = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _ManageListingsScreen extends StatefulWidget {
  const _ManageListingsScreen({
    required this.listings,
    required this.onChanged,
  });

  final List<_SellerListing> listings;
  final ValueChanged<List<_SellerListing>> onChanged;

  @override
  State<_ManageListingsScreen> createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<_ManageListingsScreen> {
  late final List<_SellerListing> _listings = List.of(widget.listings);

  Future<void> _edit(int index) async {
    final updated = await showDialog<_SellerListing>(
      context: context,
      builder: (_) => _ListingEditor(listing: _listings[index]),
    );
    if (updated == null || !mounted) return;
    setState(() => _listings[index] = updated);
    widget.onChanged(List.of(_listings));
  }

  Future<void> _delete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('Remove "${_listings[index].title}" from your shop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _listings.removeAt(index));
    widget.onChanged(List.of(_listings));
  }

  void _updateStock(int index, int delta) {
    final listing = _listings[index];
    setState(() {
      _listings[index] = listing.copyWith(
        stock: (listing.stock + delta).clamp(0, 9999).toInt(),
      );
    });
    widget.onChanged(List.of(_listings));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage listings')),
      body: _listings.isEmpty
          ? const Center(
              child: Text('No listings yet. Create one to get started.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listings.length,
              itemBuilder: (context, index) {
                final listing = _listings[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(listing.imagePath),
                    ),
                    title: Text(listing.title),
                    subtitle: Text(
                      'R${listing.price} • Stock ${listing.stock}'
                      '${listing.variants.isEmpty ? '' : '\n${listing.variants}'}'
                      '${listing.stock == 0
                          ? ' • SOLD OUT'
                          : listing.stock <= 3
                          ? ' • LOW STOCK'
                          : ''}',
                    ),
                    isThreeLine: listing.variants.isNotEmpty,
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Restock ${listing.title} by 5',
                          onPressed: () => _updateStock(index, 5),
                          icon: const Icon(Icons.add_box_outlined),
                        ),
                        IconButton(
                          tooltip: 'Edit ${listing.title}',
                          onPressed: () => _edit(index),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete ${listing.title}',
                          onPressed: () => _delete(index),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _OrdersScreen extends StatelessWidget {
  const _OrdersScreen();

  Future<String?> _editOrderNote(BuildContext context, CampusOrder order) {
    final controller = TextEditingController(text: order.sellerNote);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order notes and arrangement'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add collection point, delivery plan, or order note',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save note'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _rejectOrder(
    BuildContext context,
    AppState state,
    CampusOrder order,
  ) async {
    final reason = await _editOrderNote(context, order);
    if (reason == null || !context.mounted) return;
    state.updateOrder(
      order.id,
      status: DeliveryStatus.cancelled,
      sellerNote: reason.isEmpty ? 'Cancelled by seller' : reason,
    );
  }

  Future<void> _saveOrderNote(
    BuildContext context,
    AppState state,
    CampusOrder order,
  ) async {
    final note = await _editOrderNote(context, order);
    if (note == null || !context.mounted) return;
    state.updateOrder(order.id, status: order.status, sellerNote: note);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          final nextStatus = order.status.next;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.id,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Chip(label: Text(order.status.label)),
                    ],
                  ),
                  Text(
                    '${order.buyerName} • ${order.item} × ${order.quantity}',
                  ),
                  if (order.isAppointment) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Appointment: ${order.appointmentAt}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (order.sellerNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Order note: ${order.sellerNote}'),
                  ],
                  const SizedBox(height: 16),
                  if (order.status != DeliveryStatus.cancelled) ...[
                    DeliveryProgress(status: order.status),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    order.status == DeliveryStatus.delivered
                        ? 'Successfully delivered'
                        : order.status == DeliveryStatus.cancelled
                        ? 'Order cancelled'
                        : 'Arrangement: ${order.estimatedDelivery}',
                    style: TextStyle(
                      color: order.status == DeliveryStatus.delivered
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (order.status == DeliveryStatus.newOrder) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _rejectOrder(context, state, order),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () => state.updateOrder(
                            order.id,
                            status: DeliveryStatus.preparing,
                          ),
                          child: const Text('Accept & prepare'),
                        ),
                      ],
                    ),
                  ] else if (order.status.isOpen) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              _saveOrderNote(context, state, order),
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Add order note'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () =>
                              state.updateOrder(order.id, status: nextStatus),
                          child: Text('Mark ${nextStatus.label.toLowerCase()}'),
                        ),
                      ],
                    ),
                  ] else if (order.status == DeliveryStatus.cancelled) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _saveOrderNote(context, state, order),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('View cancellation note'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
