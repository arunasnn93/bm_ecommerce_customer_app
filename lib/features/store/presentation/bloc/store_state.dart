part of 'store_bloc.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

class StoreInitial extends StoreState {}

class StoreImagesLoading extends StoreState {}

class StoreImagesSuccess extends StoreState {
  final List<StoreImage> storeImages;

  const StoreImagesSuccess(this.storeImages);

  @override
  List<Object> get props => [storeImages];
}

class StoreImagesFailure extends StoreState {
  final String message;

  const StoreImagesFailure(this.message);

  @override
  List<Object> get props => [message];
}
