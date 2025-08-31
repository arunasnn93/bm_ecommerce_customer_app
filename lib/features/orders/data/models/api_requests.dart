import 'dart:io';

class CreateOrderRequest {
  final List<OrderItemRequest> orderItems;
  final String deliveryAddress;
  final String deliveryPhone;
  final String? notes;
  final File? image;

  CreateOrderRequest({
    required this.orderItems,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.notes,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_items': orderItems.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'delivery_phone': deliveryPhone,
      if (notes != null) 'notes': notes,
    };
  }
}

class OrderItemRequest {
  final String name;
  final int quantity;

  OrderItemRequest({
    required this.name,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }
}
