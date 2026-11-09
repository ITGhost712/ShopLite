import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/campaign_carousel.dart';
import '../widgets/catalog_controls.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  int _index = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ProductListing(search: _search),
      const FavoritesScreen(embedded: true),
      const CartScreen(embedded: true),
    ];
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.03, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Consumer<ShopState>(
              builder: (context, state, child) => Badge(
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                isLabelVisible: state.cartCount > 0,
                label: Text(
                  '${state.cartCount}',
                  style: ShopType.numerals.copyWith(fontSize: 11),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            selectedIcon: const Icon(Icons.shopping_bag_rounded),
            label: 'Bag',
          ),
        ],
      ),
    );
  }
}

class _ProductListing extends StatelessWidget {
  const _ProductListing({required this.search});
  final TextEditingController search;

  @override
  Widget build(BuildContext context) => Consumer<ShopState>(
    builder: (context, shop, child) {
      final showCampaign = shop.query.isEmpty && shop.category == null;
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeReveal(
                    delay: Duration.zero,
                    child: Row(
                      children: [
                        const Expanded(child: _BrandLockup()),
                        _RoundIconButton(
                          icon: shop.isLightMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          tooltip: shop.isLightMode
                              ? 'Switch to dark theme'
                              : 'Switch to light theme',
                          onTap: shop.toggleTheme,
                        ),
                      ],
                    ),
                  ),
                  if (showCampaign) ...[
                    const SizedBox(height: 16),
                    _HomeReveal(
                      delay: const Duration(milliseconds: 90),
                      child: Text(
                        'Worth discovering',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _HomeReveal(
                    delay: const Duration(milliseconds: 180),
                    child: ValueListenableBuilder(
                      valueListenable: search,
                      builder: (context, value, _) => TextField(
                        controller: search,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) =>
                            shop.loadProducts(search: value),
                        decoration: InputDecoration(
                          hintText: 'Find something you love',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    search.clear();
                                    shop.loadProducts(search: '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showCampaign)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _HomeReveal(
                  delay: const Duration(milliseconds: 220),
                  child: CampaignCarousel(
                    onExplore: (query) {
                      search.text = query;
                      FocusScope.of(context).unfocus();
                      shop.loadProducts(search: query, clearCategory: true);
                    },
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: CatalogControls(shop: shop),
            ),
          ),
          if (shop.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (shop.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'The shop couldn’t load',
                message: shop.error!,
                action: FilledButton.icon(
                  onPressed: shop.loadProducts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ),
            )
          else if (shop.products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Nothing quite like that',
                message: 'Try a different search or browse all products.',
                action: OutlinedButton(
                  onPressed: () {
                    search.clear();
                    shop.loadProducts(search: '', clearCategory: true);
                  },
                  child: const Text('Show everything'),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.query.isNotEmpty
                            ? 'Search results'
                            : shop.category?.name ?? 'Explore the shop',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: ShapeDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${shop.totalProducts}',
                              style: ShopType.numerals.copyWith(fontSize: 12),
                            ),
                            TextSpan(
                              text: shop.totalProducts == 1
                                  ? ' piece'
                                  : ' pieces',
                            ),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final count = constraints.crossAxisExtent >= 760
                    ? 4
                    : constraints.crossAxisExtent >= 520
                    ? 3
                    : 2;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
                        key: ValueKey(shop.products[index].id),
                        product: shop.products[index],
                        index: index,
                      ),
                      childCount: shop.products.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: .76,
                    ),
                  ),
                );
              },
            ),
            if (shop.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      if (shop.moreError case final error?) Text(error),
                      if (shop.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Loading more products',
                          ),
                        )
                      else
                        OutlinedButton(
                          onPressed: shop.loadMoreProducts,
                          child: Text(
                            shop.moreError == null
                                ? 'Load more products'
                                : 'Retry loading more',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      );
    },
  );
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.asset(
          'assets/brand/shoplite-mark.png',
          width: 34,
          height: 34,
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(width: 9),
      Flexible(
        child: Text(
          'ShopLite',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ShopType.display.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 26,
            letterSpacing: -1,
          ),
        ),
      ),
    ],
  );
}

class _HomeReveal extends StatefulWidget {
  const _HomeReveal({required this.child, required this.delay});
  final Widget child;
  final Duration delay;
  @override
  State<_HomeReveal> createState() => _HomeRevealState();
}

class _HomeRevealState extends State<_HomeReveal> {
  var _visible = false;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _visible ? 1 : 0,
    duration: const Duration(milliseconds: 520),
    curve: Curves.easeOutCubic,
    child: AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, .13),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
    ),
  );
}
