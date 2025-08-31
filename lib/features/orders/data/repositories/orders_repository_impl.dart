import '../../domain/repositories/orders_repository.dart';
import '../../domain/entities/order.dart' as order_entity;
import '../datasources/orders_remote_data_source.dart';
import '../models/api_requests.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl(this.remoteDataSource);

  @override
  Future<order_entity.Order> createOrder(CreateOrderRequest request) async {
    try {
      final orderModel = await remoteDataSource.createOrder(request);
      return orderModel; // OrderModel extends Order entity
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<List<order_entity.Order>> getOrders() async {
    try {
      final orderModels = await remoteDataSource.getOrders();
      return orderModels; // List<OrderModel> can be cast to List<Order>
    } catch (e) {
      throw Exception('Failed to get orders: ${e.toString()}');
    }
  }

  @override
  Future<order_entity.Order> getOrderById(String orderId) async {
    try {
      final orderModel = await remoteDataSource.getOrderById(orderId);
      return orderModel; // OrderModel extends Order entity
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }
}
