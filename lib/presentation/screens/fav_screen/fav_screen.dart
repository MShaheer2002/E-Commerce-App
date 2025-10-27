import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/common_widgets.dart/custom_empty_data_widget.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    final favService = context.read<FavoriteService>();
    products = await favService.fetchFavoriteProducts();
    setState(() {}); // ✅ trigger rebuild once products are fetched
  }

  @override
  Widget build(BuildContext context) {
    final favService = context.watch<FavoriteService>();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.015),
              // ✅ Image always visible (even during loading)
              Image.asset(
                "assets/images/titles/my_smash_cleaned.png",
                height: 70,
              ),
              const SizedBox(height: 10),
              // ✅ Loader only overlays below the title
              Expanded(
                child: favService.isloading
                    ? Center(child: SmallLoader())
                    : products.isEmpty
                        ? const Center(
                            child: CustomEmptyDataWidget(
                              title: "No favorite products yet",
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
                                  context.push(
                                    '/single-product',
                                    extra: product,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
