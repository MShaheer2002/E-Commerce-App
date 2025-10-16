import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/single_product_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SingleProductScreen extends StatelessWidget {
  final ProductModel productModel;

  const SingleProductScreen({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    log("[Product] ${productModel.imageUrls}");
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // 🚫 prevents background from moving when keyboard opens
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageAndAppBarSection(context, height * 0.5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: _buildDetailsAndActionSection(context, width, height),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Top Image + AppBar ---
  Widget _buildImageAndAppBarSection(
      BuildContext context, double sectionHeight) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      child: Container(
        height: sectionHeight,
        width: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            _ProductImageSlider(
              imageUrls: productModel.imageUrls,
              height: sectionHeight,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios, color: KprimaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: KprimaryColor,
                      size: 30,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Product Details & Actions ---
  Widget _buildDetailsAndActionSection(
      BuildContext context, double width, double height) {
    final provider = context.read<SingleProductProvider>();
    final verticalPadding = height * 0.02;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: verticalPadding),
        // Product Name
        Text(
          productModel.name,
          style: TextStyle(
            fontSize: width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: verticalPadding * 0.5),

        // Product Description
        Text(
          productModel.description,
          style: TextStyle(
            fontSize: width * 0.038,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        SizedBox(height: verticalPadding),

        // Quantity Selector
        Consumer<SingleProductProvider>(
          builder: (context, value, child) => Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: provider.decreaseQuantity,
              ),
              SizedBox(width: width * 0.05),
              Text(
                '${provider.quantity}',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: width * 0.05),
              _QuantityButton(
                icon: Icons.add,
                onTap: provider.increaseQuantity,
              ),
            ],
          ),
        ),

        SizedBox(height: verticalPadding),

        // Note Text Field
        _buildNoteTextField(width * 0.035),
        SizedBox(height: verticalPadding * 2),

        // Add to Cart Button
        Consumer<SingleProductProvider>(
          builder: (context, value, child) =>
              _buildAddToBasketButton(width, height, provider.quantity),
        ),
        SizedBox(height: verticalPadding * 2),
      ],
    );
  }

  // --- Note Text Field ---
  Widget _buildNoteTextField(double fontSize) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Note to Restaurant (optional)',
              hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  // --- Add to Basket Button ---
  Widget _buildAddToBasketButton(double width, double height, int quantity) {
    return SizedBox(
      width: double.infinity,
      height: height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Add to cart logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: KprimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Add to Cart - ${(productModel.price * quantity).toStringAsFixed(2)} USD',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// --- Stateless Product Image Slider (no stateful widget anymore) ---
class _ProductImageSlider extends StatelessWidget {
  final List<String> imageUrls;
  final double height;

  const _ProductImageSlider({
    required this.imageUrls,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SingleProductProvider>();
    final pageController = PageController();

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: pageController,
        itemCount: imageUrls.length,
        onPageChanged: provider.setImageIndex,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            errorWidget: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

// --- Reusable Quantity Button ---
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: KprimaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(icon, color: KprimaryColor, size: 20),
        ),
      ),
    );
  }
}
