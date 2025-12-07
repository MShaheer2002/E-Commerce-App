import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/cart_provider.dart';
import 'package:e_commerce_app/core/providers/fav_provider.dart';
import 'package:e_commerce_app/core/providers/single_product_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleProductScreen extends StatefulWidget {
  final ProductModel productModel;

  const SingleProductScreen({super.key, required this.productModel});

  @override
  State<SingleProductScreen> createState() => _SingleProductScreenState();
}

class _SingleProductScreenState extends State<SingleProductScreen> {
  bool isFav = false;

  @override
  void initState() {
    final favoriteService = context.read<FavoriteService>();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      favoriteService.loadFavoritesForUser();
    });

    isFav = favoriteService.isFavorite(widget.productModel.id ?? "0");
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.read<FavoriteService>();

    log("[Product] ${widget.productModel.imageUrls}");
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageAndAppBarSection(
                    context, isFav, height * 0.5, favoriteProvider),
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
  Widget _buildImageAndAppBarSection(BuildContext context, bool isFav,
      double sectionHeight, FavoriteService favoriteProvider) {
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
              imageUrls: widget.productModel.imageUrls,
              height: sectionHeight,
            ),
            // Sold Out Badge
            if (widget.productModel.isSoldout)
              Positioned(
                top: 80,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'SOLD OUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
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
                  Consumer<FavoriteService>(
                    builder: (context, favoriteService, _) {
                      final isFav = favoriteService
                          .isFavorite(widget.productModel.id ?? "");
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: KprimaryColor,
                          size: 30,
                        ),
                        onPressed: () {
                          favoriteService
                              .toggleFavorite(widget.productModel.id ?? "");
                        },
                      );
                    },
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
          widget.productModel.name,
          style: TextStyle(
            fontSize: width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: verticalPadding * 0.5),

        // Pricing Section
        _buildPricingSection(width),
        SizedBox(height: verticalPadding * 0.5),

        // Product Description
        Text(
          widget.productModel.description,
          style: TextStyle(
            fontSize: width * 0.038,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        SizedBox(height: verticalPadding),

        // Stock Information
        _buildStockInfo(width),
        SizedBox(height: verticalPadding),

        // Quantity Selector (only if not sold out)
        if (!widget.productModel.isSoldout)
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

        if (!widget.productModel.isSoldout) SizedBox(height: verticalPadding),

        // Note Text Field (only if not sold out)
        if (!widget.productModel.isSoldout) _buildNoteTextField(width * 0.035),

        // Amazon Link Button
        if (widget.productModel.productLink != null)
          _amazonLinkButton(widget.productModel.productLink!),

        const SizedBox(height: 20),

        // Add to Cart Button or Sold Out Message
        if (widget.productModel.isSoldout || (widget.productModel.stock <= 0))
          _buildSoldOutButton(width, height)
        else
          Consumer<SingleProductProvider>(
            builder: (context, value, child) => buildAddToBasketButton(
              width,
              height,
              'Add to Cart - \$${(widget.productModel.price * provider.quantity).toStringAsFixed(2)}',
              () {
                log("[cart] ${provider.quantity}");
                final cartService = context.read<CartProvider>();
                cartService.setUser();

                final cartItem = CartItemModel(
                    userId: provider.userId,
                    addedAt: Timestamp.now(),
                    priceAtPurchase: widget.productModel.price,
                    product: widget.productModel,
                    quantity: provider.quantity);

                cartService.addToCart(cartItem);

                context.pop();
                Fluttertoast.showToast(
                    msg: "Added to Cart",
                    textColor: Colors.white,
                    backgroundColor: Colors.green);
              },
            ),
          ),
        SizedBox(height: verticalPadding * 2),
      ],
    );
  }

  // --- Pricing Section with Retail Price Struck Through ---
  Widget _buildPricingSection(double width) {
    final hasRetailPrice = widget.productModel.retailPrice > 0;
    final discount = hasRetailPrice
        ? ((widget.productModel.retailPrice - widget.productModel.price) /
                widget.productModel.retailPrice *
                100)
            .round()
        : 0;

    return Row(
      children: [
        // Current Price (Bold)
        Text(
          '\$${widget.productModel.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: width * 0.07,
            fontWeight: FontWeight.bold,
            color: KprimaryColor,
          ),
        ),
        if (hasRetailPrice) ...[
          SizedBox(width: width * 0.03),
          // Retail Price (Struck Through)
          Text(
            '\$${widget.productModel.retailPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: width * 0.045,
              color: Colors.white.withValues(alpha: 0.5),
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.white.withValues(alpha: 0.5),
              decorationThickness: 2,
            ),
          ),
          SizedBox(width: width * 0.02),
          // Discount Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-$discount%',
              style: TextStyle(
                fontSize: width * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Stock Information ---
  Widget _buildStockInfo(double width) {
    final stock = widget.productModel.stock;
    final isLowStock = stock > 0 && stock <= 5;

    return Row(
      children: [
        Icon(
          stock > 0 ? Icons.check_circle : Icons.cancel,
          color: stock > 0 ? Colors.green : Colors.red,
          size: width * 0.045,
        ),
        SizedBox(width: width * 0.02),
        Text(
          stock > 0
              ? (isLowStock
                  ? 'Only $stock left in stock'
                  : 'In Stock ($stock available)')
              : 'Out of Stock',
          style: TextStyle(
            fontSize: width * 0.035,
            color: stock > 0
                ? (isLowStock ? Colors.orange : Colors.green)
                : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- Sold Out Button ---
  Widget _buildSoldOutButton(double width, double height) {
    return Container(
      width: width,
      height: height * 0.065,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_shopping_cart,
              color: Colors.white.withValues(alpha: 0.7),
              size: width * 0.06,
            ),
            SizedBox(width: width * 0.02),
            Text(
              'Currently Unavailable',
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
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
              hintText: 'Note to Product Plug (Optional)',
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

  Widget _amazonLinkButton(String link) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          log('Could not launch $link');
          Fluttertoast.showToast(msg: "Could not open link");
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9900), // Amazon Primary Orange
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svgs/amazon.svg',
              height: 25,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              'View on Amazon',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Stateless Product Image Slider ---
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
