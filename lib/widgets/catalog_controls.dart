import 'package:flutter/material.dart';

import '../models/product_catalog.dart';
import '../state/shop_state.dart';

class CatalogControls extends StatelessWidget {
  const CatalogControls({super.key, required this.shop});

  final ShopState shop;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: shop.categoriesFailed
            ? OutlinedButton.icon(
                onPressed: shop.loadCategories,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry categories'),
              )
            : PopupMenuButton<String>(
                tooltip: 'Filter by category',
                constraints: BoxConstraints(
                  minWidth: 112,
                  maxWidth: 280,
                  maxHeight: (MediaQuery.sizeOf(context).height * .45).clamp(
                    0.0,
                    280.0,
                  ),
                ),
                enabled: !shop.loadingCategories && shop.categories.isNotEmpty,
                initialValue: shop.category?.slug ?? '',
                onSelected: (slug) => shop.selectCategory(
                  slug.isEmpty
                      ? null
                      : shop.categories.firstWhere((item) => item.slug == slug),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '', child: Text('All categories')),
                  for (final category in shop.categories)
                    PopupMenuItem(
                      value: category.slug,
                      child: Text(category.name),
                    ),
                ],
                child: _ControlLabel(
                  icon: Icons.grid_view_rounded,
                  label: shop.loadingCategories
                      ? 'Loading categories'
                      : shop.category?.name ?? 'All categories',
                ),
              ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: PopupMenuButton<ProductSort>(
          tooltip: 'Sort products',
          initialValue: shop.sort,
          onSelected: shop.selectSort,
          itemBuilder: (context) => [
            for (final sort in ProductSort.values)
              PopupMenuItem(value: sort, child: Text(sort.label)),
          ],
          child: _ControlLabel(
            icon: Icons.swap_vert_rounded,
            label: shop.sort == ProductSort.featured
                ? 'Sort by'
                : shop.sort.label,
          ),
        ),
      ),
    ],
  );
}

class _ControlLabel extends StatelessWidget {
  const _ControlLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.expand_more_rounded, size: 18),
        ],
      ),
    );
  }
}
