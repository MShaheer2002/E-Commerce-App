import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/productManagement_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/admin/cloudinary_provider.dart';

class AdminEditProductScreen extends StatefulWidget {
  final ProductModel product;
  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late String name;
  late String description;
  late double price;
  late int stock;
  String? selectedCategoryId;
  late List<File> imageFiles;
  late List<String> existingImageUrls;

  @override
  void initState() {
    super.initState();
    name = widget.product.name;
    description = widget.product.description;
    price = widget.product.price;
    stock = widget.product.stock;
    selectedCategoryId = widget.product.categoryId;
    existingImageUrls = List<String>.from(widget.product.imageUrls);
    imageFiles = [];
  }

  Future<void> _pickImages() async {
    final totalImages = imageFiles.length + existingImageUrls.length;
    if (totalImages >= 4) {
      Fluttertoast.showToast(
          msg: "Maximum 4 images allowed",
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return;
    }

    final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);

    if (pickedFiles.isNotEmpty) {
      final newImages = pickedFiles.map((x) => File(x.path)).toList();
      final allowedCount = 4 - existingImageUrls.length;
      final allowedImages = newImages.take(allowedCount).toList();

      setState(() => imageFiles.addAll(allowedImages));
    }
  }

  void _removeLocalImage(File file) {
    setState(() {
      imageFiles.remove(file);
    });
  }

  void _removeExistingImage(String url) {
    setState(() {
      existingImageUrls.remove(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: adminCustomAppBar(
        context: context,
        title: "Edit Product",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Product Details",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Update product information and save changes",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      _buildSectionTitle("Product Images", "Up to 4 images"),
                      const SizedBox(height: 16),
                      _buildImagePicker(),
                      const SizedBox(height: 32),

                      // Product Details Section
                      _buildSectionTitle(
                          "Product Details", "Basic information"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Product Name',
                        hint: 'Enter product name',
                        initialValue: name,
                        validator: (v) => v!.isEmpty ? 'Required field' : null,
                        onSaved: (v) => name = v!,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Description',
                        hint: 'Enter product description',
                        initialValue: description,
                        maxLines: 4,
                        onSaved: (v) => description = v!,
                      ),
                      const SizedBox(height: 32),

                      // Pricing & Stock Section
                      _buildSectionTitle(
                          "Pricing & Stock", "Set price and quantity"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Price',
                              hint: '0.00',
                              initialValue: price.toString(),
                              keyboardType: TextInputType.number,
                              prefixText: '\$ ',
                              onSaved: (v) => price = double.parse(v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Stock',
                              hint: '0',
                              initialValue: stock.toString(),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => stock = int.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Category Section
                      _buildSectionTitle("Category", "Select product category"),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KprimaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ...existingImageUrls.map((url) => _buildExistingImageCard(url)),
          ...imageFiles.map((file) => _buildLocalImageCard(file)),
          if (existingImageUrls.length + imageFiles.length < 4)
            _buildAddImageCard(),
        ],
      ),
    );
  }

  Widget _buildExistingImageCard(String url) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(url, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => _removeExistingImage(url),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalImageCard(File file) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => _removeLocalImage(file),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageCard() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: KprimaryColor.withValues(alpha: 0.3), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: KprimaryColor, size: 32),
            SizedBox(height: 4),
            Text(
              "Add",
              style: TextStyle(
                  color: KprimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final categories = snapshot.data!.docs
            .map((doc) =>
                CategoryModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return DropdownButtonFormField<String>(
          value: selectedCategoryId,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: KprimaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          hint: const Text("Select a category"),
          items: categories
              .map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  ))
              .toList(),
          onChanged: (val) => setState(() => selectedCategoryId = val),
          validator: (v) => v == null ? 'Please select a category' : null,
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: KprimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _saveChanges(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 22),
            SizedBox(width: 8),
            Text("Save Changes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // If both existing and new images are empty
    if (existingImageUrls.isEmpty && imageFiles.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please add at least one image",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return;
    }

    final cloudinary = context.read<CloudinaryProvider>();
    final productProvider = context.read<ProductmanagementProvider>();

    try {
      // Upload new images to Cloudinary
      List<String> newImageUrls = [];
      if (imageFiles.isNotEmpty) {
        newImageUrls = await cloudinary.uploadMultipleImages(
          imageFiles,
          folder:
              "ecommerce/products/$selectedCategoryId/$name", // Organized by category/product name
        );
      }

      // 2️⃣ Combine existing + new images
      final allImageUrls = [...existingImageUrls, ...newImageUrls];

      // 3️⃣ Create updated product model
      final updatedProduct = ProductModel(
        isSoldout: false,
        retailPrice: 0,
        id: widget.product.id,
        name: name,
        description: description,
        price: price,
        categoryId: selectedCategoryId ?? '',
        imageUrls: allImageUrls,
        stock: stock,
        createdAt: widget.product.createdAt,
      );

      // 4️⃣ Update Firestore document
      await productProvider.updateProduct(widget.product.id!, updatedProduct);

      // 5️⃣ Show success message
      if (mounted) {
        Fluttertoast.showToast(
            msg: "Product updated successfully!",
            backgroundColor: Colors.green,
            textColor: Colors.white);

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong while editing the product. Try again later.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      debugPrint("Error editing product: $e");
    }
  }
}
