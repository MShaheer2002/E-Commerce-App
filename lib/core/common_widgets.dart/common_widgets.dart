import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
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
                color: overlayColor!.withOpacity(overlayOpacity),
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
          backgroundColor:
              isDisabled ? backgroundColor.withOpacity(0.5) : backgroundColor,
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

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.horizontalPadding = 16,
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
        style: const TextStyle(color: Colors.black),
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
Widget SmallLoader({Color backgroundColor = KprimaryColor}) {
  return CircularProgressIndicator(
    color: backgroundColor,
    strokeWidth: 3,
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
          // 🖼 Product Image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: height * 0.16,
              width: width * 0.4,
              color: Colors.grey[200], // optional background
              child: product.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
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
  List<Widget>? actions,
  Color titleColor = Colors.white,
  String? backgroundImagePath = "assets/images/background.png",
}) {
  double width = MediaQuery.of(context).size.width;

  return PreferredSize(
    preferredSize: Size(width, kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        image: backgroundImagePath != null
            ? DecorationImage(
                image: AssetImage(backgroundImagePath),
                fit: BoxFit.fitWidth,
              )
            : null,
        color: backgroundImagePath == null
            ? Colors.black // fallback background
            : null,
      ),
      child: AppBar(
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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: actions,
      ),
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
      return Icon(Icons.error);
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
            color: Colors.grey.withOpacity(0.15),
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
