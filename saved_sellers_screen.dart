import 'package:flutter/material.dart';

import '../profiles/seller_profile_screen.dart';
import 'app_state.dart';
import 'models.dart';

class SavedSellersScreen extends StatelessWidget {
  const SavedSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellers = AppScope.of(context).savedSellers;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved businesses')),
      body: sellers.isEmpty
          ? const Center(
              child: Text('Save a seller profile to add it to your wishlist.'),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final seller in sellers)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageProviderFor(seller.imagePath),
                      ),
                      title: Text(seller.name),
                      subtitle: Text(
                        '${seller.category.label} • From R${seller.startingPrice}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SellerProfileScreen(
                            profile: sellerProfileFromSeller(seller),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
