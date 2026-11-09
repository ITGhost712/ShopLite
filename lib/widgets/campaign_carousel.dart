import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CampaignCarousel extends StatefulWidget {
  const CampaignCarousel({super.key, required this.onExplore});

  final ValueChanged<String> onExplore;

  @override
  State<CampaignCarousel> createState() => _CampaignCarouselState();
}

class _CampaignCarouselState extends State<CampaignCarousel> {
  static const _campaigns = [
    (
      image: 'assets/campaign/amber-fragrance.jpg',
      title: 'The Scent Edit',
      subtitle: 'Find a fragrance worth remembering.',
      query: 'fragrance',
    ),
    (
      image: 'assets/campaign/walnut-lounge.jpg',
      title: 'The Living Edit',
      subtitle: 'Make yourself at home.',
      query: 'chair',
    ),
  ];
  final _pages = PageController();
  var _selected = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _show(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 440),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height:
                  (constraints.maxWidth * .83).clamp(264.0, 390.0) +
                  (textScale - 1).clamp(0.0, 4.0) * 145,
              child: PageView.builder(
                controller: _pages,
                itemCount: _campaigns.length,
                onPageChanged: (index) => setState(() => _selected = index),
                itemBuilder: (context, index) {
                  final campaign = _campaigns[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1, end: 1.05),
                        duration: reducedMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 1800),
                        curve: Curves.easeOutCubic,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Image.asset(
                          campaign.image,
                          fit: BoxFit.cover,
                          alignment: Alignment(.55, -.5),
                          excludeFromSemantics: true,
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xF8100C08)],
                            stops: [.23, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 16,
                        child: ExcludeSemantics(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: ShapeDecoration(
                              color: AppColors.ink.withValues(alpha: .65),
                              shape: const StadiumBorder(
                                side: BorderSide(color: Colors.white24),
                              ),
                            ),
                            child: Text(
                              '0${index + 1} / 0${_campaigns.length}',
                              style: ShopType.numerals.copyWith(
                                color: AppColors.cream,
                                fontSize: 10,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.cream,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              campaign.subtitle,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.cream),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.cream,
                                foregroundColor: AppColors.ink,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                              ),
                              onPressed: () => widget.onExplore(campaign.query),
                              icon: const Icon(
                                Icons.arrow_outward_rounded,
                                size: 17,
                              ),
                              label: const Text('Explore collection'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < _campaigns.length; index++)
              Semantics(
                selected: _selected == index,
                child: IconButton(
                  tooltip: 'Show ${_campaigns[index].title}',
                  onPressed: () => _show(index),
                  icon: AnimatedContainer(
                    duration: reducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    width: _selected == index ? 8 : 5,
                    height: _selected == index ? 8 : 5,
                    decoration: BoxDecoration(
                      color: _selected == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
