import 'package:crud_task/models/product.dart';
import 'package:crud_task/state/shop_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _perfume = Product(
  id: 6,
  title: 'Perfume',
  description: '',
  category: 'fragrances',
  price: 49.99,
  rating: 4.4,
  thumbnail: '',
);

const _chair = Product(
  id: 13,
  title: 'Chair',
  description: '',
  category: 'furniture',
  price: 299.99,
  rating: 4.6,
  thumbnail: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ShopState shop;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    shop = ShopState();
  });
  tearDown(() => shop.dispose());

  test('adding the same product twice updates one cart line', () {
    shop.addToCart(_perfume);
    shop.addToCart(_perfume);

    expect(shop.cart.single.quantity, 2);
    expect(shop.cartCount, 2);
  });

  test('subtotal reflects the current quantities of different products', () {
    shop.addToCart(_perfume);
    shop.addToCart(_chair);
    shop.changeQuantity(_perfume, 3);

    expect(shop.subtotal, closeTo(449.96, .00001));
    expect(shop.cartCount, 4);
  });

  test('decreasing to zero and removing leave the cart empty', () {
    shop.addToCart(_perfume);
    shop.addToCart(_chair);
    shop.changeQuantity(_perfume, 0);
    expect(shop.cart.single.product.id, _chair.id);

    shop.removeFromCart(_chair);
    expect(shop.cart, isEmpty);
    expect(shop.subtotal, 0);
  });
}
