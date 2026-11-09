import 'package:crud_task/models/cart_item.dart';
import 'package:crud_task/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

const headphones = Product(
  id: 1,
  title: 'Wireless Headphones',
  description: 'Test product',
  category: 'electronics',
  price: 129.99,
  rating: 4.8,
  thumbnail: '',
);

void main() {
  test('cart item total uses product price and quantity', () {
    expect(CartItem(product: headphones, quantity: 3).total, 389.97);
  });

  test('copyWith changes quantity and keeps product', () {
    final updated = CartItem(product: headphones).copyWith(quantity: 2);
    expect(updated.quantity, 2);
    expect(updated.product.id, headphones.id);
  });

  test('cart item serializes and restores correctly', () {
    final original = CartItem(product: headphones, quantity: 2);
    final restored = CartItem.fromJson(original.toJson());
    expect(restored.quantity, 2);
    expect(restored.product.title, 'Wireless Headphones');
    expect(restored.total, 259.98);
  });
}
