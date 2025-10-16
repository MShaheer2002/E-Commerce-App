import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/product_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final productProvider = context.read<ProductProvider>();

    return Scaffold(
      appBar: customAppBar(context: context, title: "Products"),
      body: Background(
          showBackButton: false,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: 10,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return Center(
                child: GestureDetector(
                  onTap: () async {
                    // final message =
                    //     await productProvider.sampleProductAdd();

                    // Fluttertoast.showToast(
                    //     msg: message ?? 'something went wrong');
                  },
                  // child: ProductWidget(height, width),
                ),
              );
            },
          )),
    );
  }
}
