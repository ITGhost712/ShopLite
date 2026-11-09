import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _details;

  @override
  void initState() {
    super.initState();
    _details = context.read<ShopState>().fetchProduct(widget.product.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Product>(
    future: _details,
    builder: (context, snapshot) => _buildDetails(
      context,
      snapshot.data ?? widget.product,
      loading: snapshot.connectionState == ConnectionState.waiting,
      failed: snapshot.hasError,
    ),
  );

  Widget _buildDetails(
    BuildContext context,
    Product product, {
    required bool loading,
    required bool failed,
  }) {
    final favorite = context.select<ShopState, bool>(
      (state) => state.isFavorite(product),
    );
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('THE PRODUCT'),
        actions: [
          IconButton(
            tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () {
              context.read<ShopState>().toggleFavorite(product);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      favorite
                          ? 'Removed from favorites'
                          : 'Saved to favorites',
                    ),
                  ),
                );
            },
            icon: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.elasticOut,
              scale: favorite ? 1.15 : 1,
              child: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () {
            context.read<ShopState>().addToCart(product);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Added to your bag')),
              );
          },
          icon: const Icon(Icons.shopping_bag_outlined),
          label: const Text('Add to bag'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loading) const LinearProgressIndicator(),
            if (failed)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Showing the last available details.'),
                  TextButton(
                    onPressed: () => setState(() {
                      _details = context.read<ShopState>().fetchProduct(
                        product.id,
                      );
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            Container(
              height: (MediaQuery.sizeOf(context).width * .78).clamp(
                220.0,
                340.0,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surface,
                  ],
                ),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(16),
              child: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported_outlined, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.category.replaceAll('-', ' ').toUpperCase(),
              style: ShopType.eyebrow.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: ShopType.price.copyWith(
                    fontSize: 25,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.surface,
                    shape: StadiumBorder(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating.toStringAsFixed(1)} / 5',
                        style: ShopType.numerals.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            Text('A closer look', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${product.stock}',
                          style: ShopType.numerals.copyWith(fontSize: 14),
                        ),
                        const TextSpan(text: ' currently in stock'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
