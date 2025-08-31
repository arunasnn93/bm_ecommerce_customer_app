import '../../domain/entities/order.dart' as order_entity;

class OrderModel extends order_entity.Order {
  const OrderModel({
    required super.id,
    required super.customerId,
    required super.storeId,
    required super.status,
    required super.deliveryAddress,
    required super.deliveryPhone,
    super.notes,
    required super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
    required super.orderItems,
    required super.orderImages,
    required super.orderStatusHistory,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      deliveryPhone: json['delivery_phone']?.toString() ?? '',
      notes: json['notes']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      orderImages: (json['order_images'] as List<dynamic>?)
          ?.map((image) => OrderImageModel.fromJson(image as Map<String, dynamic>))
          .toList() ?? [],
      orderStatusHistory: (json['order_status_history'] as List<dynamic>?)
          ?.map((history) => OrderStatusHistoryModel.fromJson(history as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class OrderItemModel extends order_entity.OrderItem {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.name,
    required super.quantity,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }
}

class OrderImageModel extends order_entity.OrderImage {
  const OrderImageModel({
    required super.id,
    required super.orderId,
    required super.filename,
    required super.url,
    required super.fileSize,
    required super.width,
    required super.height,
    required super.format,
    required super.storagePath,
    required super.bucketName,
    required super.uploadedBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderImageModel.fromJson(Map<String, dynamic> json) {
    return OrderImageModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      filename: json['filename']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      format: json['format']?.toString() ?? '',
      storagePath: json['storage_path']?.toString() ?? '',
      bucketName: json['bucket_name']?.toString() ?? '',
      uploadedBy: json['uploaded_by']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }
}

class OrderStatusHistoryModel extends order_entity.OrderStatusHistory {
  const OrderStatusHistoryModel({
    required super.id,
    required super.orderId,
    required super.status,
    required super.message,
    required super.createdAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }
}
