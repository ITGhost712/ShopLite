import 'product.dart';

typedef ProductCategory = ({String slug, String name});
typedef ProductPage = ({List<Product> items, int total});

enum ProductSort {
  featured('Featured'),
  priceAscending('Price: low to high', field: 'price', order: 'asc'),
  priceDescending('Price: high to low', field: 'price', order: 'desc'),
  topRated('Highest rated', field: 'rating', order: 'desc');

  const ProductSort(this.label, {this.field, this.order});

  final String label;
  final String? field;
  final String? order;
}
