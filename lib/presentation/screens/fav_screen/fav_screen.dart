import 'package:ProductPlug/core/common_widgets.dart/common_widgets.dart';
import 'package:ProductPlug/core/common_widgets.dart/custom_empty_data_widget.dart';
import 'package:ProductPlug/core/providers/fav_provider.dart';
import 'package:ProductPlug/core/themes/constantsColors.dart';
import 'package:ProductPlug/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen>
    with AutomaticKeepAliveClientMixin<FavScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteService>().loadFavoriteProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final favService = context.watch<FavoriteService>();
    final products = favService.favoriteProducts;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.015),
              Image.asset(
                "assets/images/titles/my_smash_cleaned.png",
                height: 70,
              ),
              const SizedBox(height: 10),

              // ✅ SmartRefresher section
              Expanded(
                child: favService.isloading
                    ? Center(child: SmallLoader())
                    : products.isEmpty
                        ? const Center(
                            child: CustomEmptyDataWidget(
                              title: "No favorite products yet",
                            ),
                          )
                        : SmartRefresher(
                            controller: _refreshController,
                            onRefresh: () async {
                              await favService.loadFavoriteProducts(
                                  isRefresh: true);
                              _refreshController.refreshCompleted();
                            },
                            header: const WaterDropHeader(
                              waterDropColor: KprimaryColor,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.only(bottom: height * 0.05),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final ProductModel product = products[index];
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
