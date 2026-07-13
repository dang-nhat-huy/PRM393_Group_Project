class ProductModel {
  final int productId;
  final String productName;
  final num price;
  final String unit;
  final int stockQuantity;
  final String images;
  final String description;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final String categoryName;
  final String cropId;
  final String cropName;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.images,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryName,
    required this.cropId,
    required this.cropName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      price: json['price'] ?? 0,
      unit: json['unit'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      images: json['images'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
      categoryName: json['categoryname'] ?? '',
      cropId: json['cropId']?.toString() ?? '',
      cropName: json['cropName'] ?? '',
    );
  }
}