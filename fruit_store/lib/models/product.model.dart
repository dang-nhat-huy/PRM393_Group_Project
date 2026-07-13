class Product {
  final int productId;
  final String productName;
  final double price;
  final int stockQuantity;

  final String? image;
  final String? description;

  final String? unit;
  final String? categoryName;
  final String? cropName;
  final String? status;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.stockQuantity,
    this.image,
    this.description,
    this.unit,
    this.categoryName,
    this.cropName,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["productId"] ?? 0,
      productName: json["productName"] ?? "",
      price: (json["price"] as num).toDouble(),
      stockQuantity: json["stockQuantity"] ?? 0,

      image: json["images"],
      description: json["description"],

      unit: json["unit"],
      categoryName: json["categoryName"] ?? json["categoryname"],
      cropName: json["cropName"],
      status: json["status"],
    );
  }
}