class Product {
  final int productId;
  final String productName;
  final double price;
  final int stockQuantity;
  final String? image;
  final String? description;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.stockQuantity,
    this.image,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["productId"],
      productName: json["productName"] ?? "",
      price: (json["price"] as num).toDouble(),
      stockQuantity: json["stockQuantity"] ?? 0,
      image: json["images"],
      description: json["description"],
    );
  }
}