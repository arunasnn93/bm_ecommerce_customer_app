import 'package:equatable/equatable.dart';

class StoreImage extends Equatable {
  final String id;
  final String title;
  final String description;
  final String url;
  final int width;
  final int height;
  final int orderIndex;
  final Store store;
  
  const StoreImage({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.width,
    required this.height,
    required this.orderIndex,
    required this.store,
  });
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    url,
    width,
    height,
    orderIndex,
    store,
  ];
}

class Store extends Equatable {
  final String id;
  final String name;
  
  const Store({
    required this.id,
    required this.name,
  });
  
  @override
  List<Object> get props => [id, name];
}
