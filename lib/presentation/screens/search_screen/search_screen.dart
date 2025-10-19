import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/search_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    // Autofocus keyboard after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF121212), // dark background
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 100),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 8),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.7),
              ),
              child: TextField(
                controller: searchController,
                focusNode: _focusNode,
                autofocus: true,
                textAlignVertical:
                    TextAlignVertical.center, // 👈 centers vertically
                onChanged: (value) {
                  log("[Search] $value");
                  searchProvider.searchProducts(value);
                },
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                      Icons.search,
                      size: 28,
                      color: KprimaryColor,
                    ),
                  ),
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 0, bottom: 0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Background(
        child: Consumer<SearchProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // if (provider.results.isEmpty) {
            //   return const Center(
            //     child: Text(
            //       "No products found",
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.black54,
            //       ),
            //     ),
            //   );
            // }

            return ListView.builder(
              itemCount: provider.results.length,
              itemBuilder: (context, index) {
                final product = provider.results[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrls.isNotEmpty
                          ? product.imageUrls.first
                          : '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      // color: Colors.black,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    "${product.description}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    context.push("/single-product", extra: product);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
