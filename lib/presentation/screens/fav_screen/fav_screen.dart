import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/fav_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';

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

    // ✅ Safe: run after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
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
    final favService = context.watch<FavoriteService>(); // ✅ use watch here
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(context: context, title: "Favorites"),
      body: Background(
        child: favService.isloading
            ? Center(child: SmallLoader())
            : products.isEmpty
                ? Center(
                    child: Text(
                      "No favorite products yet",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: height * 0.05),
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
