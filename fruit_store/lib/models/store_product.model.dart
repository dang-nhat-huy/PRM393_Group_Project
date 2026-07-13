// lib/models/store_product.model.dart

class StoreProduct {
  final int productId;
  final String productName;
  final double price;
  final String? unit;
  final int stockQuantity;
  final String? images;
  final String? description;
  final String status;
  final String createdAt;
  final String? categoryName;
  final String? cropName;

  StoreProduct({
    required this.productId,
    required this.productName,
    required this.price,
    this.unit,
    required this.stockQuantity,
    this.images,
    this.description,
    required this.status,
    required this.createdAt,
    this.categoryName,
    this.cropName,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      images: json['images'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] as String? ?? '',
      categoryName: json['categoryname'] as String? ?? json['categoryName'] as String?,
      cropName: json['cropName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'images': images,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'categoryname': categoryName,
      'cropName': cropName,
    };
  }
}
