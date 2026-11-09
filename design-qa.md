# ShopLite Design QA

The Poppins update was reviewed on a Pixel 8 with live catalog data. The category popup stays within 45% of the viewport height and is capped at 280 logical pixels. Swiping in the popup revealed additional categories, and selecting one updated the catalog.

- [Home](docs/screenshots/home.png) shows the campaign and the header with the theme switch.
- [Categories](docs/screenshots/categories.png) shows the menu after scrolling, with the storefront still visible.
- [Product details](docs/screenshots/details.png) shows the live product image, title, category, price, rating, description, and cart action.
- [Favorites](docs/screenshots/favorites.png) shows the empty state with Poppins.
- [Cart](docs/screenshots/cart.png) shows the bag total and the Checkout button.
- [Demo checkout](docs/screenshots/checkout.png) and [confirmation](docs/screenshots/checkout-confirmation.png) show the flow tested with sample details on the Pixel 8. Returning to the bag after confirmation preserved the item and its total.

The category screenshot was captured before the regular-weight typography update.

An earlier iPhone 17 Pro simulator pass checked the fragrance campaign, live results, and product details. Saving Calvin Klein CK One showed it in Favorites. Adding it to the bag and increasing the quantity updated the total from $49.99 to $99.98. The quantity persisted when the app was relaunched.
