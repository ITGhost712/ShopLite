import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/collection_heading.dart';
import '../widgets/empty_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.itemCount,
    required this.total,
  });

  final int itemCount;
  final double total;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  bool _complete = false;

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _complete = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CHECKOUT')),
    body: SafeArea(
      top: false,
      child: _complete
          ? Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.check_rounded,
                  title: 'Demo checkout complete',
                  message: 'No order was placed and no payment was taken.',
                  action: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to bag'),
                  ),
                ),
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: 520, child: _buildForm(context)),
            ),
    ),
  );

  Widget _buildForm(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CollectionHeading(
            label: 'DEMO CHECKOUT',
            title: 'Delivery details',
            description: 'Use sample details to try the checkout.',
          ),
          const SizedBox(height: 20),
          _buildTotal(Theme.of(context)),
          const SizedBox(height: 20),
          _field('Full name', 'Jamie Morgan'),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'jamie@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            validator: (value) => _emailPattern.hasMatch(value?.trim() ?? '')
                ? null
                : 'Enter a valid email address.',
          ),
          const SizedBox(height: 12),
          _field('Street address', '42 Market Street'),
          const SizedBox(height: 12),
          _field('City', 'Austin'),
          const SizedBox(height: 12),
          _field('Postal code', '78701', last: true),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Place demo order'),
          ),
        ],
      ),
    ),
  );

  Widget _buildTotal(ThemeData theme) {
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, color: colors.primary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order total', style: theme.textTheme.titleSmall),
                Text(
                  widget.itemCount == 1
                      ? '1 item'
                      : '${widget.itemCount} items',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '\$${widget.total.toStringAsFixed(2)}',
              textAlign: TextAlign.end,
              style: ShopType.price.copyWith(
                color: colors.primary,
                fontSize: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String example, {bool last = false}) =>
      TextFormField(
        decoration: InputDecoration(labelText: label, hintText: example),
        textCapitalization: last
            ? TextCapitalization.characters
            : TextCapitalization.words,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        validator: (value) => value == null || value.trim().isEmpty
            ? '$label is required.'
            : null,
      );
}
