import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/api_requests.dart';
import '../models/api_responses.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderModel> createOrder(CreateOrderRequest request);
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient apiClient;

  OrdersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      print('🛒 Creating Order API Call:');
      print('   📦 Items: ${request.orderItems.length}');
      print('   📍 Address: ${request.deliveryAddress}');
      print('   📞 Phone: ${request.deliveryPhone}');
      print('   📝 Notes: ${request.notes ?? "None"}');
      print('   🖼️ Image: ${request.image != null ? "Yes" : "No"}');

      // Create FormData for multipart request
      final formData = FormData.fromMap({
        'items': jsonEncode(request.orderItems.map((item) => item.toJson()).toList()),
        'delivery_address': request.deliveryAddress,
        'delivery_phone': request.deliveryPhone.replaceAll('+', '').replaceAll(' ', '').replaceAll('91', ''),
        if (request.notes != null) 'notes': request.notes,
        if (request.image != null) 'image': await MultipartFile.fromFile(
          request.image!.path,
          filename: request.image!.path.split('/').last,
        ),
      });

      final response = await apiClient.post(
        '/api/orders',
        data: formData,
      );

      print('✅ Order Created Successfully:');
      print('   📋 Order ID: ${response.data['data']['id']}');
      print('   📊 Status: ${response.data['data']['status']}');

      return OrderModel.fromJson(response.data['data']);

    } catch (e) {
      print('💥 Create Order Error: $e');
      
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Error Message: ${e.message}');
        print('   Response Data: ${e.response?.data}');
        
        if (e.response?.statusCode == 400) {
          throw Exception('Invalid order data. Please check your input.');
        } else if (e.response?.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Server error. Please try again later.');
        }
      }
      
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      print('📋 Getting Orders API Call');
      
      final response = await apiClient.get('/api/orders');
      
      final List<dynamic> ordersData = response.data['data'] ?? [];
      final List<OrderModel> orders = ordersData
          .map((orderJson) => OrderModel.fromJson(orderJson))
          .toList();

      print('✅ Retrieved ${orders.length} orders');
      return orders;

    } catch (e) {
      print('💥 Get Orders Error: $e');
      
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        }
      }
      
      throw Exception('Failed to get orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      print('📋 Getting Order by ID: $orderId');
      
      final response = await apiClient.get('/api/orders/$orderId');
      
      final order = OrderModel.fromJson(response.data['data']);
      
      print('✅ Retrieved order: ${order.id}');
      return order;

    } catch (e) {
      print('💥 Get Order by ID Error: $e');
      
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Order not found');
        } else if (e.response?.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        }
      }
      
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }
}
