import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/fav_provider.dart';
import 'package:e_commerce_app/core/providers/provider_setup.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List<ProductModel> products = [];
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favService = context.read<FavoriteService>();
    final fetchedProducts = await favService.fetchFavoriteProducts();

    if (mounted) {
      setState(() {
        products = fetchedProducts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favService = context.read<FavoriteService>();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(context: context, title: "favorites"),
      body: Background(
        child: favService.isloading == true
            ? Center(
                child: SmallLoader(),
              )
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return FavProductWidget(
                    width: width,
                    height: height,
                    product: product,
                    onTap: () {
                      context.push('/single-product', extra: product);
                    },
                  );
                },
              ),
      ),
    );
  }
}
