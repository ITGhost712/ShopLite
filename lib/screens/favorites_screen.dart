import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../widgets/collection_heading.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<ShopState>(
      builder: (context, shop, _) {
        if (shop.favorites.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Nothing saved yet',
            message:
                'Tap the heart on something you love to find it here later.',
            action: embedded
                ? null
                : FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Explore products'),
                  ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth >= 720
                ? 4
                : constraints.maxWidth >= 480
                ? 3
                : 2;
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              itemCount: shop.favorites.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .76,
              ),
              itemBuilder: (_, index) =>
                  ProductCard(product: shop.favorites[index], index: index),
            );
          },
        );
      },
    );
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: CollectionHeading(
              label: 'YOUR COLLECTION',
              title: 'Saved favorites',
              description: 'Everything you’ve had your eye on.',
            ),
          ),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: body,
    );
  }
}
