import 'package:equatable/equatable.dart';
import '../../data/models/api_requests.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrdersEvent {
  final CreateOrderRequest request;

  const CreateOrderEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class GetOrdersEvent extends OrdersEvent {}

class GetOrderByIdEvent extends OrdersEvent {
  final String orderId;

  const GetOrderByIdEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class LoadUserOrders extends OrdersEvent {
  final int page;
  final int limit;
  final String? status;

  const LoadUserOrders({
    this.page = 1,
    this.limit = 5,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class LoadMoreUserOrders extends OrdersEvent {
  final int page;
  final int limit;
  final String? status;

  const LoadMoreUserOrders({
    required this.page,
    this.limit = 5,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class LoadMostRecentUndeliveredOrder extends OrdersEvent {
  const LoadMostRecentUndeliveredOrder();
}
