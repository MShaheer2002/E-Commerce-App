import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/common_widgets.dart/common_widgets.dart';
import 'package:e_commerce_app/core/providers/admin/cloudinary_provider.dart';
import 'package:e_commerce_app/core/providers/admin/productManagement_provider.dart';
import 'package:e_commerce_app/core/themes/constantsColors.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String name = '';
  String description = '';
  double price = 0;
  double retailPrice = 0;
  String? productLink;
  int stock = 0;
  String? selectedCategoryId;
  List<File> imageFiles = [];

  Future<void> _pickImages() async {
    if (imageFiles.length >= 4) {
      Fluttertoast.showToast(
          msg: 'Maximum 4 images allowed',
          textColor: Colors.white,
          backgroundColor: Colors.black);
      return;
    }

    final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);

    if (pickedFiles.isNotEmpty) {
      final newImages = pickedFiles.map((x) => File(x.path)).toList();

      if (imageFiles.length + newImages.length > 4) {
        Fluttertoast.showToast(
            msg: "Maximum 4 images allowed total",
            textColor: Colors.white,
            backgroundColor: Colors.black);
      }

      final allowedImages = [...imageFiles, ...newImages].take(4).toList();
      setState(() => imageFiles = allowedImages);
    }
  }

  void _removeImage(File file) {
    setState(() {
      imageFiles.remove(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: adminCustomAppBar(
        context: context,
        title: "Add Product",
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
                    "Create New Product",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill in the details below to add a new product",
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
                        validator: (v) => v!.isEmpty ? 'Required field' : null,
                        onSaved: (v) => name = v!,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Description',
                        hint: 'Enter product description',
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
                              label: 'Sale Price',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              prefixText: '\$ ',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(v) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                              onSaved: (v) => price = double.parse(v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Stock',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(v) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                              onSaved: (v) => stock = int.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Retail Price Section
                      _buildSectionTitle(
                          "Retail Price", "Original/MSRP price for comparison"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Retail Price',
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        prefixText: '\$ ',
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (double.tryParse(v) == null) {
                              return 'Invalid number';
                            }
                            final retail = double.parse(v);
                            if (retail > 0 && retail < price) {
                              return 'Should be higher than sale price';
                            }
                          }
                          return null;
                        },
                        onSaved: (v) =>
                            retailPrice = v!.isEmpty ? 0 : double.parse(v),
                      ),
                      const SizedBox(height: 32),

                      // Amazon Link Section
                      _buildSectionTitle("Amazon Link (Optional)",
                          "Add product link for reference"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Amazon Product URL',
                        hint: 'https://www.amazon.com/...',
                        keyboardType: TextInputType.url,
                        prefixIcon: Icons.link,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (!Uri.tryParse(v)!.isAbsolute) {
                              return 'Please enter a valid URL';
                            }
                          }
                          return null;
                        },
                        onSaved: (v) => productLink = v!.isEmpty ? null : v,
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
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: KprimaryColor) : null,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
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
          ...imageFiles.map((file) => _buildImageCard(file)),
          if (imageFiles.length < 4) _buildAddImageCard(),
        ],
      ),
    );
  }

  Widget _buildImageCard(File file) {
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
            onTap: () => _removeImage(file),
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
        onPressed: () => _saveProduct(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 22),
            SizedBox(width: 8),
            Text("Save Product",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (imageFiles.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please add at least one image",
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return;
    }

    final cloudinary = context.read<CloudinaryProvider>();
    final productProvider = context.read<ProductmanagementProvider>();

    try {
      // Upload images to Cloudinary under folder: category/productName
      final folderPath = "products/$selectedCategoryId/$name";
      final urls =
          await cloudinary.uploadMultipleImages(imageFiles, folder: folderPath);

      if (urls.isEmpty) {
        Fluttertoast.showToast(
            msg: "Image upload failed!",
            backgroundColor: Colors.black,
            textColor: Colors.white);
        return;
      }

      await productProvider.addNewProduct(
        retailPrice: retailPrice,
        name: name,
        description: description,
        price: price,
        categoryId: selectedCategoryId!,
        stock: stock,
        imageUrls: urls,
        productLink: productLink,
      );

      if (mounted) {
        Fluttertoast.showToast(
            msg: "Product Successfully Added",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong while Adding product try later",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }
  }
}
