import 'dart:io';

class CreateOrderRequest {
  final String bulkItemsText;
  final String deliveryAddress;
  final String deliveryPhone;
  final String? notes;
  final File? image;

  CreateOrderRequest({
    required this.bulkItemsText,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.notes,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'bulk_items_text': bulkItemsText,
      'delivery_address': deliveryAddress,
      'delivery_phone': deliveryPhone,
      if (notes != null) 'notes': notes,
    };
  }
}

// Keep OrderItemRequest for backward compatibility with existing code
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
