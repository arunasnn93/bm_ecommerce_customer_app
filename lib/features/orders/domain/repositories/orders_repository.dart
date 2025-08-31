import '../entities/order.dart';
import '../../data/models/api_requests.dart';

abstract class OrdersRepository {
  Future<Order> createOrder(CreateOrderRequest request);
  Future<List<Order>> getOrders();
  Future<Order> getOrderById(String orderId);
}
