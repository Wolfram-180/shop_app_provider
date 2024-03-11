import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app_provider/providers/cart.dart';
import 'package:shop_app_provider/providers/products.dart';
import 'package:shop_app_provider/widgets/app_drawer.dart';
import 'package:shop_app_provider/widgets/basket_badge.dart';
import 'package:shop_app_provider/widgets/products_grid.dart';
import 'cart_screen.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // different variants:
    // var 1 - calling WITH listen: false - as context is not available
    // commented to show workaround
    // however workaround needed only if NO context
    // AND listen: false not possible (need to listen)
    //Provider.of<Products>(context, listen: false).fetchAndSetProducts();

    // var 2
    // also works, but better use didChangeDependencies
    // because in that case fetchAndSetProducts is treated as async and
    // execution postponed => slowed
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });

    // var 3 - didChangeDependencies below

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit == true) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.favorites,
              ),
              const PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.all,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => BasketBadge(
              child: ch as Widget,
              value: cart.itemQuant.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
