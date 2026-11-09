import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.index = 0});
  final Product product;
  final int index;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  var _shown = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      Duration(milliseconds: 70 * (widget.index.clamp(0, 6))),
      () {
        if (mounted) setState(() => _shown = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final colors = Theme.of(context).colorScheme;
    final favorite = context.select<ShopState, bool>(
      (state) => state.isFavorite(product),
    );
    return AnimatedSlide(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      offset: _shown ? Offset.zero : const Offset(0, .12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 420),
        opacity: _shown ? 1 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeTransition(
                    opacity: animation,
                    child: ProductDetailScreen(product: product),
                  ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.surfaceContainerHighest,
                            colors.surface,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(
                        product: product,
                        selected: favorite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: colors.primary, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: ShopType.numerals.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShopType.price.copyWith(
                        color: colors.onSurface,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.product, required this.selected});
  final Product product;
  final bool selected;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.ink.withValues(alpha: .72),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: selected ? 'Remove from favorites' : 'Add to favorites',
      onPressed: () {
        context.read<ShopState>().toggleFavorite(product);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                selected ? 'Removed from favorites' : 'Saved to favorites',
              ),
            ),
          );
      },
      icon: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.elasticOut,
        scale: selected ? 1.15 : 1,
        child: Icon(
          selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: selected ? AppColors.copper : AppColors.cream,
          size: 20,
        ),
      ),
    ),
  );
}
