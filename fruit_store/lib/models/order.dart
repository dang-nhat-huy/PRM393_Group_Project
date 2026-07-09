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

class PaginatedOrderResponse {
  final int totalItemCount;
  final int pageSize;
  final int totalPagesCount;
  final int pageIndex;
  final bool next;
  final bool previous;
  final List<Order> items;

  const PaginatedOrderResponse({
    required this.totalItemCount,
    required this.pageSize,
    required this.totalPagesCount,
    required this.pageIndex,
    required this.next,
    required this.previous,
    required this.items,
  });

  factory PaginatedOrderResponse.fromJson(
      Map<String, dynamic> json) {
    return PaginatedOrderResponse(
      totalItemCount: json['totalItemCount'] ?? 0,
      pageSize: json['pageSize'] ?? 20,
      totalPagesCount: json['totalPagesCount'] ?? 1,
      pageIndex: json['pageIndex'] ?? 1,
      next: json['next'] ?? false,
      previous: json['previous'] ?? false,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}