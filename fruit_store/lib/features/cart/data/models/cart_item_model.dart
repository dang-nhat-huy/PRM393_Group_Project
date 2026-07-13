class CartItemModel {
  final int cartId;
  final int productId;
  final String productName;
  final num price;
  final int quantity;
  final String unit;
  final String image;
  final int stockQuantity;

  CartItemModel({
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.image,
    required this.stockQuantity,
  });

  num get totalPrice => price * quantity;

  CartItemModel copyWith({
    int? cartId,
    int? productId,
    String? productName,
    num? price,
    int? quantity,
    String? unit,
    String? image,
    int? stockQuantity,
  }) {
    return CartItemModel(
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      image: image ?? this.image,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartId: _toInt(json['cartId'] ?? json['CartId'] ?? json['id']),
      productId: _toInt(json['productId'] ?? json['ProductId']),
      productName: _toString(json['productName'] ?? json['ProductName']),
      price: _toNum(
        json['price'] ??
            json['Price'] ??
            json['unitPrice'] ??
            json['priceQuantity'] ??
            json['PriceQuantity'] ??
            0,
      ),
      quantity: _toInt(json['quantity'] ?? json['Quantity'] ?? 1),
      unit: _toString(json['unit'] ?? json['Unit'] ?? 'kg'),
      image: _toString(
        json['images'] ??
            json['image'] ??
            json['imageUrl'] ??
            json['productImage'] ??
            '',
      ),
      stockQuantity: _toInt(
        json['stockQuantity'] ?? json['StockQuantity'] ?? 0,
      ),
    );
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}