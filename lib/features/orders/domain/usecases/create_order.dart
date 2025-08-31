import 'package:equatable/equatable.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';
import '../../data/models/api_requests.dart';
import '../../../../core/usecases/usecase.dart';

class CreateOrder implements UseCase<Order, CreateOrderParams> {
  final OrdersRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Order> call(CreateOrderParams params) async {
    return await repository.createOrder(params.request);
  }
}

class CreateOrderParams extends Equatable {
  final CreateOrderRequest request;

  const CreateOrderParams({required this.request});

  @override
  List<Object?> get props => [request];
}
