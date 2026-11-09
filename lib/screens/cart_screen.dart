import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/collection_heading.dart';
import '../widgets/empty_state.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<ShopState>(
      builder: (context, shop, _) {
        if (shop.cart.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Your bag is empty',
            message:
                'Found something you love? Add it to your bag and it’ll be here when you’re ready.',
            action: embedded
                ? null
                : OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continue shopping'),
                  ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          children: [
            ...shop.cart.map((item) => _CartItemTile(item: item)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bag summary',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _PriceRow(label: 'Subtotal', value: shop.subtotal),
                  const SizedBox(height: 8),
                  const _PriceRow(label: 'Shipping', value: 0),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  _PriceRow(label: 'Total', value: shop.subtotal, bold: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            itemCount: shop.cartCount,
                            total: shop.subtotal,
                          ),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 14),
            child: CollectionHeading(
              label: 'YOUR SELECTION',
              title: 'Shopping bag',
            ),
          ),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: body,
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopState>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.network(
              item.product.thumbnail,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${item.product.price.toStringAsFixed(2)}',
                        style: ShopType.price.copyWith(fontSize: 12),
                      ),
                      const TextSpan(text: ' each'),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 9),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      tooltip: 'Decrease quantity',
                      onPressed: () =>
                          shop.changeQuantity(item.product, item.quantity - 1),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Padding(
                        key: ValueKey(item.quantity),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '${item.quantity}',
                          style: ShopType.numerals.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      tooltip: 'Increase quantity',
                      onPressed: () =>
                          shop.changeQuantity(item.product, item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Remove from cart',
                onPressed: () => shop.removeFromCart(item.product),
                icon: const Icon(Icons.delete_outline),
              ),
              Text('\$${item.total.toStringAsFixed(2)}', style: ShopType.price),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton.outlined(
    tooltip: tooltip,
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 17),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final double value;
  final bool bold;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: bold
                ? theme.textTheme.titleMedium
                : theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '\$${value.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: ShopType.price.copyWith(
              fontSize: bold ? 23 : 14,
              color: bold
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
