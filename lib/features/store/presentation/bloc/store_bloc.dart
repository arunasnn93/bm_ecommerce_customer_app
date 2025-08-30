import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/store_image.dart';
import '../../domain/usecases/get_store_images_usecase.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoreImagesUseCase getStoreImagesUseCase;

  StoreBloc({
    required this.getStoreImagesUseCase,
  }) : super(StoreInitial()) {
    on<LoadStoreImages>(_onLoadStoreImages);
  }

  Future<void> _onLoadStoreImages(
    LoadStoreImages event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreImagesLoading());

    final result = await getStoreImagesUseCase();

    result.fold(
      (failure) => emit(StoreImagesFailure(failure.message)),
      (storeImages) => emit(StoreImagesSuccess(storeImages)),
    );
  }
}
