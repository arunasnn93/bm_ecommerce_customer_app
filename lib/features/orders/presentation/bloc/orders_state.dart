import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../data/models/paginated_orders_response.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final PaginationInfo? pagination;

  const OrdersLoaded({
    required this.orders,
    this.pagination,
  });

  @override
  List<Object?> get props => [orders, pagination];
}

class OrderLoaded extends OrdersState {
  final Order order;

  const OrderLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCreated extends OrdersState {
  final Order order;

  const OrderCreated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}
