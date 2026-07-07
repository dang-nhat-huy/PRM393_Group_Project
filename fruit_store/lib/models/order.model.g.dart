// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  price: (json['price'] as num).toInt(),
  unit: json['unit'] as String?,
  stockQuantity: (json['stockQuantity'] as num).toInt(),
  images: json['images'] as String?,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'price': instance.price,
  'unit': instance.unit,
  'stockQuantity': instance.stockQuantity,
  'images': instance.images,
};

OrderDetailItem _$OrderDetailItemFromJson(Map<String, dynamic> json) =>
    OrderDetailItem(
      orderDetailId: (json['orderDetailId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      feedbacks: json['feedbacks'] as List<dynamic>,
      product: json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderDetailItemToJson(OrderDetailItem instance) =>
    <String, dynamic>{
      'orderDetailId': instance.orderDetailId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'feedbacks': instance.feedbacks,
      'product': instance.product,
    };

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  images: json['images'] as String?,
  price: (json['price'] as num).toInt(),
  stockQuantity: (json['stockQuantity'] as num).toInt(),
  description: json['description'] as String?,
  status: json['status'] as String,
  createdAt: json['createdAt'] as String,
  categoryId: (json['categoryId'] as num?)?.toInt(),
  inventories: json['inventories'] as List<dynamic>,
  orderDetails: json['orderDetails'] as List<dynamic>,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'images': instance.images,
  'price': instance.price,
  'stockQuantity': instance.stockQuantity,
  'description': instance.description,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'categoryId': instance.categoryId,
  'inventories': instance.inventories,
  'orderDetails': instance.orderDetails,
};

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  paymentId: (json['paymentId'] as num?)?.toInt(),
  amount: (json['amount'] as num?)?.toInt(),
  method: json['method'] as String?,
  status: json['status'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'amount': instance.amount,
  'method': instance.method,
  'status': instance.status,
  'createdAt': instance.createdAt,
};

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderId: (json['orderId'] as num).toInt(),
  totalPrice: (json['totalPrice'] as num).toInt(),
  shippingAddress: json['shippingAddress'] as String?,
  status: OrderStatus.orderStatusFromJson(json['status']),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
  fullname: json['fullname'] as String?,
  email: json['email'] as String?,
  orderDetailIds: (json['orderDetailIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  orderItems: (json['orderItems'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  customerId: (json['customerId'] as num?)?.toInt(),
  customer: json['customer'] == null
      ? null
      : User.fromJson(json['customer'] as Map<String, dynamic>),
  orderDetails: (json['orderDetails'] as List<dynamic>?)
      ?.map((e) => OrderDetailItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'orderId': instance.orderId,
  'totalPrice': instance.totalPrice,
  'shippingAddress': instance.shippingAddress,
  'status': OrderStatus.orderStatusToJson(instance.status),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'fullname': instance.fullname,
  'email': instance.email,
  'orderDetailIds': instance.orderDetailIds,
  'orderItems': instance.orderItems,
  'customerId': instance.customerId,
  'customer': instance.customer,
  'orderDetails': instance.orderDetails,
  'payments': instance.payments,
};

PaginatedOrderResponse _$PaginatedOrderResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedOrderResponse(
  totalItemCount: (json['totalItemCount'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPagesCount: (json['totalPagesCount'] as num).toInt(),
  pageIndex: (json['pageIndex'] as num).toInt(),
  next: json['next'] as bool,
  previous: json['previous'] as bool,
  items: (json['items'] as List<dynamic>)
      .map((e) => Order.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedOrderResponseToJson(
  PaginatedOrderResponse instance,
) => <String, dynamic>{
  'totalItemCount': instance.totalItemCount,
  'pageSize': instance.pageSize,
  'totalPagesCount': instance.totalPagesCount,
  'pageIndex': instance.pageIndex,
  'next': instance.next,
  'previous': instance.previous,
  'items': instance.items,
};
