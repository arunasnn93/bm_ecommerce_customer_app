import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final CreateOrder createOrder;
  final OrdersRepository ordersRepository;

  OrdersBloc({
    required this.createOrder,
    required this.ordersRepository,
  }) : super(OrdersInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<GetOrdersEvent>(_onGetOrders);
    on<GetOrderByIdEvent>(_onGetOrderById);
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final order = await createOrder(CreateOrderParams(request: event.request));
      emit(OrderCreated(order: order));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onGetOrders(GetOrdersEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await ordersRepository.getOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onGetOrderById(GetOrderByIdEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final order = await ordersRepository.getOrderById(event.orderId);
      emit(OrderLoaded(order: order));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }
}
