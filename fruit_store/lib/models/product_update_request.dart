class ProductUpdateRequest {
  final String productName;
  final double price;
  final String images;
  final String description;
  final int categoryId;

  ProductUpdateRequest({
    required this.productName,
    required this.price,
    required this.images,
    required this.description,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      "productName": productName,
      "price": price,
      "images": images,
      "description": description,
      "categoryId": categoryId,
    };
  }
}