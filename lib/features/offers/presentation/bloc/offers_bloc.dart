import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/paginated_offers_response.dart';
import '../../data/models/offer_model.dart';
import '../../domain/usecases/get_active_offers_usecase.dart';

// Events
abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveOffers extends OffersEvent {
  final int page;
  final int limit;
  final String? search;
  final String? sort;
  final String? order;

  const LoadActiveOffers({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.sort,
    this.order,
  });

  @override
  List<Object?> get props => [page, limit, search, sort, order];
}

class LoadMoreOffers extends OffersEvent {
  final int page;
  final int limit;
  final String? search;
  final String? sort;
  final String? order;

  const LoadMoreOffers({
    required this.page,
    this.limit = 10,
    this.search,
    this.sort,
    this.order,
  });

  @override
  List<Object?> get props => [page, limit, search, sort, order];
}

// States
abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<OfferModel> offers;
  final PaginationModel pagination;
  final bool hasReachedMax;

  const OffersLoaded({
    required this.offers,
    required this.pagination,
    this.hasReachedMax = false,
  });

  OffersLoaded copyWith({
    List<OfferModel>? offers,
    PaginationModel? pagination,
    bool? hasReachedMax,
  }) {
    return OffersLoaded(
      offers: offers ?? this.offers,
      pagination: pagination ?? this.pagination,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [offers, pagination, hasReachedMax];
}

class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final GetActiveOffersUseCase _getActiveOffersUseCase;

  OffersBloc({required GetActiveOffersUseCase getActiveOffersUseCase})
      : _getActiveOffersUseCase = getActiveOffersUseCase,
        super(OffersInitial()) {
    on<LoadActiveOffers>(_onLoadActiveOffers);
    on<LoadMoreOffers>(_onLoadMoreOffers);
  }

  Future<void> _onLoadActiveOffers(
    LoadActiveOffers event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());

    try {
      final response = await _getActiveOffersUseCase(
        page: event.page,
        limit: event.limit,
        search: event.search,
        sort: event.sort,
        order: event.order,
      );

      emit(OffersLoaded(
        offers: response.data,
        pagination: response.pagination,
        hasReachedMax: !response.pagination.hasNext,
      ));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onLoadMoreOffers(
    LoadMoreOffers event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;
    if (currentState is OffersLoaded) {
      if (currentState.hasReachedMax) return;

      try {
        final response = await _getActiveOffersUseCase(
          page: event.page,
          limit: event.limit,
          search: event.search,
          sort: event.sort,
          order: event.order,
        );

        final updatedOffers = [...currentState.offers, ...response.data];
        final hasReachedMax = !response.pagination.hasNext;

        emit(OffersLoaded(
          offers: updatedOffers,
          pagination: response.pagination,
          hasReachedMax: hasReachedMax,
        ));
      } catch (e) {
        emit(OffersError(e.toString()));
      }
    }
  }
}
