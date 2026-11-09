import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_catalog.dart';

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://dummyjson.com/products';

  Future<Product> fetchProduct(int id) async =>
      Product.fromJson(await _get(Uri.parse('$_baseUrl/$id')));

  Future<List<ProductCategory>> fetchCategories() async {
    final body = await _get(Uri.parse('$_baseUrl/categories')) as List<dynamic>;
    return [
      for (final item in body.cast<Map<String, dynamic>>())
        (slug: item['slug'] as String, name: item['name'] as String),
    ];
  }

  Future<ProductPage> fetchProducts({
    String query = '',
    String? category,
    ProductSort sort = ProductSort.featured,
    int offset = 0,
    int limit = 20,
  }) async {
    final search = query.trim();
    final combined = search.isNotEmpty && category != null;
    final path = search.isNotEmpty
        ? '$_baseUrl/search'
        : category != null
        ? '$_baseUrl/category/${Uri.encodeComponent(category)}'
        : _baseUrl;
    // Search and category are separate endpoints. Apply the category to all
    // search matches before taking a page so the result count stays accurate.
    final endpoint = Uri.parse(path).replace(
      queryParameters: {
        'limit': combined ? '0' : '$limit',
        if (offset > 0 && !combined) 'skip': '$offset',
        if (search.isNotEmpty) 'q': search,
        'sortBy': ?sort.field,
        'order': ?sort.order,
      },
    );
    final body = await _get(endpoint) as Map<String, dynamic>;
    final products = (body['products'] as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
    if (combined) {
      final matches = products
          .where((item) => item.category == category)
          .toList();
      return (
        items: matches.skip(offset).take(limit).toList(),
        total: matches.length,
      );
    }
    return (items: products, total: body['total'] as int);
  }

  Future<dynamic> _get(Uri endpoint) async {
    final response = await _client
        .get(endpoint)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Unable to load product data (${response.statusCode}).');
    }
    return jsonDecode(response.body);
  }

  void close() => _client.close();
}
