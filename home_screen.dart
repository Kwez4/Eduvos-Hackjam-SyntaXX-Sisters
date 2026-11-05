import 'package:flutter/material.dart';

import '../profiles/seller_profile_screen.dart';
import 'app_state.dart';
import 'buyer_tools.dart';
import 'buyer_checkout.dart';
import 'campus_events_screen.dart';
import 'deliveries_screen.dart';
import 'models.dart';
import 'saved_sellers_screen.dart';
import 'settings_screen.dart';
import 'support_agent.dart';
import 'vibe_features.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Category? _selectedCategory;
  SortBy _sortBy = SortBy.popular;
  int _maxPrice = 1000;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSellerProfile(SellerProfileData profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProfileScreen(profile: profile),
      ),
    );
  }

  Future<void> _showMarketplaceFilters() async {
    var maxPrice = _maxPrice;
    var sortBy = _sortBy;
    final result = await showModalBottomSheet<(int, SortBy)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filter and sort',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SortBy>(
                  initialValue: sortBy,
                  decoration: const InputDecoration(labelText: 'Sort by'),
                  items: [
                    for (final option in SortBy.values)
                      DropdownMenuItem(
                        value: option,
                        child: Text(option.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => sortBy = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('Maximum price: R$maxPrice'),
                Slider(
                  value: maxPrice.toDouble(),
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: 'R$maxPrice',
                  onChanged: (value) =>
                      setSheetState(() => maxPrice = (value / 50).round() * 50),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, (maxPrice, sortBy)),
                  child: const Text('Apply filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _maxPrice = result.$1;
        _sortBy = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final deliveryCount = appState.inProgressBuyerOrders.length;
    final profiles = appState.sellers
        .map(sellerProfileFromSeller)
        .where((profile) {
          if (!sellerProfileMatches(profile, _searchQuery)) return false;
          final seller = appState.sellers.firstWhere(
            (seller) => seller.handle == profile.handle,
          );
          if (appState.campus != kAllCampuses &&
              seller.campus != appState.campus) {
            return false;
          }
          if (_selectedCategory != null &&
              seller.category != _selectedCategory) {
            return false;
          }
          return seller.startingPrice <= _maxPrice;
        }).toList()..sort((first, second) {
          final firstSeller = appState.sellers.firstWhere(
            (seller) => seller.handle == first.handle,
          );
          final secondSeller = appState.sellers.firstWhere(
            (seller) => seller.handle == second.handle,
          );
          return switch (_sortBy) {
            SortBy.popular => secondSeller.reviews.compareTo(
              firstSeller.reviews,
            ),
            SortBy.rating => secondSeller.rating.compareTo(firstSeller.rating),
            SortBy.priceLow => firstSeller.startingPrice.compareTo(
              secondSeller.startingPrice,
            ),
          };
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Shopping cart',
            icon: Badge(
              isLabelVisible: appState.cartItemCount > 0,
              label: Text('${appState.cartItemCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BuyerCartScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Filter and sort businesses',
            icon: Badge(
              isLabelVisible: _selectedCategory != null || _maxPrice < 1000,
              child: const Icon(Icons.tune),
            ),
            onPressed: _showMarketplaceFilters,
          ),
          IconButton(
            tooltip: 'Campus events',
            icon: const Icon(Icons.event_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CampusEventsScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'My orders',
            icon: Badge(
              isLabelVisible: deliveryCount > 0,
              label: Text('$deliveryCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DeliveriesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Seller videos',
            icon: const Icon(Icons.video_library_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SellerVideoFeed()),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your campus marketplace is ready.',
                style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search businesses or services',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: appState.campus,
                decoration: const InputDecoration(
                  labelText: 'Campus',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  isDense: true,
                ),
                items: [
                  for (final campus in kCampuses)
                    DropdownMenuItem(value: campus, child: Text(campus)),
                ],
                onChanged: (campus) {
                  if (campus != null) appState.setCampus(campus);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    for (final category in Category.values)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(category.label),
                          selected: _selectedCategory == category,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marketplace Highlights',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '• Student essentials\n• Campus events\n• Buy and sell locally\n• Meet people from your faculty',
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.onSurfaceVariant,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const CampusEventsScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.event_outlined),
                            label: const Text('Explore campus events'),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const PrivateMessagesScreen(),
                                  ),
                                ),
                                icon: Badge(
                                  isLabelVisible: appState.totalUnread > 0,
                                  label: Text('${appState.totalUnread}'),
                                  child: const Icon(Icons.chat_bubble_outline),
                                ),
                                label: const Text('Messages'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const HelpCentreScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.help_outline),
                                label: const Text('Help & support'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const SavedSellersScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.bookmark_border),
                                label: const Text('Saved businesses'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const VibeWindowsScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.bolt_outlined),
                                label: const Text('VibeWindows'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const VibeCollabsScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.handshake_outlined),
                                label: const Text('VibeCollabs'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Campus Drops • limited-time offers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final drop in appState.drops)
                      if (appState.campus == kAllCampuses ||
                          appState.sellerById(drop.sellerId).campus ==
                              appState.campus)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.local_offer_outlined),
                            title: Text(drop.text),
                            subtitle: Text(
                              '${appState.sellerById(drop.sellerId).name} • ${drop.when}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openSellerProfile(
                              sellerProfileFromSeller(
                                appState.sellerById(drop.sellerId),
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 16),
                    Text(
                      'Seller profiles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (profiles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.trim().isEmpty
                                  ? 'No sellers available.'
                                  : 'Service not found or unavailable. Try another search.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (appState.businessLayout == BusinessLayout.grid)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: profiles.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.9,
                            ),
                        itemBuilder: (context, index) =>
                            _sellerCard(context, profiles[index], true),
                      )
                    else
                      for (final profile in profiles)
                        _sellerCard(context, profile, false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sellerCard(
    BuildContext context,
    SellerProfileData profile,
    bool isGrid,
  ) {
    final colors = Theme.of(context).colorScheme;
    if (!isGrid) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: imageProviderFor(profile.imagePath),
          ),
          title: Text(
            profile.name,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            profile.subtitle,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          onTap: () => _openSellerProfile(profile),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openSellerProfile(profile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image(
                image: imageProviderFor(profile.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
