import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/product_api.dart';
import 'state/shop_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShopLiteApp());
}

class ShopLiteApp extends StatelessWidget {
  const ShopLiteApp({super.key, this.api});

  final ProductApi? api;

  static final _lightTheme = buildShopLiteTheme(Brightness.light);
  static final _darkTheme = buildShopLiteTheme(Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopState(api: api)..initialize(),
      child: Selector<ShopState, bool>(
        selector: (_, shop) => shop.isLightMode,
        builder: (_, isLightMode, home) => MaterialApp(
          title: 'ShopLite',
          debugShowCheckedModeBanner: false,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: isLightMode ? ThemeMode.light : ThemeMode.dark,
          home: home,
        ),
        child: const HomeScreen(),
      ),
    );
  }
}
