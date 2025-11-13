import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/product_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final productProvider = context.read<ProductProvider>();
    RefreshController _refresher = RefreshController(initialRefresh: true);

    final products = productProvider.products;

    return Scaffold(
      appBar: customAppBar(context: context, title: "Products"),
      body: Background(
          showBackButton: false,
          child: SmartRefresher(
            controller: _refresher,
            header: const WaterDropHeader(waterDropColor: KprimaryColor),
            onRefresh: () {
              productProvider.listenToProducts();
              _refresher.refreshCompleted();
            },
            enablePullDown: true,
            enablePullUp: false,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                      child: ProductWidget(
                          products[index], height, width, context)),
                );
              },
            ),
          )),
    );
  }
}
