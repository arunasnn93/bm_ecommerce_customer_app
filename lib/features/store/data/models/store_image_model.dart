import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/store_image.dart';
import 'store_model.dart';



class StoreImageModel extends StoreImage {
  const StoreImageModel({
    required super.id,
    required super.title,
    required super.description,
    required super.url,
    required super.width,
    required super.height,
    required super.orderIndex,
    required super.store,
  });
  
  factory StoreImageModel.fromJson(Map<String, dynamic> json) {
    return StoreImageModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      orderIndex: json['order_index'] as int,
      store: StoreModel.fromJson(json['store'] as Map<String, dynamic>),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'width': width,
      'height': height,
      'order_index': orderIndex,
      'store': (store as StoreModel).toJson(),
    };
  }
}
