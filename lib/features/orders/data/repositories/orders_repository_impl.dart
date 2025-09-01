import '../../domain/repositories/orders_repository.dart';
import '../../domain/entities/order.dart' as order_entity;
import '../datasources/orders_remote_data_source.dart';
import '../models/api_requests.dart';
import '../models/paginated_orders_response.dart';

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

  @override
  Future<PaginatedOrdersResponse> getUserOrders({
    int page = 1,
    int limit = 5,
    String? status,
    String sort = 'created_at',
    String order = 'desc',
  }) async {
    try {
      final response = await remoteDataSource.getUserOrders(
        page: page,
        limit: limit,
        status: status,
        sort: sort,
        order: order,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get user orders: ${e.toString()}');
    }
  }
}
