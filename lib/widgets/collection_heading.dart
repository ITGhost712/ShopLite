import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CollectionHeading extends StatelessWidget {
  const CollectionHeading({
    super.key,
    required this.label,
    required this.title,
    this.description,
  });

  final String label;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ShopType.eyebrow.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 7),
        Text(title, style: theme.textTheme.headlineLarge),
        if (description case final text?) ...[
          const SizedBox(height: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
