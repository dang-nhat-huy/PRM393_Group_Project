import 'package:flutter/material.dart';
import 'package:fruit_store/widgets/product/product_edit/product_category_dropdown.dart';
import 'package:fruit_store/widgets/product/product_edit/product_description_field.dart';
import 'package:fruit_store/widgets/product/product_edit/product_image_field.dart';
import 'package:fruit_store/widgets/product/product_edit/product_image_preview.dart';
import 'package:fruit_store/widgets/product/product_edit/product_name_field.dart';
import 'package:fruit_store/widgets/product/product_edit/product_price_field.dart';

import '../../models/category_model.dart';
import '../../models/product.model.dart';
import '../../models/product_update_request.dart';
import '../../services/api.service.dart';
import '../../services/product.service.dart';

class ProductEditScreen extends StatefulWidget {
  final int productId;
  final ApiService apiService;

  const ProductEditScreen({
    super.key,
    required this.productId,
    required this.apiService,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late final ProductService _productService;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Category> categories = [];

  Category? selectedCategory;

  Product? product;

  bool isLoading = true;
  bool isSaving = false;

  String error = "";

  @override
  void initState() {
    super.initState();

    _productService = ProductService(widget.apiService);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final results = await Future.wait([
        _productService.getProductById(widget.productId),
        _productService.getCategories(),
      ]);

      product = results[0] as Product?;
      categories = results[1] as List<Category>;

      if (product == null) {
        throw Exception("Product not found");
      }

      _nameController.text = product!.productName;
      _priceController.text = product!.price.toStringAsFixed(0);
      _imageController.text = product!.image ?? "";
      _descriptionController.text = product!.description ?? "";

      selectedCategory = categories.firstWhere(
        (e) => e.categoryName == product!.categoryName,
        orElse: () => categories.first,
      );
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final request = ProductUpdateRequest(
        productName: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        images: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: selectedCategory!.categoryId,
      );
      debugPrint("Selected category: ${selectedCategory!.categoryId}");
      debugPrint(request.toJson().toString());
      await _productService.updateProduct(widget.productId, request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Edit Product")),
        body: Center(child: Text(error)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProductImagePreview(imageUrl: _imageController.text),

            const SizedBox(height: 24),

            ProductNameField(controller: _nameController),

            const SizedBox(height: 16),

            ProductPriceField(controller: _priceController),

            const SizedBox(height: 16),

            ProductImageField(
              controller: _imageController,
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 16),

            ProductCategoryDropdown(
              categories: categories,
              selectedCategory: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 16),

            ProductDescriptionField(controller: _descriptionController),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _saveProduct,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? "Saving..." : "Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
