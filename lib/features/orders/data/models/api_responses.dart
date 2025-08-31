import 'order_model.dart';

class CreateOrderResponse {
  final bool success;
  final String message;
  final OrderModel data;
  final String timestamp;

  CreateOrderResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: OrderModel.fromJson(json['data'] ?? {}),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class GetOrdersResponse {
  final bool success;
  final String message;
  final List<OrderModel> data;
  final String timestamp;

  GetOrdersResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory GetOrdersResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ordersData = json['data'] ?? [];
    return GetOrdersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ordersData.map((orderJson) => OrderModel.fromJson(orderJson)).toList(),
      timestamp: json['timestamp'] ?? '',
    );
  }
}
