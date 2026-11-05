import 'package:flutter/material.dart';

import '../screens/app_state.dart';
import '../screens/buyer_tools.dart';
import '../screens/buyer_checkout.dart';
import '../screens/mock_data.dart';
import '../screens/models.dart';

void main() {
  runApp(const VossiesApp());
}

class VossiesApp extends StatelessWidget {
  const VossiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vossie\'s Vibe',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A2240), // Dark Navy from mockup
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto', // Replace with your custom font if you have one
      ),
      home: const SellerProfileScreen(),
    );
  }
}

class SellerOffering {
  final String title;
  final String price;
  final String imagePath;

  const SellerOffering({
    required this.title,
    required this.price,
    required this.imagePath,
  });
}

class SellerProfileData {
  final String name;
  final String handle;
  final String subtitle;
  final String about;
  final String rating;
  final String offeringsLabel;
  final String imagePath;
  final String? bannerImagePath;
  final List<SellerOffering> offerings;
  final List<SellerReview> reviews;
  final List<String> perks;
  final List<String> searchTerms;

  const SellerProfileData({
    required this.name,
    required this.handle,
    required this.subtitle,
    required this.about,
    required this.rating,
    required this.offeringsLabel,
    required this.imagePath,
    this.bannerImagePath,
    required this.offerings,
    this.reviews = const [],
    required this.perks,
    this.searchTerms = const [],
  });
}

const _tombiProfile = SellerProfileData(
  name: 'Tombi\'s Nails',
  handle: '@tombisnails',
  subtitle: 'Beauty • Nails • Durban Campus',
  about: 'I\'m Tombi, your campus nail girl. I do gel, acrylic, custom sets and more. Book your spot now! Good nails = good mood.',
  rating: '4.9 (124 reviews)',
  offeringsLabel: 'Services',
  imagePath: 'lib/assets/nail_profilepic.jpg',
  offerings: [
    SellerOffering(
      title: 'French Tips',
      price: 'R150',
      imagePath: 'lib/assets/french_tips.jpg',
    ),
    SellerOffering(
      title: 'Acrylics',
      price: 'R220',
      imagePath: 'lib/assets/acrylic_set.jpg',
    ),
    SellerOffering(
      title: 'Custom Set',
      price: 'R280',
      imagePath: 'lib/assets/custom_nail_set.jpg',
    ),
    SellerOffering(
      title: 'Gel Overlay',
      price: 'R200',
      imagePath: 'lib/assets/gel_overlay.jpg',
    ),
  ],
  perks: [
    'Student Entrepreneur',
    'Fast & Friendly Service',
    'Book via DM or WhatsApp',
  ],
);

const List<SellerProfileData> sellerProfiles = [
  _tombiProfile,
  SellerProfileData(
    name: 'Lebo\'s Clothes',
    handle: '@lebosclothes',
    subtitle: 'Clothing • Durban Campus',
    about: 'I curate affordable campus outfits, from everyday basics to standout vintage finds. Message me for sizes and measurements.',
    rating: '4.8 (52 reviews)',
    offeringsLabel: 'Products',
    imagePath: 'lib/assets/clothes_profile.jpg',
    offerings: [
      SellerOffering(
        title: 'Vintage Jacket',
        price: 'R450',
        imagePath: 'lib/assets/vintage.png',
      ),
      SellerOffering(
        title: 'Everyday Outfit',
        price: 'R300',
        imagePath: 'lib/assets/basic_fit.jpg',
      ),
      SellerOffering(
        title: 'Thrifted Finds',
        price: 'From R150',
        imagePath: 'lib/assets/thrifted.jpg',
      ),
    ],
    perks: [
      'Fresh styles every week',
      'Student-friendly prices',
      'Campus meet-ups',
    ],
    searchTerms: ['clothes', 'fashion', 'apparel'],
  ),
  SellerProfileData(
    name: 'Key\'s Cakes',
    handle: '@keyscakes',
    subtitle: 'Food • Cakes • Durban Campus',
    about: 'I bake celebration cakes and sweet treats fresh to order. Get in touch with your flavour and design ideas for a custom cake.',
    rating: '4.9 (76 reviews)',
    offeringsLabel: 'Products',
    imagePath: 'lib/assets/cake_profile.jpg',
    offerings: [
      SellerOffering(
        title: 'Cupcake Box',
        price: 'R120',
        imagePath: 'lib/assets/cupcake_box.jpg',
      ),
      SellerOffering(
        title: 'Caramel Drip Cake',
        price: 'R350',
        imagePath: 'lib/assets/caramel.jpg',
      ),
      SellerOffering(
        title: 'Custom Celebration Cake',
        price: 'From R380',
        imagePath: 'lib/assets/custom_cake.jpg',
      ),
    ],
    perks: ['Baked fresh to order', 'Custom designs', 'Campus delivery'],
  ),
  SellerProfileData(
    name: 'Ariel\'s Cookies',
    handle: '@arielscookies',
    subtitle: 'Food • Cookies • Durban Campus',
    about: 'Freshly baked cookies for study breaks, sharing, or a little treat between lectures. Ask me about this week\'s flavours.',
    rating: '4.8 (64 reviews)',
    offeringsLabel: 'Products',
    imagePath: 'lib/assets/cookies_profile.jpg',
    offerings: [
      SellerOffering(
        title: 'Choc Chip Cookies',
        price: 'R50',
        imagePath: 'lib/assets/cookies_profile.jpg',
      ),
      SellerOffering(
        title: 'Double Chocolate Box',
        price: 'R80',
        imagePath: 'lib/assets/double_choc.jpg',
      ),
      SellerOffering(
        title: 'Mixed Cookie Dozen',
        price: 'R120',
        imagePath: 'lib/assets/mixed_dozen.jpg',
      ),
    ],
    perks: ['Baked fresh daily', 'Great for sharing', 'Easy campus pick-up'],
  ),
  SellerProfileData(
    name: 'Mason\'s Shoe Store',
    handle: '@masonsshoes',
    subtitle: 'Footwear • Durban Campus',
    about: 'Find your next everyday pair here, from laid-back campus sneakers to comfortable slides. Message me to check sizes in stock.',
    rating: '4.7 (48 reviews)',
    offeringsLabel: 'Products',
    imagePath: 'lib/assets/shoes_profile.jpg',
    offerings: [
      SellerOffering(
        title: 'Campus Sneakers',
        price: 'R650',
        imagePath: 'lib/assets/campus_sneakers.jpg',
      ),
      SellerOffering(
        title: 'Everyday Shoes',
        price: 'R500',
        imagePath: 'lib/assets/everyday_shoes.jpg',
      ),
      SellerOffering(
        title: 'Comfort Slides',
        price: 'R250',
        imagePath: 'lib/assets/comfort_slides.jpg',
      ),
    ],
    perks: [
      'Multiple sizes available',
      'Student-friendly prices',
      'Campus meet-ups',
    ],
    searchTerms: ['shoes', 'sneakers', 'footwear'],
  ),
];

List<SellerProfileData> get searchableSellerProfiles {
  return [for (final seller in kSellers) sellerProfileFromSeller(seller)];
}

SellerProfileData sellerProfileFromSeller(Seller seller) {
  return SellerProfileData(
    name: seller.name,
    handle: seller.handle,
    subtitle: '${seller.subtitle} • ${seller.campus}',
    about: seller.about,
    rating: '${seller.rating} (${seller.reviews} reviews)',
    offeringsLabel: seller.offeringsLabel,
    imagePath: seller.imagePath,
    bannerImagePath: seller.bannerImagePath,
    offerings: [
      for (final offering in seller.offerings)
        SellerOffering(
          title: offering.name,
          price: 'R${offering.price}',
          imagePath: offering.imagePath,
        ),
    ],
    reviews: kMockSellerReviews[seller.id] ?? const [],
    perks: seller.perks,
    searchTerms: [seller.category.label, seller.campus, seller.tagline],
  );
}

bool sellerProfileMatches(SellerProfileData profile, String query) {
  final terms = _normalizeSearchText(query)
      .split(' ')
      .where((term) => term.isNotEmpty);
  if (terms.isEmpty) return true;

  final searchableText = _normalizeSearchText(
    [
      profile.name,
      profile.handle,
      profile.subtitle,
      profile.about,
      ...profile.searchTerms,
      ...profile.offerings.map((offering) => offering.title),
      ...profile.perks,
    ].join(' '),
  );
  return terms.every(searchableText.contains);
}

String _normalizeSearchText(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key, this.profile = _tombiProfile});

  final SellerProfileData profile;

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  Future<void> _chooseSellerProfile() async {
    final appState = AppScope.read(context);
    final profile = await showModalBottomSheet<SellerProfileData>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Seller profiles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (final seller
                in appState.sellers.map(sellerProfileFromSeller))
              if (seller.handle != widget.profile.handle)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: imageProviderFor(seller.imagePath),
                  ),
                  title: Text(seller.name),
                  subtitle: Text(seller.subtitle),
                  onTap: () => Navigator.pop(context, seller),
                ),
          ],
        ),
      ),
    );

    if (profile == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProfileScreen(profile: profile),
      ),
    );
  }

  void _messageSeller() {
    final state = AppScope.read(context);
    final seller = state.sellers.firstWhere(
      (seller) => seller.handle == widget.profile.handle,
    );
    final thread = state.threadFor(seller);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DirectMessageScreen(thread: thread),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final appState = AppScope.of(context);
    final colors = Theme.of(context).colorScheme;
    final isFollowing = appState.following.contains(profile.handle);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // 1. Custom App Bar with Profile Info
            SliverAppBar(
              expandedHeight: 260.0,
              floating: false,
              pinned: true,
              backgroundColor: colors.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: _chooseSellerProfile,
                ),
                IconButton(
                  tooltip: 'Shopping cart',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BuyerCartScreen(),
                    ),
                  ),
                  icon: Badge(
                    isLabelVisible: appState.cartItemCount > 0,
                    label: Text('${appState.cartItemCount}'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Image(
                      image: imageProviderFor(
                        profile.bannerImagePath ?? profile.imagePath,
                      ),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    // Profile Picture
                    Positioned(
                      bottom: 0,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: imageProviderFor(
                                profile.imagePath,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            profile.handle,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Details, Ratings & Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            profile.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: colors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified Student Seller',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: colors.primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          profile.rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                appState.toggleFollow(profile.handle),
                            icon: Icon(
                              isFollowing
                                  ? Icons.person_remove
                                  : Icons.person_add,
                              size: 18,
                            ),
                            label: Text(isFollowing ? 'Following' : 'Follow'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _messageSeller,
                            icon: const Icon(Icons.message_outlined, size: 18),
                            label: const Text('Message'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.primary,
                              side: BorderSide(color: colors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 3. Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.onSurfaceVariant,
                  indicatorColor: colors.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'About'),
                    Tab(text: profile.offeringsLabel),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Posts'),
                  ],
                ),
              ),
            ),

            // 4. Tab Bar Content
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  // ABOUT TAB
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Hey Vossies! 👋',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.about,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      for (final perk in profile.perks) ...[
                        _buildFeatureRow(Icons.check_circle_outline, perk),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),

                  // Seller offerings
                  _buildOfferings(context, profile, appState),

                  _buildReviews(context, profile),

                  _buildPosts(
                    context,
                    appState.posts
                        .where(
                          (post) =>
                              post.sellerId ==
                              appState.sellers
                                  .firstWhere(
                                    (seller) => seller.handle == profile.handle,
                                  )
                                  .id,
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferings(
    BuildContext context,
    SellerProfileData profile,
    AppState appState,
  ) {
    final colors = Theme.of(context).colorScheme;
    final seller = appState.sellers.firstWhere(
      (seller) => seller.handle == profile.handle,
    );
    if (appState.businessLayout == BusinessLayout.list) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: profile.offerings.length,
        itemBuilder: (context, index) {
          final item = profile.offerings[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: Image(
                image: imageProviderFor(item.imagePath),
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
              title: Text(item.title),
              subtitle: Text(
                item.price,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: IconButton.filledTonal(
                tooltip: seller.type == ListingType.service
                    ? 'Choose appointment time'
                    : 'Add to cart',
                onPressed: () => _addOfferingToCart(context, profile, index),
                icon: Icon(
                  seller.type == ListingType.service
                      ? Icons.calendar_month_outlined
                      : Icons.add_shopping_cart,
                ),
              ),
            ),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: profile.offerings.length,
      itemBuilder: (context, index) {
        final item = profile.offerings[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image(
                  image: imageProviderFor(item.imagePath),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.price,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            _addOfferingToCart(context, profile, index),
                        icon: Icon(
                          seller.type == ListingType.service
                              ? Icons.calendar_month_outlined
                              : Icons.add_shopping_cart,
                          size: 18,
                        ),
                        label: Text(
                          seller.type == ListingType.service ? 'Book' : 'Add',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addOfferingToCart(
    BuildContext context,
    SellerProfileData profile,
    int index,
  ) {
    final state = AppScope.read(context);
    final seller = state.sellers.firstWhere(
      (seller) => seller.handle == profile.handle,
    );
    final offering = seller.offerings[index];
    if (seller.type == ListingType.service) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ServiceBookingScreen(seller: seller, offering: offering),
        ),
      );
      return;
    }

    state.addToCart(
      CartItem(
        id: '${seller.id}-${offering.name}',
        sellerId: seller.id,
        offeringName: offering.name,
        price: offering.price,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${offering.name} added to your cart.')),
    );
  }

  Widget _buildReviews(BuildContext context, SellerProfileData profile) {
    final colors = Theme.of(context).colorScheme;
    if (profile.reviews.isEmpty) {
      return const Center(child: Text('No reviews yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: colors.primary, size: 30),
                const SizedBox(width: 8),
                Text(
                  profile.rating,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '${profile.reviews.length} recent reviews',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        for (final review in profile.reviews)
          Card(
            margin: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          review.author,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        review.dateLabel,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(review.comment),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPosts(BuildContext context, List<SellerPost> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet.'));
    }

    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                post.imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.caption),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text('${post.likes}'),
                        const Spacer(),
                        Text(
                          post.dateLabel,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: colors.onSurface, fontSize: 13)),
      ],
    );
  }
}

// Helper class to keep the TabBar pinned at the top when scrolling
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
