import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final productProvider = context.read<ProductProvider>();

    final products = productProvider.products;

    return Scaffold(
      appBar: customAppBar(context: context, title: "Products"),
      body: Background(
          showBackButton: false,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: 10,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              return Center(
                  child:
                      ProductWidget(products[index], height, width, context));
            },
          )),
    );
  }
}
