import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String customerId;
  final String storeId;
  final String status;
  final String deliveryAddress;
  final String deliveryPhone;
  final String? notes;
  final String totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> orderItems;
  final List<OrderImage> orderImages;
  final List<OrderStatusHistory> orderStatusHistory;

  const Order({
    required this.id,
    required this.customerId,
    required this.storeId,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    required this.orderImages,
    required this.orderStatusHistory,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        storeId,
        status,
        deliveryAddress,
        deliveryPhone,
        notes,
        totalAmount,
        createdAt,
        updatedAt,
        orderItems,
        orderImages,
        orderStatusHistory,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String name;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.name,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        name,
        quantity,
        createdAt,
        updatedAt,
      ];
}

class OrderImage extends Equatable {
  final String id;
  final String orderId;
  final String filename;
  final String url;
  final int fileSize;
  final int width;
  final int height;
  final String format;
  final String storagePath;
  final String bucketName;
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderImage({
    required this.id,
    required this.orderId,
    required this.filename,
    required this.url,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.format,
    required this.storagePath,
    required this.bucketName,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        filename,
        url,
        fileSize,
        width,
        height,
        format,
        storagePath,
        bucketName,
        uploadedBy,
        createdAt,
        updatedAt,
      ];
}

class OrderStatusHistory extends Equatable {
  final String id;
  final String orderId;
  final String status;
  final String message;
  final DateTime createdAt;

  const OrderStatusHistory({
    required this.id,
    required this.orderId,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        status,
        message,
        createdAt,
      ];
}
