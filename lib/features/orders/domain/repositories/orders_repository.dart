import '../entities/order.dart';
import '../../data/models/api_requests.dart';
import '../../data/models/paginated_orders_response.dart';

abstract class OrdersRepository {
  Future<Order> createOrder(CreateOrderRequest request);
  Future<List<Order>> getOrders();
  Future<Order> getOrderById(String orderId);
  Future<PaginatedOrdersResponse> getUserOrders({
    int page = 1,
    int limit = 5,
    String? status,
    String sort = 'created_at',
    String order = 'desc',
  });
}
