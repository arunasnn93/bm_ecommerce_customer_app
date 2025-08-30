import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/store_image.dart';

part 'store_model.g.dart';

@JsonSerializable()
class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.name,
  });
  
  factory StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);
  Map<String, dynamic> toJson() => _$StoreModelToJson(this);
}
