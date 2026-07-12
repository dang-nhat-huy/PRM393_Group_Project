import 'package:flutter/material.dart';

import '../../models/product.model.dart';
import '../../services/api.service.dart';
import '../../services/product.service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final ApiService apiService;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.apiService,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  late final ProductService _productService;

  Product? product;

  bool isLoading = true;

  String error = "";

  @override
  void initState() {
    super.initState();

    _productService = ProductService(widget.apiService);

    fetchProduct();
  }

  Future<void> fetchProduct() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final result =
          await _productService.getProductById(
        widget.productId,
      );

      setState(() {
        product = result;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Product"),
        ),
        body: Center(
          child: Text(error),
        ),
      );
    }

    if (product == null) {
      return const Scaffold(
        body: Center(
          child: Text("Product not found"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: RefreshIndicator(
        onRefresh: fetchProduct,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildTopSection(),

            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 14,
              left: 18,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 14,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Go back",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned.fill(
              top: 48,
              child: Center(
                child: Hero(
                  tag:
                      "product-image-${product!.productId}",
                  child: Container(
                    width: 215,
                    height: 215,
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(.18),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(10),
                      child: ClipOval(
                        child: Image.network(
                          product!.image ?? "",
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  Container(
                            color:
                                Colors.grey.shade200,
                            child: const Icon(
                              Icons.image,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        26,
        24,
        24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            product!.productName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xff27214D),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "₫${product!.price.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),

          const SizedBox(height: 24),

          const Divider(),

          const SizedBox(height: 18),

          _buildSectionTitle(
              "Product Information"),

          const SizedBox(height: 16),       

          _buildInfoRow(
            Icons.inventory_2_outlined,
            "Stock",
            "${product!.stockQuantity} kg",
          ),
                  

          

          _buildInfoRow(
            Icons.category_outlined,
            "Category",
            product!.categoryName ?? "-",
          ),

          _buildInfoRow(
            Icons.eco,
            "Crop",
            product!.cropName ?? "-",
          ),

          

          _buildInfoRow(
            Icons.check_circle_outline,
            "Status",
            product!.status ?? "-",
          ),

          const SizedBox(height: 24),

          _buildSectionTitle("Description"),

          const SizedBox(height: 12),

          Text(
            product!.description?.isNotEmpty ==
                    true
                ? product!.description!
                : "No description",
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xff5D577E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff27214D),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 45,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepOrange,
            size: 19,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xff27214D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}