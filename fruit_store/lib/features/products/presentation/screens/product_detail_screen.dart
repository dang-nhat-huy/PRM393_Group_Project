import 'package:flutter/material.dart';

import 'package:fruit_store/core/constants/app_colors.dart';
import 'package:fruit_store/core/utils/currency_formatter.dart';
import 'package:fruit_store/features/products/data/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  ProductModel get product => widget.product;

  void _increaseQuantity() {
    if (quantity < product.stockQuantity) {
      setState(() {
        quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void _addToBasket() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm $quantity ${product.unit} ${product.productName.trim()} vào giỏ hàng',
        ),
        backgroundColor: AppColors.primaryOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  num get totalPrice => product.price * quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Column(
        children: [
          _buildTopSection(context),
          Expanded(
            child: _buildInfoSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 14,
                        color: AppColors.textDark,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Go back',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12,
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
                  tag: 'product-image-${product.productId}',
                  child: Container(
                    width: 215,
                    height: 215,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipOval(
                        child: Image.network(
                          product.images,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFFF3E5),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.primaryOrange,
                                size: 52,
                              ),
                            );
                          },
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
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName.trim(),
              style: const TextStyle(
                color: Color(0xFF27214D),
                fontSize: 25,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onTap: _decreaseQuantity,
                  isPrimary: false,
                ),
                const SizedBox(width: 18),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: Color(0xFF27214D),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 18),
                _buildQuantityButton(
                  icon: Icons.add,
                  onTap: _increaseQuantity,
                  isPrimary: true,
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.formatVnd(totalPrice),
                  style: const TextStyle(
                    color: Color(0xFF27214D),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 22),

            _buildSectionTitle('Thông tin sản phẩm'),

            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.category_outlined,
              label: 'Danh mục',
              value: product.categoryName,
            ),

            _buildInfoRow(
              icon: Icons.inventory_2_outlined,
              label: 'Đơn vị',
              value: product.unit,
            ),

            _buildInfoRow(
              icon: Icons.storefront_outlined,
              label: 'Tồn kho',
              value: '${product.stockQuantity} ${product.unit}',
            ),

            _buildInfoRow(
              icon: Icons.eco_outlined,
              label: 'Giống cây',
              value: product.cropName,
            ),

            const SizedBox(height: 18),

            _buildSectionTitle('Mô tả'),

            const SizedBox(height: 10),

            Text(
              product.description.trim().isEmpty
                  ? 'Sản phẩm hiện chưa có mô tả chi tiết.'
                  : product.description.trim(),
              style: const TextStyle(
                color: Color(0xFF5D577E),
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: product.stockQuantity > 0 ? _addToBasket : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  product.stockQuantity > 0 ? 'Add to basket' : 'Hết hàng',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFFF3E5) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isPrimary
                ? const Color(0xFFFFF3E5)
                : const Color(0xFFB8B5C6),
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isPrimary ? AppColors.primaryOrange : const Color(0xFF27214D),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF27214D),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryOrange,
            size: 19,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF27214D),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}