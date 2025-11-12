import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/providers/admin/productManagement_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Background extends StatelessWidget {
  /// Path to local asset (preferred) or network URL if [useNetwork] is true.
  final String assetName;

  /// The content to show on top of the background.
  final Widget? child;

  /// Whether to show a back arrow button at the top left.
  final bool showBackButton;

  /// How the image should fit within the available space.
  final BoxFit fit;

  /// Where to align the image.
  final Alignment alignment;

  /// Optional color overlay placed above the image (useful to tint/darken).
  final Color? overlayColor;

  /// Opacity for the overlay (0.0 - 1.0).
  final double overlayOpacity;

  /// Gaussian blur sigma. 0.0 means no blur.
  final double blurSigma;

  /// If true, loads the asset using a network URL.
  final bool useNetwork;

  /// Semantics label for accessibility (optional).
  final String? semanticsLabel;

  const Background({
    super.key,
    this.assetName = "assets/images/background.png",
    this.child,
    this.showBackButton = false,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.blurSigma = 0.0,
    this.useNetwork = false,
    this.semanticsLabel,
  })  : assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0),
        assert(blurSigma >= 0.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          // --- Background image ---
          Positioned.fill(
            child: Image.asset(
              assetName,
              fit: fit,
              alignment: alignment,
            ),
          ),

          // --- Optional blur layer ---
          if (blurSigma > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(color: Colors.transparent),
              ),
            ),

          // --- Optional overlay tint ---
          if (overlayColor != null && overlayOpacity > 0)
            Positioned.fill(
              child: Container(
                color: overlayColor!.withValues(alpha: overlayOpacity),
              ),
            ),

          // --- Foreground content ---
          if (child != null) Positioned.fill(child: child!),

          // --- Optional back button ---
          if (showBackButton)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: KprimaryColor),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A dynamic, reusable button widget.
class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final bool isDisabled;
  final double horizontalPadding;
  final double verticalPadding;

  const CustomButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = KprimaryColor, // purple
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.height = 50,
    this.isDisabled = false,
    this.horizontalPadding = 20,
    this.verticalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? backgroundColor.withValues(alpha: 0.5)
              : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        onPressed: isDisabled ? null : onPressed,
        child: child,
      ),
    );
  }
}

/// A dynamic, reusable text field widget.

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final double horizontalPadding;
  final IconData? icon;
  final bool readOnly; // ✅ New field for non-editable input (e.g. email)

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.horizontalPadding = 16,
    this.icon,
    this.readOnly = false, // ✅ Default editable
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _obscure : false,
        readOnly: widget.readOnly, // ✅ disables input if true
        style: TextStyle(
          color: widget.readOnly ? Colors.grey[700] : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: Colors.grey,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget SmallLoader(
    {Color backgroundColor = KprimaryColor, double strokeWidth = 3}) {
  return CircularProgressIndicator(
    color: backgroundColor,
    strokeWidth: strokeWidth,
  );
}

// ignore: non_constant_identifier_names
Widget ProductWidget(
    ProductModel product, double height, double width, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: InkWell(
      onTap: () => context.push('/single-product', extra: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (product.isSoldout == true || product.stock <= 0)
              ? Stack(
                  children: [
                    // 🖼 Product Image with rounded corners
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: height * 0.16,
                        width: width * 0.4,
                        color: Colors.grey[200], // optional background
                        child: product.imageUrls.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(color: Colors.black),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrls.first,
                                  fit: BoxFit.cover, // fill and crop if needed
                                  progressIndicatorBuilder: (context, url,
                                          downloadProgress) =>
                                      Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              value:
                                                  downloadProgress.progress)),
                                  errorWidget: (context, url, error) {
                                    return const Icon(Icons.error);
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: Container(
                        height: height * 0.16,
                        width: width * 0.4,
                        decoration: const BoxDecoration(color: Colors.black54),
                        child: const Center(
                          child: Text(
                            "Sold out",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: "Urbanist",
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              :
              // 🖼 Product Image with rounded corners
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: height * 0.16,
                    width: width * 0.4,
                    color: Colors.grey[200], // optional background
                    child: product.imageUrls.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(color: Colors.black),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover, // fill and crop if needed
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: downloadProgress.progress)),
                              errorWidget: (context, url, error) {
                                return const Icon(Icons.error);
                              },
                            ),
                          )
                        : const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),

          SizedBox(height: height * 0.008),

          // 🏷 Product Name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 13,
              color: KprimaryColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          // 💲 Price
          Text(
            "\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              color: KprimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  bool showBackButton = true,
  PreferredSizeWidget? bottom,
  List<Widget>? actions,
  Color titleColor = Colors.white,
  String? backgroundImagePath = "assets/images/background.png",
}) {
  double width = MediaQuery.of(context).size.width;

  return PreferredSize(
    preferredSize:
        Size(width, kToolbarHeight + (bottom?.preferredSize.height ?? 0)),
    child: Stack(
      children: [
        // 🔹 Background image (covers entire AppBar + bottom)
        if (backgroundImagePath != null)
          Container(
            width: width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImagePath),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(color: Colors.black),

        // 🔹 Actual AppBar with transparent background
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontFamily: "Urbanist",
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: showBackButton
              ? IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          actions: actions,
          bottom: bottom,
        ),
      ],
    ),
  );
}

CachedNetworkImage cacheImage(String imageUrl, {bool showLoader = false}) {
  return CachedNetworkImage(
    fit: BoxFit.cover,
    imageUrl: imageUrl,
    progressIndicatorBuilder: (context, url, downloadProgress) => showLoader
        ? Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, value: downloadProgress.progress))
        : const SizedBox.shrink(),
    errorWidget: (context, url, error) {
      log("[Image not Loading] $error");
      return const Icon(Icons.error);
    },
  );
}

Widget FavProductWidget({
  required ProductModel product,
  VoidCallback? onTap,
  VoidCallback? onRemove,
  required double width,
  required double height,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼 Product image with circle border
          SizedBox(
            width: width * 0.22,
            height: width * 0.22,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl:
                    product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 📝 Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: KprimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Price
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: KprimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCartItem({
  required BuildContext context,
  required CartItemModel cartItem,
  required VoidCallback onDelete,
  required Function(int) onQuantityChanged,
}) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: width * 0.04,
      vertical: height * 0.01,
    ),
    padding: EdgeInsets.all(width * 0.03),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: width * 0.22,
            height: width * 0.22,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: cartItem.product.imageUrls.isNotEmpty
                ? Image.network(
                    cartItem.product.imageUrls[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      size: width * 0.1,
                      color: Colors.grey,
                    ),
                  )
                : Icon(
                    Icons.shopping_bag,
                    size: width * 0.1,
                    color: Colors.grey,
                  ),
          ),
        ),
        SizedBox(width: width * 0.03),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                cartItem.product.name,
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: height * 0.005),

              // Price
              Text(
                '\$${cartItem.product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: height * 0.01),

              // Quantity Controls
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (cartItem.quantity > 1) {
                              onQuantityChanged(cartItem.quantity - 1);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(width * 0.015),
                            child: Icon(
                              Icons.remove,
                              size: width * 0.04,
                              color: cartItem.quantity > 1
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                          ),
                          child: Text(
                            '${cartItem.quantity}',
                            style: TextStyle(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            onQuantityChanged(cartItem.quantity + 1);
                          },
                          child: Container(
                            padding: EdgeInsets.all(width * 0.015),
                            child: Icon(
                              Icons.add,
                              size: width * 0.04,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Total Price
                  Text(
                    '\$${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: width * 0.042,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: width * 0.02),

        // Delete Button
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red[400],
            size: width * 0.06,
          ),
          padding: EdgeInsets.all(width * 0.02),
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

// --- Add to Basket Button ---
Widget buildAddToBasketButton(
    double width, double height, String title, VoidCallback ontap) {
  return SizedBox(
    width: double.infinity,
    height: height * 0.07,
    child: ElevatedButton(
      onPressed: ontap,
      style: ElevatedButton.styleFrom(
        backgroundColor: KprimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: width * 0.045,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

PreferredSizeWidget adminCustomAppBar({
  required BuildContext context,
  required String title,
  bool showBackButton = true,
  List<Widget>? actions,
  Color titleColor = Colors.black,
}) {
  double width = MediaQuery.of(context).size.width;

  return PreferredSize(
    preferredSize: Size(width, kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // subtle shadow
            blurRadius: 6,
            offset: const Offset(0, 3), // downward shadow
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // keep it 0 since shadow is from container
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontFamily: "Urbanist",
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: actions,
      ),
    ),
  );
}

Widget buildProductCard(BuildContext context, product,
    ProductmanagementProvider provider, VoidCallback ontap) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 32),
                        )
                      : Icon(Icons.inventory_2_outlined,
                          color: Colors.grey[400], size: 32),
                ),
              ),
              const SizedBox(width: 14),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            provider.getCategoryName(product.categoryId),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Menu
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: Colors.black54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  offset: const Offset(-10, 40),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/admin/edit-product', extra: product);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, product, provider);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 20, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          const Text("Edit Product"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          const Text("Delete"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showDeleteConfirmation(
    BuildContext context, product, ProductmanagementProvider provider) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await provider.deleteProduct(product.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
