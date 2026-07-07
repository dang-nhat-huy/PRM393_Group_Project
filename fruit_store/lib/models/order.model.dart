// lib/models/order.model.dart
import 'package:json_annotation/json_annotation.dart';
import '../constants/order.constant.dart';
import 'user.model.dart';

part 'order.model.g.dart';

@JsonSerializable()
class OrderItem {
  final int productId;
  final String productName;
  final int price;
  final String? unit;
  final int stockQuantity;
  final String? images;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.unit,
    required this.stockQuantity,
    this.images,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class OrderDetailItem {
  final int orderDetailId;
  final int quantity;
  final int unitPrice;
  final int orderId;
  final int productId;
  final List<dynamic> feedbacks;
  final Product? product;

  const OrderDetailItem({
    required this.orderDetailId,
    required this.quantity,
    required this.unitPrice,
    required this.orderId,
    required this.productId,
    required this.feedbacks,
    this.product,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailItemToJson(this);
}

// ──────────────────────────────────────────────
// Product - nested inside OrderDetailItem
// ──────────────────────────────────────────────

@JsonSerializable()
class Product {
  final int productId;
  final String productName;
  final String? images;
  final int price;
  final int stockQuantity;
  final String? description;
  final String status;
  final String createdAt;
  final int? categoryId;
  final List<dynamic> inventories;
  final List<dynamic> orderDetails;

  const Product({
    required this.productId,
    required this.productName,
    this.images,
    required this.price,
    required this.stockQuantity,
    this.description,
    required this.status,
    required this.createdAt,
    this.categoryId,
    required this.inventories,
    required this.orderDetails,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Payment {
  final int? paymentId;
  final int? amount;
  final String? method;
  final String? status;
  final String? createdAt;

  const Payment({
    this.paymentId,
    this.amount,
    this.method,
    this.status,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

@JsonSerializable()
class Order {
  @JsonKey(name: 'orderId')
  final int orderId;

  final int totalPrice;
  final String? shippingAddress;

  @JsonKey(
    fromJson: OrderStatus.orderStatusFromJson,
    toJson: OrderStatus.orderStatusToJson,
  )
  final OrderStatus? status;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  // From paginated list
  final String? fullname;
  final String? email;
  final List<int>? orderDetailIds;
  final List<OrderItem>? orderItems;

  // From single order detail
  final int? customerId;
  final User? customer;
  final List<OrderDetailItem>? orderDetails;
  final List<Payment>? payments;

  const Order({
    required this.orderId,
    required this.totalPrice,
    this.shippingAddress,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.fullname,
    this.email,
    this.orderDetailIds,
    this.orderItems,
    this.customerId,
    this.customer,
    this.orderDetails,
    this.payments,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
@JsonSerializable()
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

  factory PaginatedOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedOrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedOrderResponseToJson(this);
}