import 'dart:convert';

import 'package:crud_task/main.dart';
import 'package:crud_task/services/product_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _categories = [
  {'slug': 'furniture', 'name': 'Furniture'},
  {'slug': 'fragrances', 'name': 'Fragrances'},
];

Map<String, Object> _product(int id, String title, String category) => {
  'id': id,
  'title': title,
  'category': category,
  'price': 10.0,
  'rating': 4.5,
  'thumbnail': 'https://example.test/product.png',
};

http.Response _json(Object value, {int status = 200}) =>
    http.Response(jsonEncode(value), status);

http.Response _page(List<Map<String, Object>> items, int total) =>
    _json({'products': items, 'total': total});

ProductApi _api(
  http.Response Function(Uri url) products, {
  List<Map<String, String>>? categories,
}) => ProductApi(
  client: MockClient((request) async {
    if (request.url.path == '/products/categories') {
      return _json(categories ?? _categories);
    }
    return products(request.url);
  }),
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void _usePhoneViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('category, rating sort, and search combine', (tester) async {
    _usePhoneViewport(tester);
    final requests = <Uri>[];
    await tester.pumpWidget(
      ShopLiteApp(
        api: _api((url) {
          requests.add(url);
          final furniture = _product(1, 'Walnut desk', 'furniture');
          final fragrance = _product(2, 'Desk fragrance', 'fragrances');
          if (url.path == '/products/category/furniture') {
            return _page([furniture], 1);
          }
          return _page([furniture, fragrance], 2);
        }),
      ),
    );
    await _settle(tester);

    await tester.tap(find.byTooltip('Filter by category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Furniture'));
    await _settle(tester);
    expect(requests.last.path, '/products/category/furniture');
    expect(find.text('Walnut desk'), findsOneWidget);
    expect(find.text('Desk fragrance'), findsNothing);

    await tester.tap(find.byTooltip('Sort products'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest rated'));
    await _settle(tester);
    expect(requests.last.queryParameters['sortBy'], 'rating');
    expect(requests.last.queryParameters['order'], 'desc');

    await tester.enterText(find.byType(TextField), 'desk');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);
    expect(requests.last.path, '/products/search');
    expect(requests.last.queryParameters['q'], 'desk');
    expect(find.text('1 piece'), findsOneWidget);
    expect(find.text('Walnut desk'), findsOneWidget);
    expect(find.text('Desk fragrance'), findsNothing);
  });

  testWidgets('the compact category menu scrolls to offscreen options', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final requests = <Uri>[];
    await tester.pumpWidget(
      ShopLiteApp(
        api: _api(
          (url) {
            requests.add(url);
            return _page([], 0);
          },
          categories: [
            for (var index = 1; index <= 20; index++)
              {'slug': 'category-$index', 'name': 'Category $index'},
          ],
        ),
      ),
    );
    await _settle(tester);

    final categoryButton = find.byTooltip('Filter by category');
    await tester.tap(categoryButton);
    await tester.pumpAndSettle();
    final menu = find.ancestor(
      of: find.widgetWithText(PopupMenuItem<String>, 'Category 20'),
      matching: find.byType(Scrollable),
    );
    final lastCategory = find.text('Category 20').hitTestable();

    expect(tester.getSize(menu).height, lessThan(844 / 2));
    expect(lastCategory, findsNothing);
    await tester.scrollUntilVisible(lastCategory, 180, scrollable: menu);
    await tester.tap(lastCategory);
    await _settle(tester);
    expect(requests.last.path, '/products/category/category-20');

    await tester.tap(categoryButton);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(PopupMenuItem<String>, 'Category 20').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('next-page retry keeps the first page and appends results', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final offsets = <String?>[];
    await tester.pumpWidget(
      ShopLiteApp(
        api: _api((url) {
          final offset = url.queryParameters['skip'];
          offsets.add(offset);
          if (offset == null) {
            return _page([_product(1, 'First page product', 'furniture')], 2);
          }
          if (offsets.length == 2) return _json({}, status: 503);
          return _page([_product(2, 'Second page product', 'furniture')], 2);
        }),
      ),
    );
    await _settle(tester);

    final more = find.text('Load more products');
    await tester.scrollUntilVisible(
      more,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _settle(tester);
    await tester.tap(more);
    await _settle(tester);
    expect(find.text('Could not load the next page.'), findsOneWidget);
    expect(find.text('First page product'), findsOneWidget);

    await tester.tap(find.text('Retry loading more'));
    await _settle(tester);
    expect(offsets, [null, '1', '1']);
    expect(find.text('First page product'), findsOneWidget);
    expect(find.text('Second page product'), findsOneWidget);
    expect(more, findsNothing);
  });

  testWidgets('demo checkout validates details and keeps the bag intact', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    final product = _product(1, 'Walnut desk', 'furniture');
    final requests = <Uri>[];
    await tester.pumpWidget(
      ShopLiteApp(
        api: _api((url) {
          requests.add(url);
          return url.path == '/products/1'
              ? _json(product)
              : _page([product], 1);
        }),
      ),
    );
    await _settle(tester);

    final bag = find.text('Bag');
    final checkout = find.text('Checkout');
    await tester.tap(bag);
    await _settle(tester);
    expect(checkout, findsNothing);

    await tester.tap(find.text('Home'));
    await _settle(tester);
    await tester.ensureVisible(find.text('Walnut desk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Walnut desk'));
    await _settle(tester);
    await tester.tap(find.text('Add to bag'));
    await _settle(tester);
    await tester.pageBack();
    await _settle(tester);
    await tester.tap(bag);
    await _settle(tester);

    final requestCount = requests.length;
    await tester.tap(checkout);
    await _settle(tester);
    expect(find.text('1 item'), findsOneWidget);
    expect(find.text(r'$10.00'), findsOneWidget);

    final submit = find.text('Place demo order');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await _settle(tester);
    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('Demo checkout complete'), findsNothing);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jamie Morgan');
    await tester.enterText(fields.at(1), 'jamie@example.com');
    await tester.enterText(fields.at(2), '42 Market Street');
    await tester.enterText(fields.at(3), 'Austin');
    await tester.enterText(fields.at(4), '78701');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await _settle(tester);
    expect(find.text('Demo checkout complete'), findsOneWidget);
    expect(requests, hasLength(requestCount));

    await tester.tap(find.text('Back to bag'));
    await _settle(tester);
    expect(find.text('Walnut desk'), findsOneWidget);
    expect(checkout, findsOneWidget);
  });

  testWidgets('the light theme is restored when the app starts again', (
    tester,
  ) async {
    _usePhoneViewport(tester);
    ShopLiteApp app() => ShopLiteApp(api: _api((_) => _page([], 0)));

    await tester.pumpWidget(app());
    await _settle(tester);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byTooltip('Switch to light theme'));
    await _settle(tester);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await _settle(tester);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    expect(find.byTooltip('Switch to dark theme'), findsOneWidget);
  });
}
