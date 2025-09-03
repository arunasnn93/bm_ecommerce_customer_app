class OfferModel {
  final String id;
  final String storeId;
  final String offerHeading;
  final String offerDescription;
  final String imageFilename;
  final String imageUrl;
  final int imageSize;
  final int imageWidth;
  final int imageHeight;
  final String imageFormat;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StoreModel store;

  OfferModel({
    required this.id,
    required this.storeId,
    required this.offerHeading,
    required this.offerDescription,
    required this.imageFilename,
    required this.imageUrl,
    required this.imageSize,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageFormat,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.store,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? '',
      offerHeading: json['offer_heading'] ?? '',
      offerDescription: json['offer_description'] ?? '',
      imageFilename: json['image_filename'] ?? '',
      imageUrl: json['image_url'] ?? '',
      imageSize: json['image_size'] ?? 0,
      imageWidth: json['image_width'] ?? 0,
      imageHeight: json['image_height'] ?? 0,
      imageFormat: json['image_format'] ?? '',
      isActive: json['is_active'] ?? false,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      store: StoreModel.fromJson(json['store'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'offer_heading': offerHeading,
      'offer_description': offerDescription,
      'image_filename': imageFilename,
      'image_url': imageUrl,
      'image_size': imageSize,
      'image_width': imageWidth,
      'image_height': imageHeight,
      'image_format': imageFormat,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'store': store.toJson(),
    };
  }
}

class StoreModel {
  final String id;
  final String name;

  StoreModel({
    required this.id,
    required this.name,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
