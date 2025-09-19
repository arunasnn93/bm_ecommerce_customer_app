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
    on<LoadUserOrders>(_onLoadUserOrders);
    on<LoadMoreUserOrders>(_onLoadMoreUserOrders);
    on<LoadMostRecentUndeliveredOrder>(_onLoadMostRecentUndeliveredOrder);
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

  Future<void> _onLoadUserOrders(LoadUserOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final response = await ordersRepository.getUserOrders(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(OrdersLoaded(
        orders: response.orders,
        pagination: response.pagination,
      ));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreUserOrders(LoadMoreUserOrders event, Emitter<OrdersState> emit) async {
    try {
      final currentState = state;
      if (currentState is OrdersLoaded) {
        final response = await ordersRepository.getUserOrders(
          page: event.page,
          limit: event.limit,
          status: event.status,
        );
        
        final updatedOrders = [...currentState.orders, ...response.orders];
        emit(OrdersLoaded(
          orders: updatedOrders,
          pagination: response.pagination,
        ));
      }
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onLoadMostRecentUndeliveredOrder(
    LoadMostRecentUndeliveredOrder event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      // Load orders with undelivered statuses
      final response = await ordersRepository.getUserOrders(
        page: 1,
        limit: 1,
        status: 'submitted,accepted,packing,ready',
      );
      
      if (response.orders.isNotEmpty) {
        emit(OrdersLoaded(orders: response.orders));
      } else {
        emit(OrdersLoaded(orders: []));
      }
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }
}
