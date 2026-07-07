class Order {
  final int? orderId;
  final double? totalPrice;
  final String fullname;           // Không null
  final String? email;
  final String status;             // Không null
  final String? shippingAddress;
  final String? createdAt;
  final List<OrderItem> orderItems;

  Order({
    this.orderId,
    this.totalPrice,
    required this.fullname,
    this.email,
    required this.status,
    this.shippingAddress,
    this.createdAt,
    this.orderItems = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      totalPrice: json['totalPrice'],
      fullname: json['fullname']?.toString() ?? 'Không có tên',
      email: json['email'],
      status: json['status']?.toString() ?? 'Unknown',
      shippingAddress: json['shippingAddress'],
      createdAt: json['createdAt']?.toString(),
      orderItems: (json['orderDetails'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final int? productId;
  final String? productName;
  final double? price;
  final String? unit;
  final int? stockQuantity;
  final String? images;

  OrderItem({
    this.productId,
    this.productName,
    this.price,
    this.unit,
    this.stockQuantity,
    this.images,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      price: json['unitPrice'] ?? json['price'],
      unit: json['unit'],
      stockQuantity: json['quantity'] ?? json['stockQuantity'],
      images: json['product']?['images'] ?? json['images'],
    );
  }
}