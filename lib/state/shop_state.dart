import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_catalog.dart';
import '../services/product_api.dart';
import '../services/shop_storage.dart';

class ShopState extends ChangeNotifier {
  ShopState({ProductApi? api, ShopStorage? storage})
    : _api = api ?? ProductApi(),
      _storage = storage ?? ShopStorage();

  final ProductApi _api;
  final ShopStorage _storage;
  List<Product> products = [];
  List<Product> favorites = [];
  List<CartItem> cart = [];
  bool isLoading = true;
  String? error;
  String query = '';
  ProductCategory? category;
  ProductSort sort = ProductSort.featured;
  List<ProductCategory> categories = [];
  bool loadingCategories = false;
  bool categoriesFailed = false;
  bool isLoadingMore = false;
  String? moreError;
  int totalProducts = 0;
  int _nextOffset = 0;
  bool get hasMore => _nextOffset < totalProducts;
  bool isLightMode = false;
  bool _themeChanged = false;
  int _listingRequest = 0;
  bool _disposed = false;

  Future<Product> fetchProduct(int id) => _api.fetchProduct(id);

  @override
  void dispose() {
    _disposed = true;
    _api.close();
    super.dispose();
  }

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  bool isFavorite(Product product) =>
      favorites.any((item) => item.id == product.id);

  Future<void> initialize() async {
    try {
      final restored = await Future.wait([
        _storage.loadCart(),
        _storage.loadFavorites(),
        _storage.loadLightMode(),
      ]);
      if (_disposed) return;
      cart = restored[0] as List<CartItem>;
      favorites = restored[1] as List<Product>;
      if (!_themeChanged) isLightMode = restored[2] as bool;
      notifyListeners();
    } catch (_) {
      // An unreadable local cache should never prevent browsing products.
    }
    if (_disposed) return;
    await Future.wait([
      if (_listingRequest == 0) loadProducts(),
      loadCategories(),
    ]);
  }

  Future<void> toggleTheme() async {
    _themeChanged = true;
    isLightMode = !isLightMode;
    notifyListeners();
    await _storage.saveLightMode(isLightMode);
  }

  Future<void> loadCategories() async {
    if (loadingCategories) return;
    loadingCategories = true;
    categoriesFailed = false;
    notifyListeners();
    try {
      final result = await _api.fetchCategories();
      if (_disposed) return;
      categories = result;
    } catch (_) {
      if (_disposed) return;
      categoriesFailed = true;
    }
    loadingCategories = false;
    notifyListeners();
  }

  Future<void> selectCategory(ProductCategory? value) {
    category = value;
    return loadProducts();
  }

  Future<void> selectSort(ProductSort value) {
    sort = value;
    return loadProducts();
  }

  Future<void> loadProducts({
    String? search,
    bool clearCategory = false,
  }) async {
    final request = ++_listingRequest;
    query = search?.trim() ?? query;
    if (clearCategory) category = null;
    isLoading = true;
    isLoadingMore = false;
    error = null;
    moreError = null;
    totalProducts = 0;
    _nextOffset = 0;
    notifyListeners();
    try {
      final result = await _fetchPage(0);
      if (_disposed || request != _listingRequest) return;
      products = result.items;
      totalProducts = result.total;
      _nextOffset = result.items.length;
    } catch (_) {
      if (_disposed || request != _listingRequest) return;
      error =
          'We could not load products. Check your connection and try again.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    final request = _listingRequest;
    isLoadingMore = true;
    moreError = null;
    notifyListeners();
    try {
      final result = await _fetchPage(_nextOffset);
      if (_disposed || request != _listingRequest) return;
      final existingIds = products.map((item) => item.id).toSet();
      products = [
        ...products,
        ...result.items.where((item) => existingIds.add(item.id)),
      ];
      totalProducts = result.total;
      _nextOffset = result.items.isEmpty
          ? result.total
          : _nextOffset + result.items.length;
    } catch (_) {
      if (_disposed || request != _listingRequest) return;
      moreError = 'Could not load the next page.';
    }
    isLoadingMore = false;
    notifyListeners();
  }

  Future<ProductPage> _fetchPage(int offset) => _api.fetchProducts(
    query: query,
    category: category?.slug,
    sort: sort,
    offset: offset,
  );

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      favorites.removeWhere((item) => item.id == product.id);
    } else {
      favorites.add(product);
    }
    notifyListeners();
    _storage.saveFavorites(favorites);
  }

  void addToCart(Product product) {
    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      cart.add(CartItem(product: product));
    } else {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    }
    notifyListeners();
    _storage.saveCart(cart);
  }

  void changeQuantity(Product product, int quantity) {
    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index == -1) return;
    if (quantity <= 0) {
      cart.removeAt(index);
    } else {
      cart[index] = cart[index].copyWith(quantity: quantity);
    }
    notifyListeners();
    _storage.saveCart(cart);
  }

  void removeFromCart(Product product) => changeQuantity(product, 0);
}
